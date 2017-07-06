#!/bin/bash -e

function install_packages() {
  echo "== Installing packages =="
  if [ ! `which sudo` ]; then
    apt-get update
    apt-get install -y sudo
  fi

  sudo dpkg --add-architecture i386
  sudo apt-get update
  sudo apt-get install -y build-essential \
                          libc6:i386 \
                          libncurses5:i386 \
                          libstdc++6:i386 \
                          locales \
                          git \
                          cmake \
                          vim \
                          tmux \
                          python-dev \
                          python-pip \
                          python3-dev \
                          python3-pip \
                          autoconf \
                          automake \
                          pkg-config \
                          libevent-dev \
                          libncurses5-dev \
                          exuberant-ctags \
                          curl \
                          wget \
                          llvm-dev \
                          libclang-dev \
                          zlib1g-dev \
                          libssl-dev \
                          zip \
                          thefuck \
                          software-properties-common # for add-apt-repository
  echo "== Finished installing packages =="

  echo "== Installing neovim =="
  sudo add-apt-repository -y ppa:neovim-ppa/unstable

  sudo apt-get update
  sudo apt-get install -y neovim

  pip2 install neovim
  pip3 install neovim

  sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
  # sudo update-alternatives --config vi
  sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
  # sudo update-alternatives --config vim
  sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
  # sudo update-alternatives --config editor

  locale-gen en_US.UTF-8

  echo "== Finished installing neovim == "
}

function dot_config {
  /usr/bin/git --git-dir=$HOME/git/dotfiles.git --work-tree=$HOME $@
}

function configure_dot_files() {
  echo "== Configuring dot files =="
  cd $HOME
  mkdir -p $HOME/git
  git clone --bare https://github.com/yt27/dotfiles.git $HOME/git/dotfiles.git

  echo "Backing up pre-existing dot files.";
  mkdir -p $HOME/.config-backup
  dot_config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} $HOME/.config-backup/{} || true

  dot_config checkout
  dot_config config status.showUntrackedFiles no

  echo "alias gh='cd /home/$USER'" >> $HOME/.bashrc

  echo "== Finished configuring dot files =="
}

function build_tmux() {
  echo "== Building tmux =="
  cd $HOME/git
  git clone https://github.com/tmux/tmux.git

  cd tmux
  git checkout 2.5
  sh autogen.sh
  ./configure --prefix=$HOME/local/tmux
  make -j `nproc`
  make install
  make distclean

  echo "== Installing tmux plugins...== "
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

  $HOME/.tmux/plugins/tpm/bin/install_plugins
  echo "== Finished installing tmux plugins...== "

  echo "== Finished building tmux =="
}

function build_rtags() {
  echo "== Building rtags =="
  cd $HOME/git
  git clone --recursive https://github.com/Andersbakken/rtags.git

  cd rtags
  mkdir build
  cd build
  cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_INSTALL_PREFIX=$HOME/local/rtags ..
  make -j `nproc`
  make install
  make clean

  if [ `which systemctl` ]; then
    echo "== Configuring systemd to autostart rdm =="
    mkdir -p $HOME/.config/systemd/user
    cat >> $HOME/.config/systemd/user/rdm.socket << HERE
[Unit]
Description=RTags daemon socket

[Socket]
ListenStream=%t/rdm.socket

[Install]
WantedBy=default.target
HERE

    cat >> $HOME/.config/systemd/user/rdm.service << HERE
[Unit]
Description=RTags daemon

Requires=rdm.socket

[Service]
Type=simple
ExecStart=$HOME/local/rtags/bin/rdm -v --inactivity-timeout 300 --log-flush
HERE

    systemctl --user enable rdm.socket || echo "Failed to enable rdm.socket; please run the following command manually: systemctl --user enable rdm.socket"
    systemctl --user start rdm.socket || echo "Failed to start rdm.socket; please run the following command manually: systemctl --user start rdm.socket"
    echo "== Finished configuring systemd to autostart rdm =="
  fi
  echo "== Finished building rtags =="
}

function install_nvm() {
  echo "== Installing nvm =="
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

  echo "== Finished installing nvm =="
}

function install_node() {
  echo "== Installing installing node =="
  nvm install node
  nvm use node
  echo "== Finished installing node =="
}

function install_sdkman() {
  echo "== Installing installing sdkman =="
  curl -s "https://get.sdkman.io" | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  echo "== Finished installing sdkman =="
}

function install_java() {
  echo "== Installing installing java =="
  sdk install java
  echo "== Finished installing java =="
}

function install_gradle() {
  echo "== Installing installing gradle =="
  sdk install gradle
  echo "== Finished installing gradle =="
}

function install_scala() {
  echo "== Installing installing scala =="
  sdk install scala
  echo "== Finished installing scala =="
}

function build_global() {
  mkdir -p $HOME/local/src
  cd $HOME/local/src

  local version='6.5.7'
  wget http://tamacom.com/global/global-$version.tar.gz
  tar xvf global-$version.tar.gz
  cd global-$version

  ./configure --prefix=$HOME/local/global
  make -j `nproc`
  make install
}

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
                          git \
                          cmake \
                          vim \
                          tmux \
                          python-dev \
                          python-pip \
                          python3-dev \
                          python3-pip \
                          global \
                          autoconf \
                          automake \
                          pkg-config \
                          libevent-dev \
                          libncurses5-dev \
                          exuberant-ctags \
                          curl \
                          llvm-dev \
                          libclang-dev \
                          zlib1g-dev \
                          libssl-dev \
                          thefuck \
                          software-properties-common # for add-apt-repository
  echo "== Finished installing packages =="

  echo "== Installing neovim, java =="
  sudo add-apt-repository -y ppa:neovim-ppa/stable
  sudo add-apt-repository -y ppa:webupd8team/java

  echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
  echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

  sudo apt-get update
  sudo apt-get install -y neovim oracle-java7-installer

  sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
  # sudo update-alternatives --config vi
  sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
  # sudo update-alternatives --config vim
  sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
  # sudo update-alternatives --config editor

  echo "== Finished installing neovim, java == "
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

  echo "== Finished configuring dot files =="
}

function build_tmux() {
  echo "== Building tmux =="
  cd $HOME/git
  git clone https://github.com/tmux/tmux.git

  cd tmux
  git checkout 2.2
  sh autogen.sh
  ./configure --prefix=$HOME/local/tmux
  make && make install

  echo "== Installing tmux plugins...== "
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

  # tmux complained about bad locale...
  # tmux: need UTF-8 locale (LC_CTYPE) but have ANSI_X3.4-1968
  locale-gen en_US.UTF-8
  update-locale LANG=en_US.UTF-8

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
  make -j
  make install

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

  nvm install node
  nvm use node
  echo "== Finished installing nvm =="
}

#!/bin/bash

echo "Initializing environment..."

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
                        software-properties-common # for add-apt-repository

echo "Installing node, java..."
sudo add-apt-repository -y ppa:webupd8team/java

curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -

echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

sudo apt-get update
sudo apt-get install -y nodejs \
                        oracle-java7-installer

echo "Cloning some git repos..."
mkdir -p ~/Development/git

cd ~/Development/git
git clone https://github.com/dpblue27/dotfiles.git
git clone https://github.com/tmux/tmux.git
git clone --recursive https://github.com/Andersbakken/rtags.git

echo "Configuring dot files..."
cd ~/Development/git/dotfiles
git submodule init
git submodule update

cd
if [ -f .bashrc ]; then mv .bashrc .bashrc.bak; fi
ln -s ~/Development/git/dotfiles/bashrc .bashrc
if [ -f .tmux.conf ]; then mv .tmux.conf .tmux.conf.bak; fi
ln -s ~/Development/git/dotfiles/tmux.conf .tmux.conf
if [ -f .vimrc ]; then mv .vimrc .vimrc.bak; fi
ln -s ~/Development/git/dotfiles/vimrc .vimrc
if [ -f .vim ]; then mv .vim .vim.bak; fi
ln -s ~/Development/git/dotfiles/vim .vim

echo "Building tmux..."
cd ~/Development/git/tmux
git checkout 2.2
sh autogen.sh
./configure --prefix=$HOME/local/tmux
make && make install

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# tmux complained about bad locale...
# tmux: need UTF-8 locale (LC_CTYPE) but have ANSI_X3.4-1968
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

echo "Installing tmux plugins..."
~/.tmux/plugins/tpm/bin/install_plugins

echo "Installing vim plugins..."
~/.vim/bundle/neobundle.vim/bin/neoinstall

echo "Building YouCompleteMe..."
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer

echo "Building rtags..."
cd ~/Development/git/rtags
mkdir build
cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_INSTALL_PREFIX=$HOME/local/rtags ..
make -j
make install

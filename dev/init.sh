#!/bin/bash

echo "Initializing image..."

echo "Configuring dot files..."
cd
mkdir -p git

cd ~/git
git clone https://github.com/dpblue27/dotfiles.git
git clone https://github.com/tmux/tmux.git

cd ~/git/dotfiles
git submodule init
git submodule update

cd
rm .bashrc
ln -s git/dotfiles/bashrc .bashrc
ln -s git/dotfiles/tmux.conf .tmux.conf
ln -s git/dotfiles/vimrc .vimrc
ln -s git/dotfiles/vim .vim

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "Building tmux..."
cd ~/git/tmux
git checkout 2.2
sh autogen.sh
./configure --prefix=$HOME/local/tmux
make && make install

# tmux complained about bad locale...
# tmux: need UTF-8 locale (LC_CTYPE) but have ANSI_X3.4-1968
localedef -f UTF-8 -i en_US en_US.UTF-8

echo "Installing tmux plugins..."
~/.tmux/plugins/tpm/bin/install_plugins

echo "Installing vim plugins..."
~/.vim/bundle/neobundle.vim/bin/neoinstall

cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer

#!/bin/bash -e

. /tmp/functions.sh

install_packages
configure_dot_files
build_tmux
build_rtags
install_nvm

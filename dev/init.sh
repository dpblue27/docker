#!/bin/bash -e

. functions.sh

install_packages

configure_dot_files

build_tmux
build_rtags
build_global

install_nvm
install_node

install_sdkman
install_java
install_gradle
install_scala

#!/bin/bash
sudo apt-add-repository ppa:fish-shell/release-3;
sudo apt update;
sudo apt install \ 
   tree             \
   ninja-build      \
   gettext          \
   libtool          \
   libtool-bin      \
   autoconf         \
   automake         \
   cmake            \
   g++              \
   pkg-config       \
   unzip            \
   curl             \
   doxygen          \
   tmux             \
   fonts-powerline  \
   python3-pip      \
   ruby             \ 
   gem              \
   ruby-dev         \
   build-essential  \
   fish

sudo pip install --upgrade pynvim
sudo pip install powerline-shell
sudo gem install neovim

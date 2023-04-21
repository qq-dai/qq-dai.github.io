#!/bin/bash

set -e

export DEBIAN_FRONTEND="noninteractive"

function install {
  local user
  local home

  user=${SUDO_USER:-$USER}
  home=$(getent passwd "$user" | cut -d: -f6)

  apt-get update
  apt-get install -y git make

  # Fetch dotfiles
  pushd "$home" > /dev/null
    sudo -u "$user" mkdir -p Documents Downloads Work .tmp
    rm -rf Documents/dotfiles
    sudo -E -u "$user" git clone https://github.com/ojroques/dotfiles.git Documents/dotfiles
  popd > /dev/null

  # Install packages
  pushd "$home"/Documents/dotfiles > /dev/null
    make install-cli
    make clean
  popd > /dev/null

  # Remove old dotfiles
  pushd "$home" > /dev/null
    rm -rf .config/git
    rm -rf .config/nvim
    rm -rf .tmux.conf
    rm -rf .vimrc
    rm -rf .zshenv .config/zsh .local/share/zsh .local/state/zsh
  popd > /dev/null

  # Install dotfiles
  pushd "$home"/Documents/dotfiles > /dev/null
    sudo -u "$user" stow git nvim tmux vim zsh
  popd > /dev/null
}

install

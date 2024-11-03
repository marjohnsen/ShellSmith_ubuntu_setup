#!/bin/bash
//zsh

source utils/app_interface.sh

install_build_dependencies() {
  sudo apt update
  sudo apt install build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev \
    xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
}

install_pyenv() {
  rm -rf "$HOME/.pyenv"
  curl https://pyenv.run | bash
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
  pyenv update
}

install_latest_stable() {
  latest_stable=$(pyenv install --list | grep -E '^\s*3\.[0-9]+\.[0-9]+$' | tail -1 | xargs)
  pyenv install "$latest_stable"
  pyenv global "$latest_stable"
}

install_build_dependencies
install_pyenv
install_latest_stable

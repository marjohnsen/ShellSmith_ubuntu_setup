#!/bin/bash
// zsh python

source utils/app_interface.sh

error_exit() {
  echo "$1" >&2
  exit 1
}

cleanup() {
  rm -rf ~/build
}

install_dependencies() {
  sudo tee /etc/apt/sources.list.d/ubuntu.sources >/dev/null <<EOL
Types: deb deb-src
URIs: http://archive.ubuntu.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb deb-src
URIs: http://security.ubuntu.com/ubuntu/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOL

  sudo apt update -y

  sudo apt build-dep -y meson
  sudo apt build-dep -y ninja-build
  sudo apt build-dep -y wayland-protocols
  sudo apt build-dep -y wlroots
  sudo apt build-dep -y sway
  sudo apt build-dep -y waybar
  sudo apt build-dep -y mako-notifier

  sudo apt install -y \
    build-essential \
    debhelper \
    dh-make \
    wget \
    dmenu \
    wmenu \
    swayidle \
    swaybg \
    swaylock \
    grim \
    imagemagick \
    graphviz \
    xmlto \
    libgtkmm-3.0-dev \
    libxkbregistry-dev \
    libiniparser-dev \
    clang-tidy \
    libfftw3-dev \
    libxcb-util0-dev \
    libxcb-ewmh-dev \
    libxcb-xkb-dev \
    libxkbcommon-x11-dev \
    libxcb-cursor-dev \
    libxcb-xinerama0-dev \
    libxcb-keysyms1-dev \
    libstartup-notification0-dev \
    pkg-config \
    pandoc \
    cppcheck \
    ohcount \
    pulseaudio \
    pavucontrol
}

cleanup_source_install() {
  local name=$1
  sudo find /usr/local -type f -regextype posix-extended -regex ".*${name}.*" -exec rm -f {} \; || echo ""
  sudo find /usr/local -type d -regextype posix-extended -regex ".*${name}.*" -exec rm -rf {} \; || echo ""
  sudo rm -rf "/usr/local/include/${name}"
  sudo rm -rf "/usr/local/lib/pkgconfig/${name}.pc"
  sudo rm -rf "/usr/local/share/${name}"
  sudo rm -rf "/usr/local/bin/${name}"
}

prepare_build_dir() {
  local build_path=$1
  rm -rf "$build_path"
  mkdir -p "$build_path"
}

install_ninja_and_meson() {
  local ninja_build_path=~/build/ninja

  cleanup_source_install "ninja"
  cleanup_source_install "meson"

  prepare_build_dir "$ninja_build_path"

  wget -O "$ninja_build_path/ninja.zip" "https://github.com/ninja-build/ninja/releases/latest/download/ninja-linux.zip" || error_exit "ninja: Failed to download Ninja"
  unzip "$ninja_build_path/ninja.zip" -d "$ninja_build_path" || error_exit "ninja: Failed to unzip Ninja"
  sudo install -m 755 "$ninja_build_path/ninja" /usr/local/bin/ninja || error_exit "ninja: Failed to install Ninja"

  pipx install git+https://github.com/mesonbuild/meson.git || error_exit "meson: Failed to install Meson via pipx"
}

setup_swayfx() {
  mkdir -p "$HOME/.config/sway"
  mkdir -p "$HOME/.config/waybar"
  mkdir -p "$HOME/.config/rofi"
  mkdir -p "$HOME/.config/mako"

  safe_symlink "$PWD/dotfiles/sway/sway_config" "$HOME/.config/sway/config"
  safe_symlink "$PWD/misc/sway/wallpaper.jpg" "$HOME/.config/sway/wallpaper.jpg"
  safe_symlink "$PWD/misc/sway/lock_screen.sh" "$HOME/.config/sway/lockscreen.sh"

  safe_symlink "$PWD/dotfiles/waybar/waybar_config" "$HOME/.config/waybar/config"
  safe_symlink "$PWD/dotfiles/waybar/waybar_style.css" "$HOME/.config/waybar/style.css"
  safe_symlink "$PWD/misc/waybar" "$HOME/.config/waybar/scripts"

  safe_symlink "$PWD/misc/rofi" "$HOME/.config/rofi"

  safe_symlink "$PWD/dotfiles/mako" "$HOME/.config/mako/config"
}

install_dependencies
install_ninja_and_meson

mason_build_and_ninja_install "https://gitlab.freedesktop.org/mesa/drm.git"
mason_build_and_ninja_install "https://gitlab.freedesktop.org/wayland/wayland.git"
mason_build_and_ninja_install "https://gitlab.freedesktop.org/wayland/wayland-protocols.git"

mason_build_and_ninja_install "https://github.com/WillPower3309/swayfx.git 0.4" \
  "https://gitlab.freedesktop.org/wlroots/wlroots.git 0.17.1" \
  "https://github.com/wlrfx/scenefx.git 0.1"

mason_build_and_ninja_install "https://github.com/Alexays/Waybar.git"
mason_build_and_ninja_install "https://github.com/lbonn/rofi.git"

mason_build_and_ninja_install "https://github.com/emersion/mako"

setup_swayfx

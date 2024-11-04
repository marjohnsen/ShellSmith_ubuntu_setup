#!/bin/bash
// python

source utils/app_interface.sh

error_exit() {
  echo "$1" >&2
  exit 1
}

cleanup() {
  rm -rf ~/build
}

install_dependencies() {
  sudo apt update -y
  sudo apt install -y \
    sway \
    build-essential \
    git \
    wget \
    pkg-config \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    libvulkan-dev \
    libdrm-dev \
    libgbm-dev \
    libinput-dev \
    libxkbcommon-dev \
    libudev-dev \
    libpixman-1-dev \
    libpcre2-dev \
    libjson-c-dev \
    libpango1.0-dev \
    libcairo2-dev \
    libgdk-pixbuf-2.0-dev \
    wayland-protocols \
    scdoc \
    cmake \
    libffi-dev \
    libexpat1-dev \
    libcap-dev \
    python3-pip \
    python3-venv \
    libpciaccess-dev \
    seatd \
    libseat-dev \
    wl-clipboard \
    clang-tidy \
    gobject-introspection \
    libdbusmenu-gtk3-dev \
    libevdev-dev \
    libfmt-dev \
    libgirepository1.0-dev \
    libgtk-3-dev \
    libgtkmm-3.0-dev \
    libinput-dev \
    libjsoncpp-dev \
    libmpdclient-dev \
    libnl-3-dev \
    libnl-genl-3-dev \
    libpulse-dev \
    libsigc++-2.0-dev \
    libspdlog-dev \
    libwayland-dev \
    scdoc \
    upower \
    libxkbregistry-dev \
    dmenu \
    swayidle \
    swaybg \
    swaylock
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

build_and_install() {
  local repo_url=$1
  local git_tag=$2
  local build_path
  local name

  name=$(basename -s .git "$repo_url" | tr '_' '-')
  build_path=~/build/"$name"

  cleanup_source_install "$name"
  prepare_build_dir "$build_path"

  git clone --recurse-submodules "$repo_url" "$build_path" || error_exit "$name: Git clone failed"

  if [ -n "$git_tag" ]; then
    git -C "$build_path" checkout "$git_tag" || error_exit "$name: Failed to checkout tag $git_tag"
  fi

  git -C "$build_path" submodule update --init --recursive || error_exit "$name: Failed to update submodules"

  meson setup "$build_path/build" "$build_path" --prefix=/usr/local || error_exit "$name: Setup failed"
  ninja -C "$build_path/build" || error_exit "$name: Build failed"
  sudo ninja -C "$build_path/build" install || error_exit "$name: Install failed"
}

symlink_configs() {
  mkdir -p "$HOME/.config/sway"

  safe_symlink "$PWD/dotfiles/sway" "$HOME/.config/sway/config"
  safe_symlink "$PWD/dotfiles/i3/wallpaper.jpg" "$HOME/.config/sway/wallpaper.jpg"
}

install_dependencies
install_ninja_and_meson

build_and_install "https://gitlab.freedesktop.org/mesa/drm.git"
build_and_install "https://gitlab.freedesktop.org/wayland/wayland.git"
build_and_install "https://gitlab.freedesktop.org/wayland/wayland-protocols.git"

build_and_install "https://gitlab.freedesktop.org/wlroots/wlroots.git" "0.17.1" "-Dseatd=true"
build_and_install "git@github.com:wlrfx/scenefx.git" "0.1"
build_and_install "git@github.com:WillPower3309/swayfx.git" "0.4"
build_and_install "https://github.com/Alexays/Waybar.git"

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
    ifstat
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
  local main_repo_info="$1"
  shift
  local build_path name repo_url git_tag

  setup_repo() {
    local url="$1"
    local tag="$2"
    local path="$3"
    git clone --recurse-submodules "$url" "$path" || error_exit "$path: Git clone failed"
    if [ -n "$tag" ]; then
      git -C "$path" checkout "$tag" || error_exit "$path: Failed to checkout tag $tag"
    fi
    git -C "$path" submodule update --init --recursive || error_exit "$path: Failed to update submodules"
  }

  main_repo_url=$(echo "$main_repo_info" | awk '{print $1}')
  main_git_tag=$(echo "$main_repo_info" | awk '{print $2}')
  name=$(basename -s .git "$main_repo_url" | tr '_' '-')
  build_path=~/build/"$name"

  cleanup_source_install "$name"
  prepare_build_dir "$build_path"
  setup_repo "$main_repo_url" "$main_git_tag" "$build_path"

  while [ $# -gt 0 ]; do
    repo_url=$(echo "$1" | awk '{print $1}')
    git_tag=$(echo "$1" | awk '{print $2}')
    subproject_path="$build_path/subprojects/$(basename -s .git "$repo_url" | tr '_' '-')"
    prepare_build_dir "$subproject_path"
    setup_repo "$repo_url" "$git_tag" "$subproject_path"
    shift
  done

  meson setup "$build_path/build" "$build_path" --prefix=/usr/local || error_exit "$name: Setup failed"
  ninja -C "$build_path/build" -j2 || error_exit "$name: Build failed"
  sudo ninja -C "$build_path/build" install -j2 || error_exit "$name: Install failed"
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

build_and_install "https://gitlab.freedesktop.org/mesa/drm.git"
build_and_install "https://gitlab.freedesktop.org/wayland/wayland.git"
build_and_install "https://gitlab.freedesktop.org/wayland/wayland-protocols.git"

build_and_install "https://github.com/WillPower3309/swayfx.git 0.4" \
  "https://gitlab.freedesktop.org/wlroots/wlroots.git 0.17.1" \
  "https://github.com/wlrfx/scenefx.git 0.1"

build_and_install "https://github.com/Alexays/Waybar.git"
build_and_install "https://github.com/lbonn/rofi.git"

build_and_install "https://github.com/emersion/mako"

setup_swayfx

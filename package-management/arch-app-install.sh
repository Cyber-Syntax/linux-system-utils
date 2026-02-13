#!/usr/bin/env bash
# Copyright (c) 2026, Cyber-Syntax Serif
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#ARCH LINUX
#script to install my apps

packages=(
  # Essentials
  # pacman -Qqet to get all installed packages
  xorg-xinit
  xorg # for all xorg packages
  #rxvt-unicode # I don't thing this necessary
  xterm
  gtk4
  base
  base-devel
  fuse2
  grub
  htop
  linux-headers
  r8168 # for realtek ethernet
  rofi
  #terminator # I don't thing this necessary
  sh

  # Dark mode
  materia-gtk-theme
  lxappearance
  # gpu
  nvidia-open
  xf86-video-fbdev
  xf86-video-nouveau
  # TODO, need to check if these are needed
  xf86-video-qxl
  xf86-video-vesa

  #git,seahorse etc.
  gnome-keyring
  git
  wget
  curl
  unzip
  # audio
  pipewire
  pipewire-pulse
  rtkit # for pipewire
  # audio manager
  pavucontrol

  # misc
  fastfetch
  ## Fonts
  #nerd-fonts # all nerd fonts
  ttf-jetbrains-mono-nerd
  ttf-roboto-mono      # TODO: is it needed?
  ttf-roboto-mono-nerd # TODO: is it needed?
  noto-fonts           # fix fonts issues on some apps
  #noto-fonts-emoji  # noto-fonts already includes emojis
  # window manager
  qtile
  python-dbus-next
  picom
  playerctl
  feh
  dunst
  #swaybg # for wayland
  #lxpolkit # fedora only
  polkit # for arch

  # firewall
  ufw

  # terminal
  kitty
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
  # screenshot
  # TODO: is it needed for flameshot?
  xclip

  # file manager
  pcmanfm

  # web browser
  firefox
  openh264
  ffmpeg
  ffmpeg-libs
  #ungoogled-chromium # if needed
  #librewolf # maybe later

  #password manager
  keepassxc

  # text editor
  neovim
  vim

  # virtualization
  virt-manager
  libvirt

  # blue light filter
  gammastep

  # sync
  syncthing

  # backup
  #backintime # fedora only
  # backintime in aur maybe creating rsync is better
  borgbackup
)

#yay
yay_packages=(
  btrfs-assistant
  snapper-support
)

# pacman install packages
for package in "${packages[@]}"; do
  echo "Installing $package"
  # error handling
  if ! sudo pacman -S --noconfirm --needed "$package"; then
    echo "Error installing $package"
  else
    echo "$package installed"
  fi
done

# yay install packages
for yay_package in "${yay_packages[@]}"; do
  echo "Installing $yay_package"
  # error handling
  if ! yay -S --noconfirm --needed "$yay_package"; then
    echo "Error installing $yay_package"
  else
    echo "$yay_package installed"
  fi
done

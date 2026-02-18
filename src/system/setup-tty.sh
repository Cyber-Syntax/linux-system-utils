#!/usr/bin/env bash
#
# Configure large TTY font + Turkish keyboard layout
# Works on Fedora and Arch Linux (systemd based)
#
# On Fedora, console fonts are in /usr/lib/kbd/consolefonts/
# On Arch, console fonts are in /usr/share/kbd/consolefonts/

set -e

# CONFIGURATION (you can customize)
FONT="solar24x32" # large terminus font
KEYMAP="tr"       # Turkish keymap (use localectl list-keymaps to see more)

# Check root
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: Please run as root (sudo $0)"
  exit 1
fi

# Detect distro (very basic)
if [ -f /etc/fedora-release ]; then
  DISTRO="fedora"
elif [ -f /etc/arch-release ]; then
  DISTRO="arch"
else
  echo "Unsupported distro: only Fedora and Arch supported"
  exit 1
fi

echo "Detected distro: $DISTRO"
echo "Using font: $FONT"
echo "Using keymap: $KEYMAP"
echo

# Determine font directory
if [ "$DISTRO" = "fedora" ]; then
  FONTDIR="/usr/lib/kbd/consolefonts"
else
  FONTDIR="/usr/share/kbd/consolefonts"
fi

# Check that font file exists
if ! ls "$FONTDIR/${FONT}".psf* >/dev/null 2>&1; then
  echo "ERROR: Font $FONT not found in $FONTDIR"
  echo "Check available console fonts with:"
  echo "  ls $FONTDIR"
  exit 1
fi

# 1) Apply immediately (current console)
echo "Applying font & keymap immediately..."
setfont "$FONT"
loadkeys "$KEYMAP"

# 2) Write /etc/vconsole.conf for persistence
echo "Writing /etc/vconsole.conf..."
cat >/etc/vconsole.conf <<EOF
KEYMAP=$KEYMAP
FONT=$FONT
EOF

echo
echo "Done!"
echo "Reboot to fully apply changes permanently."

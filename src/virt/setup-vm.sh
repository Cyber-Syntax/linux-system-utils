#!/usr/bin/env bash
# Virtual Machine Useful Utilities
# Contains helpers for initial VM setup: timezone, keyboard layout and
# console fonts depending on detected distribution.

set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

detect_distro() {
    # Return lowercase ID from /etc/os-release or empty if unavailable
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        printf '%s' "${ID,,}"
    else
        printf ''
    fi
}

install_terminus() {
    # Install terminus console/font package appropriate for distro
    local distro
    distro=$(detect_distro)

    case "$distro" in
        arch)
            sudo pacman -S --noconfirm terminus-font
            ;;
        fedora)
            sudo dnf install -y terminus-fonts-console
            ;;
        *)
            echo "[warning] unsupported distro '$distro'; please install terminus manually" >&2
            ;;
    esac
}

setup_timezone_and_keyboard() {
    sudo timedatectl set-timezone Europe/Istanbul
    sudo localectl set-x11-keymap tr
}

setup_console_font() {
    # apply immediately and also ensure persistence via /etc/vconsole.conf
    sudo setfont ter-932b || true
    configure_vconsole
}

configure_vconsole() {
    # write vconsole settings so font and keymap survive reboots
    sudo tee /etc/vconsole.conf >/dev/null <<'EOF'
KEYMAP=trq
FONT=ter-932b
EOF
}

# ---------------------------------------------------------------------------
# Main entrypoint
# ---------------------------------------------------------------------------

main() {
    setup_timezone_and_keyboard
    install_terminus
    setup_console_font
}

main "$@"
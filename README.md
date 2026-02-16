# Linux System Utilities

A comprehensive collection of scripts and utilities for Linux desktop environments. These tools help manage and enhance your Linux experience across multiple system aspects.

## 📋 Overview

This repository contains practical utilities for system monitoring, package management, media control, power management, display configuration, backup solutions, and more. The tools are primarily written in shell script and Python, designed to be lightweight and easy to integrate into your workflow.

## 🗂️ Directory Structure

```
linux-system-utils/
├── audio/                 # Audio device management and media player control
├── backup/                # Backup utilities (borg, rsync)
├── containers/            # Container configurations and images
├── display/               # Screen layout and display configuration
├── general/               # General-purpose utilities and helpers
├── hardware/              # Hardware utilities (Bluetooth, etc.)
├── network/               # Network testing and Wake-on-LAN utilities
├── package-management/    # DNF, Flatpak and distro helpers
├── power/                 # Brightness, battery and power scripts
├── system/                # System information and maintenance
├── web-scrapping/         # Web scraping utilities and data
└── website/               # Website deploy / stow helpers
```

## 🚀 Key Features

- **Audio Management**: Control volume levels and audio devices, interact with media players
- **Package Management**: Utilities for DNF, Flatpak, and other package managers
- **Backup Solutions**: Automated scripts for Borg and rsync backups
- **Power Management**: Battery monitoring, brightness control, and power states
- **Display Configuration**: Screen layout management for various environments
- **System Information**: Storage status and system resource reporting

## 📦 Installation

Clone the repository to your local machine:

```bash
git clone https://github.com/cyber-syntax/linux-system-utils.git && cd linux-system-utils
```

Deploy the scripts using the bundled installer (`install.sh`). The installer sets file permissions, copies files to appropriate XDG locations (for example `~/.local/share/linux-system-utils`) and can install selected scripts into `~/.local/bin`.

Common usage examples:

```bash
./install.sh            # install to XDG locations (~/.local/share/linux-system-utils)
./install.sh --binary   # install selected scripts to ~/.local/bin
./install.sh --force    # overwrite an existing installation
./install.sh --help     # show installer options
```

You do not need to run `chmod` manually — `install.sh` handles permissions and deployment for you.

## 👥 Contributing

Contributions are welcome! Feel free to:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the BSD 3‑Clause License (BSD-3-Clause). See the `LICENSE` file for full text.

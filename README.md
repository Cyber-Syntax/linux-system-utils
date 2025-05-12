# Linux System Utilities

A comprehensive collection of scripts and utilities for Linux desktop environments. These tools help manage and enhance your Linux experience across multiple system aspects.

## 📋 Overview

This repository contains practical utilities for system monitoring, package management, media control, power management, display configuration, backup solutions, and more. The tools are primarily written in shell script and Python, designed to be lightweight and easy to integrate into your workflow.

## 🗂️ Directory Structure

```
linux-system-utils/
├── audio/             # Audio device management and media player control
├── backup/            # Backup utilities using Borg and rsync
├── containers/        # Container configuration files
├── display/           # Screen layout and display configuration
├── general/           # General-purpose utilities and configurations
├── hardware/          # Hardware management (e.g., Bluetooth)
├── network/           # Network testing and remote management
├── package-management/# Package managers (DNF, Flatpak, Arch)
├── power/             # Battery monitoring and power controls
└── system/            # System information and maintenance
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

Make scripts executable:

```bash
find . -name "*.sh" -exec chmod +x {} \;
```

## 👥 Contributing

Contributions are welcome! Feel free to:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the terms in the LICENSE file.

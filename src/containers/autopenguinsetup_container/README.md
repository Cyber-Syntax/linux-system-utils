# Auto-Penguin-Setup Development Containers

Multi-distro development containers for testing the auto-penguin-setup script across Fedora, Arch Linux, and Debian.

## What It's For

These containers provide isolated environments to test the auto-penguin-setup script on different Linux distributions without affecting your host system. Each container includes pre-installed tools and proper permissions for running the setup script.

## Features

- **Three Distros**: Fedora, Arch Linux, Debian
- **Source Code**: Copied into containers with proper ownership
- **Persistent Configs**: Separate volumes per distro for config isolation
- **Pre-installed Tools**: jq, shellcheck, shfmt, bats
- **User Setup**: `devuser` with passwordless sudo
- **AUR Helper**: Paru pre-installed on Arch
- **Pre-created Directories**: All system directories needed by the script

## Quick Start

### Build and Start Containers

```bash
cd container/
./manage.sh build all
```

### Open a Shell

```bash
./manage.sh shell fedora  # or arch, debian
```

### Run the Setup Script

Inside the container (already in `/home/devuser/auto-penguin-setup/`):

```bash
sudo ./setup.sh -h  # Help
sudo ./setup.sh -a  # Full setup
```

## Usage

### Building Containers

```bash
# Build all
./manage.sh build all

# Build specific
./manage.sh build fedora
./manage.sh build arch
./manage.sh build debian
```

### Accessing Containers

```bash
# Open shell
./manage.sh shell fedora

# Check status
./manage.sh status

# View logs
./manage.sh logs fedora
```

### Updating Source Code

After making changes on the host:

```bash
./manage.sh build fedora  # Rebuild to get latest source
```

### Testing Workflows

#### Fresh Installation Test

```bash
./manage.sh clean fedora
./manage.sh build fedora
./manage.sh shell fedora
sudo ./setup.sh -a  # Should prompt for config creation
```

#### Config Persistence Test

```bash
./manage.sh shell fedora
sudo ./setup.sh -a  # Creates config
exit
./manage.sh shell fedora
ls ~/.config/auto-penguin-setup/  # Config persists
```

#### Cross-Distro Testing

Open multiple terminals for each distro and run the same commands.

## Container Management

### Stop Containers

```bash
./manage.sh stop all
./manage.sh stop fedora
```

### Clean Everything

```bash
./manage.sh clean all  # Removes containers and volumes
```

### Volume Management

Configs are stored in named volumes:

- `container_fedora-config`
- `container_arch-config`
- `container_debian-config`

To backup configs:

```bash
# Inside container
tar -czf /tmp/config-backup.tar.gz -C ~/.config auto-penguin-setup

# From host
podman cp auto-penguin-fedora:/tmp/config-backup.tar.gz ./
```

## Container Specs

### Fedora Container

- **Base**: fedora:latest
- **Package Manager**: dnf
- **Pre-installed**: jq, shellcheck, shfmt, bats

### Arch Container

- **Base**: archlinux:latest
- **Package Manager**: pacman
- **AUR Helper**: paru
- **Pre-installed**: jq, shellcheck, shfmt, bats

### Debian Container

- **Base**: debian:latest
- **Package Manager**: apt
- **Pre-installed**: jq, shellcheck, shfmt, bats

## Security Notes

- Containers run as non-root user (`devuser`)
- Source code is copied (not mounted) to prevent corruption
- Configs are isolated in separate volumes
- NOPASSWD sudo for development convenience

## Credentials

- **Username**: devuser
- **Password**: test123 (rarely needed)

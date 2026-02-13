# AGENTS.md

This document provides context, patterns, and guidelines for AI coding assistants working in this repository.

## Project Overview

This project contains useful scripts that automate some personal and general Linux tasks via Python and Bash/Shell.

- Languages: Python 3.x and POSIX shell / Bash
- Purpose: Collection of small utilities and automation scripts for Linux system tasks

## Core Technologies

- **Python**: 3.12+ with type hints
- **BASH**: POSIX shell / Bash scripts for automation tasks
- **Linting**: ruff (linter + formatter) for python files
- **Type Checking**: mypy
- **Testing**: pytest, bats

## Setup Commands

- **Clone the repository**: `git clone https://github.com/cyber-syntax/linux-system-utils.git`
- **Install dependencies**: Ensure Python 3.12+ is installed. Use `uv` for dependency management if applicable (run `uv sync` if a `pyproject.toml` is present).
- **Deploy scripts**: Run `./install.sh` to install scripts to XDG base directories (e.g., `~/.local/share/linux-system-utils`).
- **Environment setup**: No additional environment variables required beyond standard XDG paths.

## Development Workflow

- Edit scripts in the `src/` directory.
- For Python scripts: Use `uv run` for commands like linting, type checking, and testing.
- For Bash scripts: Use `shellcheck` for linting and `shfmt` for formatting.
- No development server needed; scripts are standalone utilities.
- After changes, redeploy using `./install.sh --force` to update installed scripts.

## Testing Instructions

- **Python Testing**: Test only complex scripts/modules that require extensive testing.
    - Run specific test file: `uv run pytest tests/test_install.py`
    - Run specific test function: `uv run pytest tests/test_install.py::test_install_success`
- **Bash/Shell Testing**:
    - Check a single file: `shellcheck setup.sh`
    - Check all shell scripts: `find . -name "*.sh" -type f -exec shellcheck {} \;`
    - Check with specific severity: `shellcheck -S error setup.sh`

## Code Style Guidelines

### General Coding

- **Function Size**: Keep functions small and focused (<20 lines when possible)
- **KISS**: Keep it simple, stupid. Aim for simplicity and clarity. Avoid unnecessary abstractions or metaprogramming.
- **DRY Approach**:
    - Reuse existing abstractions; don't duplicate
    - Refactor safely when duplication is found
    - Check existing protocols before creating new ones

### Python Scripts

- **Type Annotations**: Use built-in types: `list[str]`, `dict[str, int]` (not `typing.List`, `typing.Dict`)
- **PEP 8**: Enforced by ruff
- **Datetime**: Use `astimezone()` for local time conversions
- **Variable Names**: Use descriptive, self-explanatory names
- **Functions**: Use functions over classes when state management is not needed
- **Pure Functions**: Prefer pure functions without side effects when possible

### Bash Scripts

- Prefer plain bash constructs and avoid unnecessary complexity.
- Use built-in bash features where appropriate, but avoid overusing them.

## Build and Deployment

- **Build**: No build process required; scripts are interpreted directly.
- **Deployment**: Use `./install.sh` to deploy to user directories. Options include `--main` for installing from main branch, `--force` to overwrite, `--binary` to install select scripts globally to `~/.local/bin`.
- **CI/CD**: No automated pipelines defined; manual testing and deployment.

## Repository Structure

```
install.sh
containers/
docs/
src
├── audio
│  ├── mediaplayer.py
│  ├── mediaplayer.sh
│  ├── sink-change.sh
│  └── volume-control.sh
├── automation
│  ├── add-missing-i18n-variables.js
│  ├── add-xml-missing-variables.py
│  ├── add_missing_i18n_variables.py
│  ├── clean-sp-backups.sh
│  ├── coding_workflow.sh
│  ├── copy-repos-to-vm.sh
│  ├── rename_spaces.sh
│  └── write-missing-variables-tr.js
├── backup
│  ├── basic-rsync
│  │  ├── exclude_files.txt
│  │  ├── main.bash
│  │  └── test.bash
│  ├── borg-backup
│  │  ├── home-borgbackup.sh
│  │  ├── laptop-boot_borgbackup.sh
│  │  └── laptop-home_borgbackup.sh
│  ├── rsync-desktop-to-laptop.sh
│  └── rsync-laptop-to-desktop.sh
├── containers
│  ├── adventureland
│  │  └── docker-compose.yml
│  ├── autopenguinsetup_container
│  │  ├── Dockerfile.arch
│  │  ├── Dockerfile.debian
│  │  ├── Dockerfile.fedora
│  │  ├── manage.sh
│  │  ├── podman-compose.yml
│  │  └── README.md
│  ├── dev_environment
│  │  └── docker-compose.yml
│  ├── label-studio
│  │  └── docker-compose.yml
│  └── Qdrant
│     └── docker-compose.yml
├── display
│  ├── arandr_new.sh
│  ├── asus_only.sh
│  ├── laptop-xrandr.sh
│  ├── tv-xrandr.sh
│  ├── two_mon.sh
│  ├── xrandr-movie.sh
│  └── xrandr-root.sh
├── games
│  └── fs_mod_move.sh
├── general
│  ├── autologin.conf
│  ├── remove-html-tag.py
│  ├── sha512_sum.sh
│  ├── skip-prompt.conf
│  ├── write_file.py
│  └── write_file.sh
├── github
│  ├── changelog.sh
│  ├── copy-dot-github.sh
│  ├── copy_agents.sh
│  ├── data
│  │  ├── AGENTS_bash.md
│  │  ├── AGENTS_python.md
│  │  ├── another_AGENTS.md
│  │  ├── last_my_unicorn_agents.md
│  │  ├── my_unicorn_latest_pyproject.toml
│  │  ├── new_AGENTS.md
│  │  ├── pyproject.toml
│  │  ├── pyproject_aps.toml
│  │  ├── pyproject_aps2.toml
│  │  └── pyproject_my_unicorn.toml
│  ├── prune-local-branch.sh
│  ├── pull_specific_branch_specific_folder.sh
│  └── remove_cache.sh
├── hardware
│  ├── bluetooth-menu.sh
│  └── bluetooth_devices.sh
├── network
│  ├── network_test.sh
│  ├── poweroff_fedora.sh
│  ├── wake_fedora.sh
│  └── wakeonlan.wol
├── package-management
│  ├── arch-app-install.sh
│  ├── arch-package-manager.sh
│  ├── fedora-package-manager.sh
│  └── fwupd.sh
├── power
│  ├── brightness-control.sh
│  ├── check_battery.sh
│  ├── idle.sh
│  ├── power-menu.sh
│  ├── swaylock.sh
│  └── swaylock_sleep.sh
├── system
│  ├── info
│  │  ├── cpu_mem_info.sh
│  │  ├── date_time.sh
│  │  └── storage.sh
│  ├── maintenance
│  │  └── gc_cache.sh
│  └── setup-tty.sh
├── web-scrapping
│  ├── docs.astral.sh
│  │  └── #creating-a-python-script.md
│  ├── docs.pytest.org
│  │  └── pythonpath.html#import-modes.md
│  ├── docs.python.org
│  │  └── logging-cookbook.html#.md
│  └── scrap.py
└── website
   └── stow.sh
```

## Python Linting/Formatting

**CRITICAL**: Always run ruff on modified python files before committing.

```bash
# 1. Make your changes to files in src/

# 2. Run linting (auto-fix issues)
ruff check --fix path/to/file.py
ruff check --fix . # or all Python files

# 3. Run formatting
ruff format path/to/file.py
ruff format . # or all Python files

# 4. Run type checking
uv run mypy src/

# 5. Run fast tests
uv run pytest /path/to/file.py
```

## Bash/Shell Formatting

```bash
# Format a file (in-place)
shfmt -w setup.sh

# Format all shell scripts
find . -name "*.sh" -type f -exec shfmt -w {} \;

# Format options used in this project:
# -i 2    : indent with 2 spaces
# -ci     : indent switch cases
# -bn     : binary ops like && and | may start a line
shfmt -i 2 -ci -bn -w setup.sh
```

## Pull Request Guidelines

- Ensure all linting, formatting, type checking, and tests pass before submitting.
- Title format: [category] Brief description (e.g., [audio] Fix volume control script).
- Required checks: Run `ruff check --fix`, `ruff format`, `uv run mypy src/`, `uv run pytest`, `shellcheck`, and `shfmt` on relevant files.

## Additional Notes

- This is a collection of personal automation scripts; contributions are welcome but focus on Linux system utilities.
- For debugging, add logging statements to scripts and test manually.
- Security: Scripts may require system permissions; review for safe execution.

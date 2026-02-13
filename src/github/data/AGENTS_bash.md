- [ ] Make this bash general agents.md
- [ ] after became general good for bash projects, keep it example template in this.

  ## EXAMPLE, change according to your needs

# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## General Guidelines

1. KISS (Keep It Simple, Stupid): Aim for simplicity and clarity. Avoid unnecessary abstractions or metaprogramming.
2. DRY (Don't Repeat Yourself): Reuse code appropriately but avoid over-engineering. Each command handler has single responsibility.
3. YAGNI (You Aren't Gonna Need It): Always implement things when you actually need them, never when you just foresee that you need them.
4. **ALWAYS** use `ruff check <filepath>` on each python file you modify to ensure proper formatting and linting.
    - Use `ruff format <filepath>` on each python file you modify to ensure proper formatting.
    - Use `ruff check --fix <filepath>` on each python file you modify to fix any fixable errors.
4. **ALWAYS** use `shellcheck` on each file you modify to ensure proper formatting and linting. This runs both syntax and lint checks on individual files. Unless you want to lint and format multiple files, then use `shellcheck -f` and `shellcheck -l` instead.
5. When creating bash scripts, prefer plain bash constructs and avoid unnecessary complexity. Keep functions small and focused. Use built-in bash features where appropriate, but avoid overusing them.

## Testing Instructions

Critical: Run tests after any change to ensure nothing breaks.

```bash
# Always activate venv before testing:
source .venv/bin/activate

# Run all tests:
pytest -v -q --strict-markers

# Run specific test file:
pytest tests/test_config.py -v

# Run specific test function:
pytest tests/test_config.py::test_function_name -v
```

## Linting and Formatting

### ShellCheck

```bash
# Check a single file
shellcheck setup.sh

# Check all shell scripts
find . -name "*.sh" -type f -exec shellcheck {} \;

# Check with specific severity (error, warning, info, style)
shellcheck -S error setup.sh

```

### shfmt

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

## Code Style Guidelines

Style Rules:

- Follow PEP 8 strictly
- Max line length: 79 characters

Type Annotations:

- Use built-in types: `list[str]`, `dict[str, int]` (not `List`, `Dict`)
- Use `from typing import TYPE_CHECKING` for imports only used in type hints

Logging:

- Use `%s` style formatting in logging: `logger.info("Message: %s", value)`
- Never use f-strings in logging statements

## Project Overview

auto-penguin-setup is a cross-distribution Linux system setup automation tool written in Bash. It automates installation and configuration across arch linux, fedora, debian with intelligent distribution detection and package name mapping.

### Key Technologies

- Bash 4.5+ (primary language)
- INI configuration (using the project's INI parser `src/core/ini_parser.sh`). See `docs/architecture/config.arch.md` for the canonical INI schema and examples.
- BATS (Bash Automated Testing System)
- Multiple package managers: dnf/copr (Fedora), pacman/paru (Arch), apt/deb (Debian/Ubuntu)

## Setup Commands

### Running the Setup
>
> Never run setup.sh as root directly, script handles sudo internally.

```bash
# Show help and available options
./setup.sh -h
```

## Development Workflow

### Module Loading Order

**CRITICAL**: Modules must be sourced in strict dependency order:

1. `src/core/logging.sh` - **ALWAYS FIRST** (provides logging functions)
2. `src/core/distro_detection.sh` - Detects distribution
3. `src/core/package_mapping.sh` - Sets up package name mappings (required by package_manager)
4. `src/core/package_manager.sh` - Initializes package manager abstraction
5. `src/core/repository_manager.sh` - Repository management
6. `src/core/config.sh` - Loads user configurations
7. `src/core/install_packages.sh` - Package installation wrapper
8. Feature modules (apps/system/hardware/display/wm) - **Order doesn't matter**

### Working with Core Modules

**DO NOT** modify core module loading order in `setup.sh`. The order is critical for functionality.

**When adding to core modules**:

- Add source guards: `[[ -n "${_MODULENAME_SOURCED:-}" ]] && return 0`
- Use logging functions (after logging.sh is loaded)
- Follow abstraction patterns - no distribution-specific code outside core

### File Organization

- Keep related functionality together in categorical directories
- One primary feature per module file
- Helper functions can stay in the same file if they're only used there
- Share common utilities through core modules, not by copying code
- Extract complex logic into dedicated functions for better modularity and reusability

### Abstraction Rules

**NEVER write distribution-specific code outside core modules**:

❌ Wrong:

```bash
if [[ "$DETECTED_DISTRO" == "fedora" ]]; then
  sudo dnf install package
elif [[ "$DETECTED_DISTRO" == "arch" ]]; then
  sudo pacman -S package
fi
```

✅ Correct:

```bash
pm_install "package"  # Handles all distributions automatically
```

**Use abstraction functions**:

- `pm_install <package>` - Install packages
- `pm_remove <package>` - Remove packages
- `pm_search <package>` - Search for packages
- `pm_update` - Update package database
- `pm_upgrade` - Upgrade all packages
- `repo_add <repo>` - Add repository (COPR/AUR/PPA)
- `map_package <generic_name>` - Get distro-specific package name

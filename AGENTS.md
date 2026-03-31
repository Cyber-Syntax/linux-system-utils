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

## Repository Structure

```
install.sh
containers/
docs/
src
├── audio                                   # Audio-related scripts
│  ├── mediaplayer.py
│  ├── mediaplayer.sh
│  ├── sink-change.sh
│  └── volume-control.sh
├── automation                              # General automation scripts                 
│  ├── add-missing-i18n-variables.js
│  ├── add-xml-missing-variables.py
│  ├── copy-repos-to-vm.sh
├── backup                                  # Backup-related scripts
│  ├── borg-backup
│  │  ├── home-borgbackup.sh
│  ├── rsync-desktop-to-laptop.sh
│  └── rsync-laptop-to-desktop.sh
├── containers                              # Container-related scripts and configurations
│  ├── autopenguinsetup_container
│  │  ├── Dockerfile.arch
│  │  ├── Dockerfile.fedora
│  │  ├── manage.sh
│  │  ├── podman-compose.yml
├── display                                 # Display configuration scripts 
│  ├── laptop-xrandr.sh
├── games                                   # Game-related scripts
│  └── fs_mod_move.sh
├── general                                 # General utility scripts
│  ├── remove-html-tag.py
│  ├── sha512_sum.sh
├── github                                  # GitHub-related scripts and data 
│  ├── changelog.sh
│  ├── data
│  │  ├── AGENTS_bash.md
│  │  ├── AGENTS_python.md
│  │  ├── pyproject.toml
├── hardware                                # Hardware-related scripts
│  ├── bluetooth-menu.sh
├── network                                 # Network-related scripts
│  ├── network_test.sh
│  └── wakeonlan.wol
├── package-management                      # Package management scripts for various distros
│  ├── arch-package-manager.sh
│  ├── fedora-package-manager.sh
├── power                                   # Power management and related scripts
│  ├── brightness-control.sh
│  ├── check_battery.sh
│  ├── idle.sh
│  ├── power-menu.sh
│  ├── swaylock.sh
│  └── swaylock_sleep.sh
├── system                                  # System information and maintenance scripts
│  ├── info
│  │  ├── cpu_mem_info.sh
│  ├── maintenance
│  │  └── gc_cache.sh
│  └── setup-tty.sh
├── web-scrapping                           # Web scraping scripts 
│  └── scrap.py
└── website                                 # Personal website-related scripts and configurations
   └── stow.sh
```

## Setup Commands

- **Clone the repository**: `git clone https://github.com/cyber-syntax/linux-system-utils.git`
- **Install dependencies**: Ensure Python 3.12+ is installed. Use `uv` to start python scripts.
- **Deploy scripts**: Run `./install.sh` to install scripts to XDG base directories (e.g., `~/.local/share/linux-system-utils`).
- **Environment setup**: No additional environment variables required beyond standard XDG paths.

## Development Workflow

- Edit scripts in the `src/` directory.
- For Python scripts: Use `uv run` for commands like linting, type checking, and testing.
- For Bash scripts: Use `shellcheck` for linting and `shfmt` for formatting.
- No development server needed; scripts are standalone utilities.
- After changes, redeploy using `./install.sh --force` to update installed scripts.

## Code Style Guidelines

### General Coding

- **Function Size**: Keep functions small and focused (<20 lines when possible)
- **KISS**: Keep it simple, stupid. Aim for simplicity and clarity. Avoid unnecessary abstractions or metaprogramming.
- **DRY Approach**:
    - Reuse existing abstractions; don't duplicate
    - Refactor safely when duplication is found
    - Check existing protocols before creating new ones

### Python Scripts

- **Type Annotations**: Always use built-in generic types instead of `typing` equivalents:
    - Use `list[str]` not `List[str]` (from typing)
    - Use `X | None` not `Optional[X]` (from typing)
    - Only import from `typing` when absolutely necessary (e.g., `Any`, `Union` for complex cases)
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

## Testing Instructions

### Test Folder Structure Principles

```
tests/                             
├── py/                     # Python tests
├── sh/                     # Shell/Bash tests
├── custom/                 # Custom tests (e.g., GitHub Action CI test, line count test)
```

### Writing Tests

**CRITICAL**: Every new feature or bugfix MUST be covered by unit tests.

```python
# Example test structure
import pytest
from unittest.mock import AsyncMock, MagicMock, patch

from my_unicorn.core.services import InstallWorkflow
from my_unicorn.exceptions import VerificationError


@pytest.mark.asyncio
async def test_install_workflow_success(tmp_path, mock_session):
    """Test successful installation workflow."""
    # Arrange
    workflow = InstallWorkflow(...)

    # Act
    result = await workflow.execute()

    # Assert
    assert result.success is True
    assert result.app_name == "test-app"


def test_hash_verification_failure():
    """Test that verification fails with incorrect hash."""
    # Arrange
    expected_hash = "abc123"
    actual_hash = "def456"

    # Act & Assert
    with pytest.raises(VerificationError):
        verify_hash(actual_hash, expected_hash)
```

```bash
#!/usr/bin/env bats

@test "addition using bc" {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 4 ]
}

@test "addition using dc" {
  result="$(echo 2 2+p | dc)"
  [ "$result" -eq 4 ]
}
```

### Running Tests

```bash
# Run fast tests only (excludes slow logger integration tests)
uv run pytest -m "not slow"

# Run all tests (including slow tests)
uv run pytest

# Run tests with coverage
uv run pytest --cov=my_unicorn --cov-report=html

# Run specific test file
uv run pytest tests/test_install.py

# Run specific test function
uv run pytest tests/test_install.py::test_install_success

# Run shell tests with bats
bats tests/sh/

# Run specific shell test file
bats tests/sh/test_network.sh

# Run subdirectory recursively via bats
bats -r tests/sh/network/
```

### Test Checklist

Before committing, verify:

- [ ] Tests fail when your new logic is broken
- [ ] Happy path is covered
- [ ] Edge cases and error conditions are tested
- [ ] External dependencies are mocked (no real network calls in unit tests)
- [ ] Tests are deterministic (no flaky tests)
- [ ] Test names clearly describe what they test

## Debugging and Troubleshooting

### Common Issues and Solutions

#### Linting/Formatting Issues

```bash
# Problem: Ruff errors that can't be auto-fixed
# Solution: Review ruff output and fix manually
ruff check path/to/file.py

# Problem: Type checking errors
# Solution: Run mypy with verbose output
uv run mypy --show-error-codes src/my_unicorn/

# Problem: Shellcheck errors in bash scripts
# Solution: Run shellcheck and fix manually
shellcheck path/to/script.sh

# Common type error fixes:
# - Update type hints to match actual usage
# - Check for missing return type annotations
# - Ensure correct use of built-in types (list[str], dict[str, int], etc.)
```

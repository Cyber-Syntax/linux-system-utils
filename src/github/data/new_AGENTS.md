# AGENTS.md

This document provides context, patterns, and guidelines for AI coding assistants
working in this repository.

## Project Overview

My Unicorn is a Python 3.12+ CLI tool for managing AppImages on Linux. It installs, updates, and verifies AppImages from GitHub with hash verification (SHA256/SHA512).

## General Guidelines

- **KISS** (Keep It Simple, Stupid): Aim for simplicity and clarity. Avoid unnecessary abstractions or metaprogramming.
- **DRY** (Don't Repeat Yourself): Reuse code appropriately but avoid over-engineering. Each command handler has single responsibility.
- **YAGNI** (You Aren't Gonna Need It): Always implement things when you actually need them, never when you just foresee that you need them.

## Project Philosophy: The Zen of Python

The following principles from the Zen of Python guide our development approach:

> Beautiful is better than ugly.
> Explicit is better than implicit.
> Simple is better than complex.
> Complex is better than complicated.
> Flat is better than nested.
> Sparse is better than dense.
> Readability counts.
> Special cases aren't special enough to break the rules.
> Although practicality beats purity.
> Errors should never pass silently.
> Unless explicitly silenced.
> In the face of ambiguity, refuse the temptation to guess.
> There should be one-- and preferably only one --obvious way to do it.
> Now is better than never.
> Although never is often better than *right* now.
> If the implementation is hard to explain, it's a bad idea.
> If the implementation is easy to explain, it may be a good idea.
> Namespaces are one honking great idea -- let's do more of those!

### How We Apply These Principles

- **Readability**: We prioritize clear, understandable code over clever or overly complex solutions.
- **Explicitness**: Our code aims to be self-documenting, with clear type hints and docstrings.
- **Simplicity**: We break down complex problems into simpler, manageable components.
- **Pragmatism**: We balance theoretical purity with practical implementation needs.

## Development tools & commands

- `uv` – Fast Python package installer and resolver (replaces pip/poetry)
- `ruff` – Fast Python linter and formatter
- `mypy` – Static type checking
- `pytest` – Testing framework

## Key Technologies

- Python 3.12 and above version with asyncio/aiohttp for async operations
- aiohttp - Async HTTP client for GitHub API interactions
- orjson - Fast JSON library for config and cache files
- uvloop - Fast asyncio event loop
- keyring - Secure credential storage for GitHub tokens

## Key config files

- pyproject.toml: Main workspace configuration with dependency groups
- uv.lock: Locked dependencies for reproducible builds

## Repository Structure

```
src/my_unicorn/
├── main.py                      # Application entry point
├── types.py                     # Type definitions and dataclasses
├── constants.py                 # Application constants (versions, paths, defaults)
├── exceptions.py                # Custom exception classes
├── logger.py                    # Logging setup and configuration
├── catalog/                     # Application catalog JSON files (neovim.json, qownnotes.json, etc.)
├── cli/                         # CLI argument parsing and command runners
│   ├── parser.py                # Argument parser setup
│   ├── runner.py                # Command execution orchestration
│   └── commands/                # Individual command handlers (install, update, remove, list, etc.)
├── config/                      # Configuration management
│   ├── global.py                # Global INI configuration
│   ├── app.py                   # Per-app JSON configuration
│   ├── catalog.py               # Application catalog loader
│   ├── schemas/                 # JSON schema validation
│   └── migration/               # Configuration migration logic
├── core/                        # Core functionality and integrations
│   ├── auth.py                  # Authentication handling
│   ├── token.py                 # Token storage and retrieval
│   ├── cache.py                 # Release cache management
│   ├── http_session.py          # HTTP session management
│   ├── file_ops.py              # File system operations
│   ├── download.py              # File download logic
│   ├── icon.py                  # Icon extraction and management
│   ├── desktop_entry.py         # Desktop file generation
│   ├── remove.py                # Remove operations
│   ├── backup.py                # Backup operations
│   ├── protocols/               # Protocol definitions
│   ├── github/                  # GitHub API client
│   ├── verification/            # Hash verification logic (SHA256/SHA512)
│   └── workflows/               # Business workflows (install, update, remove)
├── ui/                          # User interface and display
│   ├── progress.py              # Progress bar management
│   ├── display.py               # Output formatting and rendering
│   └── formatters.py            # Text formatters
└── utils/                       # Utility functions and helpers

tests/                           # Comprehensive test suite (mirrors src/my_unicorn/ structure)
docs/                            # Documentation and design decisions
scripts/                         # Helper scripts for development
autocomplete/                    # Shell autocomplete scripts (bash, zsh)
container/                       # Container configuration (Dockerfile, podman-compose.yml)
```

## Development Workflow

### Core development principles

- Use built-in types: `list[str]`, `dict[str, int]` (not typing.List, typing.Dict)
- Use `%s` style formatting in logging statements
- Follow PEP 8 standards (enforced by ruff)
- Use `astimezone()` for local time in datetime operations

### Code quality standards

All Python code MUST include type hints and return types.

```python title="Example"
def filter_unknown_users(users: list[str], known_users: set[str]) -> list[str]:
    """Single line description of the function.

    Any additional context about the function can go here.

    Args:
        users: List of user identifiers to filter.
        known_users: Set of known/valid user identifiers.

    Returns:
        List of users that are not in the `known_users` set.
    """
```

- Use descriptive, self-explanatory variable names.
- Follow existing patterns in the codebase you're modifying
- Attempt to break up complex functions (>20 lines) into smaller, focused functions where it makes sense

### Error Handling

- Use custom exceptions from `exceptions.py`
- Do not use `logger.exception()` for expected errors (e.g., network issues, invalid user input) and secure data (e.g., tokens) to avoid leaking sensitive information.
- Handle network errors gracefully with retries

### Linting and Formatting

CRITICAL: ALWAYS run ruff on each Python file you modify:

```bash
# Check and auto-fix linting errors
ruff check --fix path/to/file.py

# Check and auto-fix all files in a directory
ruff check --fix .

# Format a specific file
ruff format path/to/file.py

# Format all files in a directory
ruff format path/to/code/

# Format all files in current directory
ruff format .
```

### File Organization

Keep files between 150-500 lines:

1. Run: uv pytest tests/test_lines.py -v
2. If tests fail, refactor large files into smaller modules
3. Find natural split points - don't force arbitrary divisions
4. Re-run tests until they pass
Current results: {test_output}

### Running the CLI

```bash
# Run via uv
uv run my-unicorn <command> [options]

# Example
uv run my-unicorn install qownnotes
```

### Making Code Changes

1. Make your changes to files in `src/my_unicorn/`
2. Run linting: `ruff check --fix <filepath>`
3. Run formatting: `ruff format <filepath>`
4. Run tests: `uv run pytest -m 'not slow'` (see Testing Instructions below)
5. Verify CLI still works: `uv run my-unicorn --help`
6. Verify ui still work as expected: `uv run scripts/test.py --quick`

### Adding New Dependencies

```bash
# Add a dependency
uv add <package-name>

# Add a dev dependency
uv add --dev <package-name>

# Update all dependencies
uv lock --upgrade
```

## Testing Instructions

CRITICAL: Every new feature or bugfix MUST be covered by unit tests.

```bash
# Run full test (Include slow logger integration test)
uv run pytest

# Run fast test
uv run pytest -m "not slow"
```

- Unit tests: `tests/` (no network calls allowed)
- Integration tests: `tests/integration/` (network calls permitted)
- We use `pytest` as the testing framework; if in doubt, check other existing tests for examples.
- The testing file structure should mirror the source code structure.

Note: The `slow` marker is applied to performance-heavy tests (e.g., 10MB log file rotation). Integration tests in `tests/integration/` are marked with `integration` but may not be slow—use `-m "not slow"` for quick runs that include fast integration tests. Skip integration tests entirely if changes don't affect config, upgrade, or cross-component interactions.

**Checklist:**

- [ ] Tests fail when your new logic is broken
- [ ] Happy path is covered
- [ ] Edge cases and error conditions are tested
- [ ] Use fixtures/mocks for external dependencies
- [ ] Tests are deterministic (no flaky tests)
- [ ] Does the test suite fail if your new logic is broken?

### Security and risk assessment

- No `eval()`, `exec()`, or `pickle` on user-controlled input
- Proper exception handling (no bare `except:`) and use a `msg` variable for error messages
- Remove unreachable/commented code
- Race conditions or resource leaks (file handles, sockets, threads).
- Ensure proper resource cleanup (file handles, connections)

### Documentation standards

- Focus on "why" rather than "what" in descriptions
- Document all parameters, return values, and exceptions
- Keep descriptions concise but clear
- Ensure American English spelling (e.g., "behavior", not "behaviour")

## Build and Deployment

### Running Locally (Development)

```bash
# Run from source without installation
uv run my-unicorn <command>
```

### Installation Methods

```bash
# Install from GitHub (main branch, for production use)
uv tool install git+https://github.com/Cyber-Syntax/my-unicorn
./install.sh -i

# Upgrade to latest from GitHub
my-unicorn upgrade
uv tool install --upgrade git+https://github.com/Cyber-Syntax/my-unicorn
```

## Review Checklist

- [ ] Code follows KISS, DRY, and YAGNI principles
- [ ] All tests pass (`uv run pytest`)
- [ ] Code is formatted (`ruff format`)
- [ ] No linting errors (`ruff check`)
- [ ] No unnecessary dependencies added
- [ ] Exception handling follows Ruff guidelines (TRY003, TRY301)
- [ ] No assert statements used (S100)

## Project-Specific Notes

### Configuration Structure

- Configuration stored in `~/.config/my-unicorn/`:
  - `settings.conf` - Global configuration file (GLOBAL_CONFIG_VERSION="1.1.0")
  - `cache/releases/` - Cache files, filtered for AppImage/checksums only (Windows, mac removed)
    - `AppFlowy-IO_AppFlowy.json` - AppFlowy cache config
    - `zen-browser_desktop.json` - Zen Browser cache config
  - `logs/` - Log files for my-unicorn
  - `apps/` - AppImages state data folder (APP_CONFIG_VERSION="2.0.0")
    - `appflowy.json` - AppFlowy app config
    - `zen-browser.json` - Zen Browser app config
    - `backups/` - Config backups created during migration

### AppImage Management

- AppImages are downloaded to user-specified directory
- Desktop entries are created in `~/.local/share/applications/`
- Icons are extracted from AppImages and stored to user-specified directory
  - Default `~/Applications` for appimages, backups, and icons
- Hash verification (SHA256/SHA512) is performed on available assets

### GitHub API Interaction

- All GitHub API calls go through `core/github/`
- Release data is cached in `core/cache.py` to reduce API calls
- Cache invalidation happens on update commands
- Asset filtering removes non-Linux assets to reduce cache size
- Authentication tokens stored securely via `core/token.py` using system keyring
- Authentication is implemented via `core/auth.py` module

### Configuration Migration

- Migrations are detected and notified on startup
- Backups are created in `~/.config/my-unicorn/apps/backups/`
- Migration logic is in `config/migration/` directory
  - `global_config.py` - Global INI config migrations
  - `app_config.py` - Per-app JSON config migrations
- Always bump VERSION constants in `constants.py` when changing config schema
  - `GLOBAL_CONFIG_VERSION` - Currently "1.1.0"
  - `APP_CONFIG_VERSION` - Currently "2.0.0"

## Additional Resources

- **Documentation:** See `docs/` directory for detailed design decisions, architecture diagrams, and API documentation
- **Scripts:** Helper scripts in `scripts/` for development tasks

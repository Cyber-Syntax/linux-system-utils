# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Project Overview

This repository contains various scripts and utilities implemented in Python and Bash.

## General Guidelines

1. KISS (Keep It Simple, Stupid): Aim for simplicity and clarity. Avoid unnecessary abstractions or metaprogramming.
2. DRY (Don't Repeat Yourself): Reuse code appropriately but avoid over-engineering. Each command handler has single responsibility.
3. YAGNI (You Aren't Gonna Need It): Always implement things when you actually need them, never when you just foresee that you need them.
4. **ALWAYS** use `ruff check <filepath>` on each python file you modify to ensure proper formatting and linting.
    - Use `ruff format <filepath>` on each python file you modify to ensure proper formatting.
    - Use `ruff check --fix <filepath>` on each python file you modify to fix any fixable errors.
5. **ALWAYS** use `shellcheck` on each file you modify to ensure proper formatting and linting. This runs both syntax and lint checks on individual files. Unless you want to lint and format multiple files, then use `shellcheck -f` and `shellcheck -l` instead.
6. When creating bash scripts, prefer plain bash constructs and avoid unnecessary complexity. Keep functions small and focused. Use built-in bash features where appropriate, but avoid overusing them.

## Python Testing Instructions

- Test only complex scripts/modules that require extensive testing on Python.

```bash
# Run specific test file:
pytest tests/test_config.py -v

# Run specific test function:
pytest tests/test_config.py::test_function_name -v
```

## Bash/Shell Testing Instructions

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

## Project Overview

This project is contains a useful scripts that automate some personal and general Linux tasks via Python and Bash/Shell.

- Languages: Python 3.x and POSIX shell / Bash
- Purpose: Collection of small utilities and automation scripts for Linux system tasks

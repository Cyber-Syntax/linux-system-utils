# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Project Overview

This repository contains various scripts and utilities implemented in Python and Bash.

## General Guidelines

1. KISS Principle: Aim for simplicity and clarity. Avoid unnecessary abstractions or metaprogramming.
2. DRY with Care: Reuse code appropriately but avoid over-engineering. Each command handler has single responsibility.

## Python Testing

1. Always use .venv for testing to ensure dependencies are isolated.

```bash
python3 -m venv .venv
```

1. Activate venv before any test execution:

```bash
source .venv/bin/activate
```

2. Run pytest with following command to ensure all tests pass:

```bash
pytest <file>.py
```

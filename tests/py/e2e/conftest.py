"""Pytest configuration for e2e tests."""

import sys
from pathlib import Path

# Ensure the repo root is on sys.path so ``from src.migration.md_to_org import …``
# works inside the e2e tests (same as the unit-test conftest).
_REPO_ROOT = Path(__file__).parent.parent.parent.parent
sys.path.insert(0, str(_REPO_ROOT))


import pytest  # noqa: E402


@pytest.fixture(scope="session")
def repo_root() -> Path:
    """Absolute path to the repository root."""
    return _REPO_ROOT


@pytest.fixture(scope="session")
def fixtures_dir() -> Path:
    """Path to ``tests/fixtures/markdown-todos/``."""
    return _REPO_ROOT / "tests" / "fixtures" / "markdown-todos"


@pytest.fixture(scope="session")
def comprehensive_md_path(fixtures_dir: Path) -> Path:
    """Path to the comprehensive.md fixture."""
    return fixtures_dir / "comprehensive.md"

"""Pytest configuration: add the workspace root to sys.path."""

import sys
from pathlib import Path

# Allow ``from src.migration.md_to_org import …`` in tests.
# Insert repo root (two levels up from tests/py/) so that
# ``from src.migration.md_to_org import …`` resolves correctly.
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

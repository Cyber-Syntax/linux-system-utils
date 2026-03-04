"""End-to-end tests for src/migration/md_to_org.py.

Each test reads real fixture files from ``tests/fixtures/markdown-todos/``
and writes converted output to ``tmp_path`` (a fresh temporary directory
provided by pytest).  No files are written to the fixtures directory itself.
"""

import subprocess
import sys
from pathlib import Path

from src.migration.md_to_org import convert_directory, convert_markdown

# ---------------------------------------------------------------------------
# comprehensive.md – covers all feature combinations
# ---------------------------------------------------------------------------


def test_e2e_comprehensive_conversion(
    comprehensive_md_path: Path, tmp_path: Path
) -> None:
    """Convert comprehensive.md and verify all feature areas in the output."""
    org_text = convert_markdown(
        comprehensive_md_path.read_text(),
        source_filename=comprehensive_md_path.name,
    )
    out = tmp_path / "comprehensive.org"
    out.write_text(org_text)

    assert out.exists()
    content = out.read_text()

    # Title from YAML id.
    assert "#+title: Comprehensive TODOS" in content

    # -- TEST section --
    assert "** TODO prototype UI with Figma" in content
    assert "figma.com/example" in content
    assert "still needs review from the design team." in content
    assert "** DONE write initial test plan" in content

    # -- DOING section: nested tasks and multi-line body text --
    assert "** TODO refactor authentication module" in content
    assert "Current approach is too tightly coupled" in content
    assert "*** TODO extract UserRepository interface" in content
    assert "**** TODO write unit tests for UserRepository" in content
    assert "*** TODO decouple session handling" in content
    assert "** TODO set up CI pipeline" in content
    assert "github.com/actions/setup-python" in content
    assert "docs.github.com/actions" in content

    # -- TODO section: bare URL, multi-line prose, non-checkbox note --
    assert "** TODO simple task no notes" in content
    assert "** TODO task with single bare url" in content
    assert "example.com/resource" in content
    assert "** TODO task with multi-line body text" in content
    assert "First, make sure the environment is clean." in content
    assert "Then run the migration script with --dry-run to verify." in content
    assert "Finally commit the changes." in content
    assert "** TODO ergonomic desk setup" in content
    assert "*** TODO adjustable standing desk" in content
    assert "**** TODO confirm desk dimensions fit the room" in content
    assert "*** TODO monitor arm for dual screens" in content
    assert (
        "non-checkbox option note: timob felix model also fits budget"
        in content
    )
    assert "example.com/timob" in content
    assert "ships within 3 days according to the vendor" in content

    assert "** TODO ergonomic chair" in content
    assert "*** TODO gaming chair by ikea" in content
    # Non-checkbox continuation 
    assert "ErgoLux Pro" in content
    assert "example.com/ergolux-pro-office-chair" in content
    assert "armrest side-to-side adjustment feels slightly stiff" in content
    assert "mixed reviews: some customers praise it" in content

    # -- BACKLOG section --
    assert "** TODO explore Neovim LSP configuration" in content
    assert "neovim/nvim-lspconfig" in content
    assert "hrsh7th/nvim-cmp" in content
    assert "** TODO read Designing Data-Intensive Applications" in content
    assert "Chapters 1-3 cover the foundation" in content
    assert "** TODO containerise the dev environment" in content
    assert "standalone note after nested tasks" in content

    # -- DONE section --
    assert "** DONE set up repository" in content
    assert "** DONE create initial README" in content
    assert "Added project overview" in content
    assert "** DONE configure ruff and mypy" in content
    assert "docs.astral.sh/ruff" in content


# ---------------------------------------------------------------------------
# Directory mode: both fixture files converted via convert_directory
# ---------------------------------------------------------------------------


def test_e2e_directory_mode(fixtures_dir: Path, tmp_path: Path) -> None:
    """convert_directory over a copy of the fixtures dir writes correct org files."""
    import shutil

    src_dir = tmp_path / "src"
    src_dir.mkdir()
    shutil.copy(
        fixtures_dir / "comprehensive.md", src_dir / "comprehensive.md"
    )

    results = convert_directory(src_dir)

    names_ok = {r.org_path.name for r in results if r.ok and r.org_path}
    assert "comprehensive.org" in names_ok
    assert not any(not r.ok for r in results), "expected no failures"

    org_dir = src_dir / "org_files"
    assert org_dir.is_dir()

    comp_content = (org_dir / "comprehensive.org").read_text()
    assert "#+title: Comprehensive TODOS" in comp_content
    assert "refactor authentication module" in comp_content
    assert "ErgoLux Pro" in comp_content


# ---------------------------------------------------------------------------
# CLI test: -o flag auto-creates missing parent directory
# ---------------------------------------------------------------------------


def test_e2e_cli_output_path_creates_parent(
    comprehensive_md_path: Path, tmp_path: Path, repo_root: Path
) -> None:
    """Passing -o to a non-existent subdirectory must create it and write the file."""
    nested_output = tmp_path / "deep" / "nested" / "comprehensive.org"

    result = subprocess.run(
        [
            sys.executable,
            "src/migration/md_to_org.py",
            str(comprehensive_md_path),
            "-o",
            str(nested_output),
        ],
        capture_output=True,
        text=True,
        cwd=str(repo_root),
    )

    assert result.returncode == 0, f"CLI failed:\n{result.stderr}"
    assert nested_output.exists(), "output file was not written"

    content = nested_output.read_text()
    assert "#+title: Comprehensive TODOS" in content
    assert "ErgoLux Pro" in content


# ---------------------------------------------------------------------------
# CLI test: single-file conversion defaults to sibling .org file
# ---------------------------------------------------------------------------


def test_e2e_cli_default_output_path(
    tmp_path: Path, repo_root: Path, comprehensive_md_path: Path
) -> None:
    """Without -o, the CLI writes <input>.org next to the source file."""
    import shutil

    # Copy comprehensive.md to tmp_path so the default sibling output lands there.
    tmp_input = tmp_path / "comprehensive.md"
    shutil.copy(comprehensive_md_path, tmp_input)

    result = subprocess.run(
        [sys.executable, "src/migration/md_to_org.py", str(tmp_input)],
        capture_output=True,
        text=True,
        cwd=str(repo_root),
    )

    assert result.returncode == 0, f"CLI failed:\n{result.stderr}"
    expected_output = tmp_path / "comprehensive.org"
    assert expected_output.exists()
    assert "#+title: Comprehensive TODOS" in expected_output.read_text()

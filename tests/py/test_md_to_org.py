"""Tests for src/migration/md_to_org.py."""

import pytest

from src.migration.md_to_org import (
    ConversionResult,
    convert_directory,
    convert_markdown,
    make_title,
    parse_tasks,
    remove_kanban_blocks,
    strip_frontmatter,
    validate_file,
)

# Root of the tests/fixtures/ tree relative to repo root.
_FIXTURES = (
    __file__  # tests/py/test_md_to_org.py
    and __import__("pathlib").Path(__file__).parent.parent
    / "fixtures"
    / "markdown-todos"
)

# Inline snapshot of temp.md (the canonical input example).
# Note: ## Review has been replaced with ## testing (a known heading)
# so that convert_markdown does not raise on this fixture after Phase 2.
TEMP_MD = """\
---
id: linux
aliases: []
tags: []
---
# TODO.md

## testing
## in-progress

- [ ] Disaster complete documents/file test in new CachyOS distro
  - [ ] Setup CachyOS properly same as your other setups
  - [ ] Get needed apps, setup apps test what's wrong on your dotfiles....
  - [ ] backintime isn't on arch official repo and AUR repo need clean chroot, so switching to borgbackup
  - [ ] P1: syncthing,
    - [ ] make sure worktrees are able to syncable
    - [ ] make sure dotfiles won't cause issue via laptop, android show conflicts

## backlog
## done
"""

# Inline snapshot of example_learn_tasks.md.
LEARN_MD = """\
# TODO.md

## testing

## in-progress

- [ ] Bash
- [ ] Learn git
  - [ ] bare-repo
  - [ ] rebase
  - [ ] merge different branches
    - [ ] Make a feat/branch

## todo

- [ ] Linux command challange <https://cmdchallenge.com/#/copy_file>

## done
"""


# ---------------------------------------------------------------------------
# strip_frontmatter
# ---------------------------------------------------------------------------


def test_strip_frontmatter_extracts_id():
    lines = ["---", "id: linux", "---", "# body"]
    remaining, data = strip_frontmatter(lines)
    assert data["id"] == "linux"
    assert remaining == ["# body"]


def test_strip_frontmatter_no_delimiters():
    lines = ["# plain", "no yaml here"]
    remaining, data = strip_frontmatter(lines)
    assert remaining == lines
    assert data == {}


# ---------------------------------------------------------------------------
# remove_kanban_blocks
# ---------------------------------------------------------------------------


def test_remove_kanban_blocks_drops_settings():
    lines = [
        "%% kanban:settings",
        '{"kanban-plugin":"board"}',
        "%%",
        "kept",
    ]
    out = remove_kanban_blocks(lines)
    assert out == ["kept"]


def test_remove_kanban_blocks_passthrough():
    lines = ["normal line", "another"]
    assert remove_kanban_blocks(lines) == lines


# ---------------------------------------------------------------------------
# parse_tasks
# ---------------------------------------------------------------------------


def test_parse_tasks_basic():
    lines = [
        "## todo",
        "- [ ] first",
        "  - [x] nested done",
    ]
    result = parse_tasks(lines)
    assert result["todo"] == [
        (0, False, "first", []),
        (1, True, "nested done", []),
    ]


def test_parse_tasks_ignores_unknown_section():
    lines = ["## random-section", "- [ ] should be ignored"]
    assert parse_tasks(lines) == {}


# ---------------------------------------------------------------------------
# make_title
# ---------------------------------------------------------------------------


def test_make_title_from_id():
    assert make_title({"id": "linux"}, "anything.md") == "Linux TODOS"


def test_make_title_fallback_to_filename():
    assert make_title({}, "health_todos.md") == "Health_todos TODOS"


def test_make_title_empty_filename():
    assert make_title({}, "") == "Untitled TODOS"


# ---------------------------------------------------------------------------
# convert_markdown – integration
# ---------------------------------------------------------------------------


def test_temp_conversion_contains_key_tasks():
    """Tasks from temp.md should appear under the right headings."""
    org = convert_markdown(TEMP_MD, source_filename="temp.md")

    assert "Disaster complete documents/file test in new CachyOS distro" in org
    assert "Setup CachyOS properly same as your other setups" in org
    assert "syncthing" in org


def test_heading_order_matches_template():
    """SECTION_TO_ORG order: TEST → DOING → TODO → BACKLOG → DONE."""
    org = convert_markdown(TEMP_MD, source_filename="temp.md")

    assert org.index("* 📝 TEST") < org.index("* 🔁 DOING")
    assert org.index("* 🔁 DOING") < org.index("* 🔲 TODO")
    assert org.index("* 🔲 TODO") < org.index("* 📥 BACKLOG")
    assert org.index("* 📥 BACKLOG") < org.index("* ✅ DONE")


def test_kanban_block_removed():
    md = """\
---
kanban-plugin: board
---

## todo
- [ ] story

%% kanban:settings
ignored
%%
"""
    out = convert_markdown(md)
    assert "kanban" not in out.lower()
    assert "story" in out


def test_title_from_id():
    # A known heading is required so validate_file does not raise.
    md = "---\nid: example\n---\n## todo\n- [ ] task\n"
    assert "Example TODOS" in convert_markdown(md)


def test_title_from_source_filename():
    """Falls back to source_filename when no YAML id is present."""
    md = "## todo\n- [ ] task\n"
    out = convert_markdown(md, source_filename="myproject.md")
    assert "Myproject TODOS" in out


def test_nested_items_and_statuses():
    md = """\
## todo
- [ ] parent
  - [x] child done
  - [ ] child todo
"""
    out = convert_markdown(md)
    assert "** TODO parent" in out
    assert "*** DONE child done" in out
    assert "*** TODO child todo" in out


def test_example_learn_tasks_converted():
    """Example learn-tasks items land in the right sections."""
    org = convert_markdown(LEARN_MD, source_filename="example_learn_tasks.md")

    assert "** TODO Bash" in org
    assert "** TODO Learn git" in org
    assert "** TODO Linux command challange" in org


# ---------------------------------------------------------------------------
# convert_directory
# ---------------------------------------------------------------------------


def test_convert_directory_creates_org_files(tmp_path):
    """All .md files in a directory are converted to org_files/."""
    (tmp_path / "alpha.md").write_text(
        "---\nid: alpha\n---\n## todo\n- [ ] do this\n"
    )
    (tmp_path / "beta.md").write_text("## done\n- [x] done task\n")

    written = convert_directory(tmp_path)
    # written is a list[ConversionResult]; use org_path for the output name
    names = {r.org_path.name for r in written if r.ok and r.org_path}

    assert names == {"alpha.org", "beta.org"}
    org_dir = tmp_path / "org_files"
    assert org_dir.is_dir()

    alpha_text = (org_dir / "alpha.org").read_text()
    assert "Alpha TODOS" in alpha_text
    assert "** TODO do this" in alpha_text

    beta_text = (org_dir / "beta.org").read_text()
    assert "** DONE done task" in beta_text


def test_convert_directory_empty_dir(tmp_path):
    """An empty directory produces no output files but doesn't error."""
    written = convert_directory(tmp_path)
    assert written == []
    assert (tmp_path / "org_files").is_dir()


def test_convert_directory_org_files_not_processed(tmp_path):
    """Files already in org_files/ are not re-processed."""
    (tmp_path / "real.md").write_text("## todo\n- [ ] task\n")
    convert_directory(tmp_path)
    # run again – org_files/ dir now exists but no .md inside it
    written_second = convert_directory(tmp_path)
    assert len(written_second) == 1  # same single source .md


# ---------------------------------------------------------------------------
# New Phase 1 Tests: Error Handling & Validation
# ---------------------------------------------------------------------------


def test_single_file_unknown_heading_raises():
    """convert_markdown must raise ValueError when unknown ## headings exist."""
    md = "---\nid: test\n---\n## Review\n- [ ] task\n"
    with pytest.raises(ValueError, match="Review"):
        convert_markdown(md)


def test_multiple_unknown_headings_reported():
    """All unknown headings are reported, not just the first."""
    md = "## Review\n## Random\n- [ ] task\n"
    with pytest.raises(ValueError) as exc_info:
        convert_markdown(md)
    msg = str(exc_info.value)
    assert "Review" in msg
    assert "Random" in msg


def test_no_task_headings_fails_file():
    """A file with no recognised ## section headings must raise ValueError."""
    md = """\
---
id: add-aps-cli-seatd-setup
---

# How to setup vibrance for wayland on nvidia?

- 1. enable the copr repo first

That error means your Hyprland session was not started through systemd.
"""
    with pytest.raises(ValueError, match="no recognised"):
        convert_markdown(md)


def test_continuation_lines_as_body_text():
    """Indented note lines after a checkbox appear as body text in org."""
    md = """\
## todo
- [ ] How to handle task management?
   I think best one is to use the todo folder.
"""
    out = convert_markdown(md)
    assert "** TODO How to handle task management?" in out
    assert "I think best one is to use the todo folder." in out


def test_multiline_note_captured():
    """Multi-line continuation notes are all captured as body text."""
    md = """\
## in-progress
- [ ] lets figure out what to do
  inconvenient in them like sysadmin.md
  better to rename them more conveniently.
"""
    out = convert_markdown(md)
    assert "** TODO lets figure out what to do" in out
    assert "inconvenient in them like sysadmin.md" in out
    assert "better to rename them more conveniently." in out


def test_validate_file_returns_errors_for_unknown_heading():
    """validate_file returns error strings for each unknown ## heading."""
    lines = ["## todo", "- [ ] task", "## Review", "- [ ] another"]
    errors = validate_file(lines)
    assert any("Review" in e for e in errors)


def test_validate_file_returns_errors_for_no_headings():
    """validate_file returns an error when no known ## sections are found."""
    lines = ["# just a regular markdown", "some text here"]
    errors = validate_file(lines)
    assert len(errors) > 0
    assert any("no recognised" in e.lower() for e in errors)


def test_validate_file_passes_clean_input():
    """validate_file returns empty list for a well-formed kanban file."""
    lines = ["## todo", "- [ ] task", "## done", "- [x] finished"]
    errors = validate_file(lines)
    assert errors == []


def test_convert_directory_returns_results(tmp_path):
    """convert_directory returns a list of ConversionResult objects."""
    (tmp_path / "good.md").write_text("## todo\n- [ ] task\n")
    results = convert_directory(tmp_path)
    assert all(isinstance(r, ConversionResult) for r in results)
    assert results[0].ok is True
    assert results[0].path.name == "good.md"
    assert results[0].org_path is not None


def test_convert_directory_skips_failed_files(tmp_path):
    """Failed files are not written; only successful ones are."""
    (tmp_path / "good.md").write_text("## todo\n- [ ] task\n")
    (tmp_path / "bad.md").write_text("## Review\n- [ ] task\n")

    results = convert_directory(tmp_path)

    good = next(r for r in results if r.path.name == "good.md")
    bad = next(r for r in results if r.path.name == "bad.md")

    assert good.ok is True
    assert (tmp_path / "org_files" / "good.org").exists()

    assert bad.ok is False
    assert bad.error is not None
    assert not (tmp_path / "org_files" / "bad.org").exists()


def test_recursive_flag_finds_subdir_files(tmp_path):
    """recursive=True picks up .md files in subdirectories."""
    subdir = tmp_path / "subdir"
    subdir.mkdir()
    (tmp_path / "top.md").write_text("## todo\n- [ ] top task\n")
    (subdir / "nested.md").write_text("## todo\n- [ ] nested task\n")

    results = convert_directory(tmp_path, recursive=True)
    names = {r.path.name for r in results}
    assert "top.md" in names
    assert "nested.md" in names


def test_recursive_false_ignores_subdirs(tmp_path):
    """recursive=False (default) does not enter subdirectories."""
    subdir = tmp_path / "subdir"
    subdir.mkdir()
    (tmp_path / "top.md").write_text("## todo\n- [ ] top task\n")
    (subdir / "nested.md").write_text("## todo\n- [ ] nested task\n")

    results = convert_directory(tmp_path, recursive=False)
    names = {r.path.name for r in results}
    assert "top.md" in names
    assert "nested.md" not in names


# ---------------------------------------------------------------------------
# shop.md regression tests (production file)
# ---------------------------------------------------------------------------

# Full inline copy of the production shop.md; also used as a fixture file at
# tests/fixtures/markdown-todos/shop.md for e2e tests.
SHOP_MD = (_FIXTURES / "shop.md").read_text()

# Real-world dotfiles task file (moved from root todo.md).
_TODO_MD = (_FIXTURES / "todo.md").read_text()

# Real-world linux-system-utils docs task file.
_DOCS_TODO_MD = (_FIXTURES / "docs_todo.md").read_text()


def test_shop_md_all_tasks_present():
    """All main todo items from shop.md must appear in org output."""
    org = convert_markdown(SHOP_MD, source_filename="shop.md")

    assert (
        "** TODO steel series headset 160240 battery need replacement" in org
    )
    assert (
        "** TODO get 2k or 4k programming monitor (not gaming, not IPS)" in org
    )
    assert "** TODO M2 SSD, samsung 990 PRO 1TB NVMe Gen4" in org
    assert "** TODO ergonomic chair" in org
    assert "*** TODO gaming chair by ikea" in org


def test_shop_md_bare_url_after_task_preserved():
    """A bare URL on its own line directly after a task is kept as body text."""
    org = convert_markdown(SHOP_MD, source_filename="shop.md")

    # The Samsung SSD URL appears on a line of its own below the task.
    assert "hepsiburada.com/samsung-990-pro" in org


def test_shop_md_non_checkbox_bullet_preserved():
    """Non-checkbox bullet '- timob felix …' must appear in the org output."""
    org = convert_markdown(SHOP_MD, source_filename="shop.md")

    assert "timob felix" in org


def test_shop_md_timob_sub_items_preserved():
    """All sub-items under the timob felix bullet are kept as body text."""
    org = convert_markdown(SHOP_MD, source_filename="shop.md")

    assert "kolçaklarda ileri geri çok hassasmış" in org
    assert "firma çok iyi diyen de var" in org
    assert "hepsiburada.com/timob-felix" in org


def test_shop_md_backlog_urls_preserved():
    """Backlog items include their bare URL continuation lines."""
    org = convert_markdown(SHOP_MD, source_filename="shop.md")

    assert "** TODO hdmi, ssd connection cables" in org
    assert "hepsiburada.com/ugreen-90-derece-sata" in org
    assert "itopya.com/ugreen-4k-hdmi" in org
    assert "** TODO smart socket(priz) for router" in org
    assert "trendyol.com/tp-link/ttapo-p100" in org


def test_shop_md_title_from_id():
    """shop.md has id: shop, so title should be 'Shop TODOS'."""
    org = convert_markdown(SHOP_MD, source_filename="shop.md")

    assert "#+title: Shop TODOS" in org


def test_bare_url_after_task_isolated():
    """Minimal unit: bare URL directly after task is attached as body text."""
    md = "## todo\n- [ ] My task\n<https://example.com/ref>\n"
    out = convert_markdown(md)

    assert "** TODO My task" in out
    assert "<https://example.com/ref>" in out


def test_non_checkbox_bullet_after_nested_task():
    """Non-checkbox bullet after a nested task is preserved as body text."""
    md = """\
## todo
- [ ] parent task
  - [ ] nested task
- plain bullet note
  - sub-item of plain bullet
"""
    out = convert_markdown(md)

    assert "** TODO parent task" in out
    assert "*** TODO nested task" in out
    assert "plain bullet note" in out
    assert "sub-item of plain bullet" in out


def test_output_parent_dir_auto_created(tmp_path):
    """write_text should succeed even when the output parent dir does not yet exist."""
    # Importing Path and simulating the __main__ logic directly.
    import subprocess
    import sys

    fixture = _FIXTURES / "shop.md"
    output = tmp_path / "new_subdir" / "shop.org"
    result = subprocess.run(
        [
            sys.executable,
            "src/migration/md_to_org.py",
            str(fixture),
            "-o",
            str(output),
        ],
        capture_output=True,
        text=True,
        cwd=__import__("pathlib").Path(__file__).parent.parent.parent,
    )
    assert result.returncode == 0, result.stderr
    assert output.exists(), "output file was not written"
    assert "Shop TODOS" in output.read_text()


# ---------------------------------------------------------------------------
# Phase: body-text parsing fix – blank-line termination removed
# All tests below FAIL on the unmodified script and PASS after the fix.
# ---------------------------------------------------------------------------


def test_code_fence_after_blank_line_captured():
    """A fenced code block separated from task body by a blank line must
    appear in the body text – the blank line must NOT terminate collection."""
    md = """\
## in-progress
- [ ] setup task
  body text here

  ```bash
  echo hello
  ```
- [ ] next task
"""
    out = convert_markdown(md)
    assert "** TODO setup task" in out
    assert "body text here" in out
    # The fence marker must be present (it is part of the note body).
    assert "```bash" in out


def test_code_fence_content_after_blank_line_captured():
    """Code content inside a fenced block after a blank line is body text."""
    md = """\
## in-progress
- [ ] task with code

  ```bash
  echo hello
  ```
- [ ] next task
"""
    out = convert_markdown(md)
    assert "** TODO task with code" in out
    assert "echo hello" in out


def test_multi_paragraph_note_captured():
    """Two prose paragraphs separated by a blank line are both body text
    of the same task – the blank line must NOT reset tracking."""
    md = """\
## todo
- [ ] multi-para task
  first paragraph here

  second paragraph here
- [ ] next task
"""
    out = convert_markdown(md)
    assert "** TODO multi-para task" in out
    assert "first paragraph here" in out
    assert "second paragraph here" in out


# ---------------------------------------------------------------------------
# todo.md e2e tests (fixture: tests/fixtures/markdown-todos/todo.md)
# ---------------------------------------------------------------------------


def test_todo_md_e2e_structure():
    """All canonical task headlines are in the output and sections are ordered
    correctly when converting the real todo.md fixture."""
    out = convert_markdown(_TODO_MD, source_filename="todo.md")

    # Title from YAML id: dotfiles
    assert "#+title: Dotfiles TODOS" in out

    # Section order
    assert out.index("* 📝 TEST") < out.index("* 🔁 DOING")
    assert out.index("* 🔁 DOING") < out.index("* 🔲 TODO")
    assert out.index("* 🔲 TODO") < out.index("* 📥 BACKLOG")

    # Key tasks present
    assert (
        "** TODO setup.sh problem on dotfiles that move files like this"
        " if it's already exist" in out
    )
    assert "** TODO hyprland" in out
    assert "**** TODO Learn how to decrease brightness" in out
    assert "** TODO Polybar" in out
    assert (
        "**** TODO playerctl script cause issue when two instance of output"
        in out
    )


def test_todo_md_e2e_code_content_present():
    """The dot-config path listing from the code block under the setup.sh task
    must appear in the body text after the fix (blank-line rule removed)."""
    out = convert_markdown(_TODO_MD, source_filename="todo.md")

    # These path strings live inside the ``` code block that currently gets
    # dropped because there is a blank line between the prose notes and the
    # fence.  After the fix they must be present.
    assert "dot-config/alacritty/alacritty/" in out
    assert "dot-config/polybar/polybar/" in out


# ---------------------------------------------------------------------------
# docs_todo.md e2e tests (fixture: tests/fixtures/markdown-todos/docs_todo.md)
# ---------------------------------------------------------------------------


def test_docs_todo_md_e2e_all_tasks_present():
    """All top-level task headlines from docs_todo.md appear in the output."""
    out = convert_markdown(_DOCS_TODO_MD, source_filename="docs_todo.md")

    assert "** TODO borgbackup scripts now moved" in out
    assert "** TODO make scrap script better" in out
    assert "** TODO P1: better script location" in out
    assert "** TODO implement copy_agents.sh" in out
    assert "** TODO make changelog_commits.md rewrite" in out
    assert "** TODO make spotify .cache/spotify/data" in out


def test_docs_todo_md_e2e_code_block_captured():
    """The ```bash ~/src/my-tools/ code block that follows the
    'Your install script should:' sub-task must appear as body text."""
    out = convert_markdown(_DOCS_TODO_MD, source_filename="docs_todo.md")

    # The sub-task headline
    assert "**** TODO Your install script should:" in out

    # Continuation prose inside the sub-task
    assert "Detect broken symlinks" in out
    assert "Refuse to overwrite real files" in out

    # Code block that is separated from the prose by a blank line:
    # ```bash
    # ~/src/my-tools/     …
    assert "~/src/my-tools/" in out

#!/usr/bin/env python3
"""Utility for converting Obsidian markdown todo files to Org-mode format.

Background
----------
Obsidian stores kanban-style task boards as plain markdown files with
``## Section`` headings and ``- [ ]``/``- [x]`` checkboxes.  This script
migrates those files to Org-mode documents.

How it works
------------
1. YAML frontmatter is stripped; the ``id`` field (if present) becomes the
   document title (e.g. ``id: linux`` → ``#+title: Linux TODOS``).
2. Obsidian ``%% kanban: ... %%`` settings blocks are removed entirely.
3. ``## Section`` headings are matched against ``SECTION_TO_ORG``.
4. Checkbox items are converted to Org TODO/DONE headlines; nesting is
   preserved via the leading-space count (2 spaces = one extra star).
5. Output heading order follows the insertion order of ``SECTION_TO_ORG``.

Usage – single file
-------------------
    uv run src/migration/md_to_org.py input.md [-o out.org]

Usage – whole directory
-----------------------
    uv run src/migration/md_to_org.py --path ~/Documents/markdown_files

    Every ``*.md`` file in the directory is converted and written to
    ``<dir>/org_files/<name>.org`` (the subfolder is created automatically).
    Example: ``linux.md`` → ``org_files/linux.org``
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path

# Mapping of normalised markdown section names to org heading text.
# The OUTPUT ORDER is determined by this dict.
SECTION_TO_ORG: dict[str, str] = {
    "testing": "📝 TEST",
    "in-progress": "🔁 DOING",
    "todo": "🔲 TODO",
    "backlog": "📥 BACKLOG",
    "done": "✅ DONE",
}


@dataclass
class ConversionResult:
    """Result of converting a single markdown file."""

    ok: bool
    path: Path
    error: str | None = None
    org_path: Path | None = None


def strip_frontmatter(
    lines: list[str],
) -> tuple[list[str], dict[str, str]]:
    """Remove YAML frontmatter block and return (remaining_lines, data).

    Only simple ``key: value`` pairs are parsed from the frontmatter;
    everything else is discarded.
    """
    if lines and lines[0].strip() == "---":
        end: int | None = None
        for i, line in enumerate(lines[1:], start=1):
            if line.strip() == "---":
                end = i
                break
        if end is not None:
            data: dict[str, str] = {}
            for line in lines[1:end]:
                if ":" in line:
                    k, v = line.split(":", 1)
                    data[k.strip()] = v.strip()
            return lines[end + 1 :], data
    return lines, {}


def remove_kanban_blocks(lines: list[str]) -> list[str]:
    """Drop Obsidian ``%% kanban: ... %%`` settings blocks."""
    out: list[str] = []
    in_block = False
    for line in lines:
        stripped = line.strip()
        if not in_block and stripped.startswith("%% kanban:"):
            in_block = True
            continue
        if in_block and stripped == "%%":
            in_block = False
            continue
        if not in_block:
            out.append(line)
    return out


def parse_tasks(
    lines: list[str],
) -> dict[str, list[tuple[int, bool, str, list[str]]]]:
    """Collect checkbox items grouped by their section heading.

    Returns a dict mapping normalised section names to a list of
    ``(indent_level, checked, text, notes)`` tuples. Indent level is derived
    from leading spaces (2 spaces per level, matching Obsidian's default).

    Any non-checkbox line that follows a checkbox item (within the same
    section, before the next checkbox or recognised ``##`` section heading)
    is treated as body text and appended to that task's ``notes`` list.
    This includes code blocks (fence markers and content), bare URLs,
    blockquote lines, plain bullet notes, and multi-paragraph prose.

    Blank lines inside a task's body are **skipped** (not appended and not
    used as a terminator).  Body text collection ends only when:

    * the next ``- [ ]`` / ``- [x]`` checkbox is encountered, or
    * a recognised ``## section`` heading is encountered.
    """
    result: dict[str, list[tuple[int, bool, str, list[str]]]] = {}
    current_section: str | None = None
    current_task_indent: int | None = None
    current_task_notes: list[str] = []

    for line in lines:
        if line.startswith("##"):
            sec = line.lstrip("#").strip().lower()
            current_section = sec if sec in SECTION_TO_ORG else None
            current_task_indent = None
            current_task_notes = []
            continue

        # Try to match a checkbox line
        m = re.match(r"^(\s*)- \[([ xX])\] (.+)", line)
        if m and current_section is not None:
            # We found a checkbox, so append any pending notes to the previous task
            level = len(m.group(1)) // 2
            checked = m.group(2).lower() != " "
            text = m.group(3).strip()

            # Update tracking for this new checkbox
            current_task_indent = len(m.group(1))
            current_task_notes = []

            result.setdefault(current_section, []).append(
                (level, checked, text, current_task_notes)
            )
            continue

        # Collect continuation body text for the current task.
        #
        # Blank lines are skipped: they do NOT terminate note collection so
        # that code blocks, blockquotes, and multi-paragraph prose separated
        # by blank lines from the task headline are all preserved.
        #
        # Everything else (code fence markers, blockquote lines, H1 headings,
        # plain text, URLs …) is appended as body text until the next
        # checkbox or recognised ## section heading resets the state.
        if current_task_indent is not None and current_section is not None:
            if not line.strip():
                # Skip blank lines without resetting body-text collection.
                continue

            # Append as body text (strip only trailing whitespace to keep
            # meaningful leading characters like `>` or ` ``` `).
            current_task_notes.append(line.rstrip())
            continue

    return result


def validate_file(lines: list[str]) -> list[str]:
    """Validate lines from a kanban markdown file.

    Returns a list of error strings. Empty list means the file is valid.

    Errors:
    - One error if no recognised ## section headings are found at all.
    - One error per unrecognised ## heading found.
    """
    errors: list[str] = []
    known_count = 0
    unknown_headings: list[str] = []

    for line in lines:
        if line.startswith("##"):
            # Preserve original heading text for error messages
            original_heading = line.lstrip("#").strip()
            normalized_heading = original_heading.lower()
            if normalized_heading in SECTION_TO_ORG:
                known_count += 1
            else:
                unknown_headings.append(original_heading)

    # Add error for each unknown heading
    for heading in unknown_headings:
        errors.append(f"unknown heading: '{heading}'")

    # If no known headings found, add that error
    if known_count == 0:
        errors.append("no recognised kanban section headings found")

    return errors


def make_title(frontmatter: dict[str, str], filename: str) -> str:
    """Generate a document title from the YAML ``id`` field or the filename."""
    idv = frontmatter.get("id")
    if idv:
        return f"{idv.capitalize()} TODOS"
    stem = Path(filename).stem if filename else "untitled"
    return f"{stem.capitalize()} TODOS"


def render_org(
    title: str,
    tasks_by_section: dict[str, list[tuple[int, bool, str, list[str]]]],
    author: str = "Cyber-Syntax",
) -> str:
    """Assemble the final Org-mode document string.

    Heading order follows the insertion order of ``SECTION_TO_ORG``.
    """
    out_lines: list[str] = [f"#+title: {title}", f"#+author: {author}", ""]
    for key, heading in SECTION_TO_ORG.items():
        out_lines.append(f"* {heading}")
        if key in tasks_by_section:
            for level, checked, text, notes in tasks_by_section[key]:
                stars = "*" * (2 + level)
                status = "DONE" if checked else "TODO"
                out_lines.append(f"{stars} {status} {text}")
                for note in notes:
                    out_lines.append(note)
        out_lines.append("")
    return "\n".join(out_lines).rstrip() + "\n"


def convert_markdown(
    md_text: str,
    author: str = "Cyber-Syntax",
    source_filename: str = "",
) -> str:
    """Convert a markdown todo string to an Org-mode string.

    Parameters
    ----------
    md_text:
        Raw markdown content to convert.
    author:
        Value written to ``#+author:``.
    source_filename:
        Original filename used as fallback title when no YAML ``id`` exists.

    Raises
    ------
    ValueError
        If the file has no recognised kanban headings or contains unknown headings.
    """
    lines = md_text.splitlines()
    lines, fm = strip_frontmatter(lines)
    lines = remove_kanban_blocks(lines)
    errors = validate_file(lines)
    if errors:
        raise ValueError("; ".join(errors))
    tasks = parse_tasks(lines)
    title = make_title(fm, source_filename)
    return render_org(title, tasks, author)


def convert_directory(
    dir_path: Path,
    author: str = "Cyber-Syntax",
    recursive: bool = False,
) -> list[ConversionResult]:
    """Convert every ``*.md`` file in *dir_path* and write to ``org_files/``.

    The output directory ``<dir_path>/org_files/`` is created when it does
    not exist. Each file is converted independently. Files in the org_files/
    subdirectory are skipped.

    Parameters
    ----------
    dir_path:
        Directory to scan for *.md files.
    author:
        Value written to ``#+author:`` in generated org files.
    recursive:
        If True, scan subdirectories recursively. If False (default),
        scan only the top-level directory.

    Returns
    -------
    list[ConversionResult]
        List of conversion results (including both successes and failures).
    """
    org_dir = dir_path / "org_files"
    org_dir.mkdir(exist_ok=True)
    results: list[ConversionResult] = []

    # Choose glob pattern based on recursive flag
    if recursive:
        glob_pattern = "**/*.md"
    else:
        glob_pattern = "*.md"

    for md_file in sorted(dir_path.glob(glob_pattern)):
        # Skip files inside org_files directory
        if "org_files" in md_file.parts:
            continue

        try:
            org_text = convert_markdown(
                md_file.read_text(),
                author,
                source_filename=md_file.name,
            )
            out_path = org_dir / md_file.with_suffix(".org").name
            out_path.write_text(org_text)
            print(f"✅ {md_file.name} → org_files/{out_path.name}")
            results.append(
                ConversionResult(ok=True, path=md_file, org_path=out_path)
            )
        except ValueError as e:
            print(f"❌ {md_file.name}: {str(e)}")
            results.append(
                ConversionResult(ok=False, path=md_file, error=str(e))
            )

    return results


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(
            "Convert Obsidian markdown todo files to Org-mode format. "
            "Pass a single file or --path for a whole directory."
        )
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "input",
        nargs="?",
        type=Path,
        help="Single markdown file to convert",
    )
    group.add_argument(
        "--path",
        type=Path,
        metavar="DIR",
        help=("Convert all *.md files in DIR; output goes to DIR/org_files/"),
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="Destination org file (single-file mode only)",
    )
    parser.add_argument(
        "--author",
        default="Cyber-Syntax",
        help="Value for #+author (default: Cyber-Syntax)",
    )
    parser.add_argument(
        "-r",
        "--recursive",
        action="store_true",
        help="Scan subdirectories recursively (directory mode only)",
    )
    args = parser.parse_args()

    if args.path:
        target = args.path.expanduser().resolve()
        if not target.is_dir():
            print(f"error: {target} is not a directory", file=sys.stderr)
            sys.exit(1)
        print(f"Converting *.md files in {target} …")
        results = convert_directory(
            target, args.author, recursive=args.recursive
        )

        # Print summary
        successes = [r for r in results if r.ok]
        failures = [r for r in results if not r.ok]

        print("─" * 33)
        print(f"Summary: {len(successes)} succeeded, {len(failures)} failed")
        for r in successes:
            print(f"✅ {r.path.name}")
        for r in failures:
            print(f"❌ {r.path.name}: {r.error}")
        print("─" * 33)
    else:
        try:
            md = args.input.read_text()
            org = convert_markdown(
                md,
                author=args.author,
                source_filename=args.input.name,
            )
            outpath = args.output or args.input.with_suffix(".org")
            outpath.parent.mkdir(parents=True, exist_ok=True)
            outpath.write_text(org)
            print(f"Written: {outpath}")
        except ValueError as e:
            print(f"error: {str(e)}", file=sys.stderr)
            sys.exit(1)

    sys.exit(0)

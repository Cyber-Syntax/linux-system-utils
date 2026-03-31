# md_to_org – Markdown → Org-mode migration

`src/migration/md_to_org.py` converts Obsidian kanban-style markdown task
files into Org-mode documents.

## Why this script exists

Obsidian stores kanban boards as plain markdown.  Moving to `nvim-orgmode`
requires structured Org files with `TODO`/`DONE` keywords.  The script
automates the tedious part: stripping Obsidian metadata, routing each
section's checkboxes to the right Org heading, and preserving nesting depth.

## How it works

```
input.md  ──►  strip YAML frontmatter  ──►  drop %% kanban blocks
          ──►  validate ## section headings (fail fast on unknown/missing)
          ──►  collect ## sections + checkboxes + continuation notes
          ──►  map sections → SECTION_TO_ORG (dict order = output order)
          ──►  emit Org with #+title / #+author / * headings / ** TODO items
```

1. **YAML frontmatter** (`---`) is stripped. The `id:` value becomes the
   document title (`id: linux` → `#+title: Linux TODOS`). If no `id` is
   present the source filename stem is used instead.
2. **Obsidian kanban blocks** (`%% kanban:settings … %%`) are dropped
   entirely.
3. **Validation** – the file must contain at least one recognised `##`
   section heading (H2 only). Any unknown `##` heading causes the file to
   be rejected with a descriptive error.  See
   [Validation & error reporting](#validation--error-reporting) below.
4. **Section mapping** – the following `## heading` names are recognised
   (case-insensitive). Output order follows the dict insertion order in
   `SECTION_TO_ORG` — edit only that dict to reorder or rename headings:

   | Markdown section | Org heading   |
   |------------------|---------------|
   | `testing`        | `📝 TEST`     |
   | `in-progress`    | `🔁 DOING`    |
   | `todo`           | `🔲 TODO`     |
   | `backlog`        | `📥 BACKLOG`  |
   | `done`           | `✅ DONE`     |

5. **Checkbox conversion** – `- [ ] text` → `** TODO text`,
   `- [x] text` → `** DONE text`. Two leading spaces increase the heading
   depth by one star (`***`, `****`, …).
6. **Continuation notes** – indented non-checkbox lines that follow a
   `- [ ]` item are captured and emitted as plain body text directly under
   the `** TODO` headline in the org output.

   ```markdown
   - [ ] My task
      I think best one is to use the todo folder.
   ```

   becomes:

   ```org
   ** TODO My task
   I think best one is to use the todo folder.
   ```

## Usage

### Single file

```bash
uv run src/migration/md_to_org.py input.md
# output: input.org (next to the source file)

uv run src/migration/md_to_org.py input.md -o ~/org/linux.org
```

### Whole directory

```bash
uv run src/migration/md_to_org.py --path ~/Documents/markdown_files
```

Every `*.md` file in the directory is converted.  Output is written to
`<dir>/org_files/` (created automatically).  Files that fail validation
(non-task markdown, unknown headings) are **skipped** — they are not written
to disk and a ❌ line is printed.  A summary is shown at the end:

```
─────────────────────────────────────────────────────────────
Summary: 2 succeeded, 1 failed
✅ linux.md
✅ health_todos.md
❌ setup-guide.md: no recognised kanban section headings found
─────────────────────────────────────────────────────────────
```

```
markdown_files/
├── linux.md          →   org_files/linux.org
├── health_todos.md   →   org_files/health_todos.org
├── setup-guide.md    →   (skipped — not a task file)
└── org_files/
    ├── linux.org
    └── health_todos.org
```

#### Recursive subdirectory scan

Use `--recursive` / `-r` to also pick up `*.md` files in subdirectories:

```bash
uv run src/migration/md_to_org.py --path ~/Documents/markdown_files --recursive
```

All converted org files land flat in the same `<dir>/org_files/` folder.

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `input` (positional) | – | Single markdown file to convert |
| `--path DIR` | – | Directory mode; mutually exclusive with `input` |
| `-o / --output FILE` | `<input>.org` | Output path (single-file mode only) |
| `--author NAME` | `Cyber-Syntax` | Value for `#+author` |
| `-r / --recursive` | off | Also scan subdirectories (directory mode only) |

## Validation & error reporting

The script **validates** each file before converting it. A file is rejected
(with a clear error message) if:

- **No recognised section headings** — the file contains no `## testing`,
  `## todo`, `## in-progress`, `## backlog`, or `## done` headings at all.
  This catches plain (non-kanban) markdown documents.

  ```
  ❌ setup-guide.md: no recognised kanban section headings found
  ```

- **Unknown `##` heading** — the file has a `##` heading that is not one of
  the five known section names (e.g. `## Review`, `## Resources`).

  ```
  ❌ linux.md: unknown heading: 'Review'
  ```

In **directory mode** a failed file is skipped (not written to disk) and
processing continues with the next file.  A summary at the end lists every
success and failure.

In **single-file mode**, a `ValueError` is raised and the script exits with
code 1, printing the error to stderr.

## Running tests

```bash
PYTHONPATH=. uv run pytest tests/py/test_md_to_org.py -v
```

---

## Reference examples

These files were the original samples used while developing the script.

### template.md — Obsidian kanban board template (input side)

```markdown
---
kanban-plugin: board
aliases: []
id: todo_template
tags: []
---

## testing

## in-progress

## todo

## backlog

## done

%% kanban:settings
{"kanban-plugin":"board","list-collapse":[false],"lane-width":360}
%%
```

### template.org — Org-mode heading template (output side)

```org
#+title: TODO Template
#+author: Cyber-Syntax

* 📝 TEST
* 🔁 DOING
* 🔲 TODO
* 📥 BACKLOG
* ✅ DONE
```

### temp.md — real example input (linux tasks)

```markdown
---
id: linux
aliases: []
tags: []
---
# TODO.md

## Review
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
```

### temp.org — manually migrated expected output

```org
#+title: Linux TODOS
#+author: Cyber-Syntax

* 📝 TEST
* 🔁 DOING
** TODO Learn nvim-orgmode
SCHEDULED: <2026-03-04 Pzt>
https://github.com/nvim-orgmode/orgmode/blob/master/docs/index.org#getting-started
** TODO Remove ctrl+a from org
SCHEDULED: <2026-03-05 Pzt>
** TODO Disaster complete documents/file test in new CachyOS distro
SCHEDULED: <2026-02-25 Çrş>
*** TODO Setup CachyOS properly same as your other setups
*** TODO Get needed apps, setup apps test what's wrong on your dotfiles....
*** TODO backintime isn't on arch official repo and AUR repo need clean chroot, so switching to borgbackup
** TODO [#P1] syncthing,
*** TODO make sure worktrees are able to syncable
*** TODO make sure dotfiles won't cause issue via laptop, android show conflicts
* 📥 BACKLOG
* ✅ DONE
```

### example_learn_tasks.md — second example input (learning tasks)

```markdown
# TODO.md

## testing

## in-progress

- [ ] Bash
- [ ] [Python-Lessons](19_Computer_Science/19.02_Programming_Language_Notes/Python/Python-Lessons.md)
- [ ] Compure Science via CS50
- [ ] Learn git
<https://ooloo.io/project/github-flow/>
<https://git-scm.com/book/>
<https://www.kaggle.com/whitepaper-agents>
~/Documents/books/developers/GitNotesForProfessionals.pdf
  - [ ] bare-repo
  - [ ] rebase
  - [ ] general
  - [ ] merge different branches
    - This would make us to learn how to real development work for contributions.
    - [ ] Make a feat/branch, fix/branch later if you find a problem on main
    - Stop adding new features on the refactoring branches!!!!

## todo

- [ ] Linux command challange <https://cmdchallenge.com/#/copy_file>

## done
```

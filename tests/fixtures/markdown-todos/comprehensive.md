---
id: comprehensive
aliases: []
tags: []
---
# Comprehensive Test Todos

## testing

- [ ] prototype UI with Figma
  <https://www.figma.com/example>
  still needs review from the design team.
- [x] write initial test plan

## in-progress

- [ ] refactor authentication module
  Current approach is too tightly coupled to the database layer.
  Consider using the repository pattern instead.
    - [ ] extract UserRepository interface
        - [ ] write unit tests for UserRepository
    - [ ] decouple session handling
- [ ] set up CI pipeline
<https://github.com/actions/setup-python>
<https://docs.github.com/actions>

## todo

- [ ] simple task no notes
- [ ] task with single bare url
<https://example.com/resource>
- [ ] task with multi-line body text
  First, make sure the environment is clean.
  Then run the migration script with --dry-run to verify.
  Finally commit the changes.
- [ ] ergonomic desk setup
    - [ ] adjustable standing desk
        - [ ] confirm desk dimensions fit the room
    - [ ] monitor arm for dual screens
- non-checkbox option note: timob felix model also fits budget
    - <https://example.com/timob>
    - ships within 3 days according to the vendor
    - warranty is 2 years
- [ ] ergonomic chair
    - [ ] gaming chair by ikea: <https://example.com/ikea-gaming-chair-bastboll>
- ErgoLux Pro highly rated, lumbar support, armrests adjust left/right and forward/backward. $299
    - <https://example.com/ergolux-pro-office-chair>
    - armrest side-to-side adjustment feels slightly stiff
    - mixed reviews: some customers praise it, others find it uncomfortable long-term

## backlog

- [ ] explore Neovim LSP configuration
<https://github.com/neovim/nvim-lspconfig>
<https://github.com/hrsh7th/nvim-cmp>
- [ ] read Designing Data-Intensive Applications
  Chapters 1-3 cover the foundation needed for the project.
- [ ] containerise the dev environment
    - [ ] write Dockerfile for Python service
    - [ ] write docker-compose for local stack
- standalone note after nested tasks: also check podman as an alternative

## done

- [x] set up repository
- [x] create initial README
  Added project overview, installation steps, and usage examples.
- [x] configure ruff and mypy
<https://docs.astral.sh/ruff/>

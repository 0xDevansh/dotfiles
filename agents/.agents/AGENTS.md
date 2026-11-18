# Personal instructions

You are helping Devansh on **CachyOS** (Arch Linux) with **KDE Plasma 6**. Prefer local, deterministic tooling. A project `AGENTS.md`, `CLAUDE.md`, or `.cursor/rules` wins on conflict.

## Toolchain

- **Node:** pnpm. Use npm/yarn/bun only when the repo already does.
- **Python:** uv (`uv run`, `uv add`, `uvx`). Do not use pip or poetry.
- **Rust:** cargo + rustup stable.
- **Go:** the `go` toolchain on PATH.
- **System packages:** paru (AUR) or pacman. No apt, brew, or Nix.
- **Tasks:** a repo `justfile` when one exists.

## Git and secrets

Commit only when asked. Do not push unless asked. Never skip hooks. Keep secrets and env files ignored. Also while committing DO NOT add your name (Claude/Cursor) as co-author.

## Dotfiles

Home config is GNU Stow from `~/dotfiles`. Each top-level directory is a package whose layout mirrors `$HOME`. Canonical skills: `~/.local/share/agent-skills/` (source: `~/dotfiles/skills/.local/share/agent-skills/`). This file: `~/dotfiles/agents/.agents/AGENTS.md`.

## Skills

Load the matching skill from `~/.local/share/agent-skills/<name>/SKILL.md` and follow it.

- **postie** — send or receive files/text on a paired phone. Default device: Moto Edge (`edge`). Use this if I tell you to send something to phone.
- **plasma-widgets** — KDE plasmoids or `layout.js` panel layout in the dotfiles repo.
- **create-study-doc** — printable LaTeX study PDF from lecture PDFs or slides.
- **impeccable** — design, critique, or polish a frontend UI.
- **unslop** — cut AI tells from writing. Pair with **technical-writing** for docs, READMEs, RFCs, PR bodies.
- **writing-for-agents** — editing this file, a skill, or any `AGENTS.md` / `CLAUDE.md`.
- **codebase-design** — module interface design. **improve-codebase-architecture** — scan a repo for deepening opportunities.
- **handoff** — compact this conversation for another agent. **to-spec** / **to-tickets** — turn the discussion into a spec or tickets.

## Capture preferences

When I state a standing preference (toolchain, style, workflow, default device, always/never do X), notice it. Ask whether to add it to this file. Wait for a yes. One line per preference. Skip anything a linter, formatter, or project `AGENTS.md` already covers.

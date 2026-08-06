# dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
directory is a *package* whose internal layout mirrors `$HOME`, so
`stow zsh` links `zsh/.zshrc` to `~/.zshrc`.

## Setup

```sh
git clone <this-repo> ~/dotfiles
~/dotfiles/bootstrap.sh
```

`bootstrap.sh` stows every package and then wires up the shared agent-skill
store (see below). To manage a single package by hand:

```sh
cd ~/dotfiles
stow kitty          # link it
stow -D kitty       # unlink it
stow -R kitty       # relink after adding files
```

## Packages

| Package | Links to | What it is |
| --- | --- | --- |
| `zsh` | `~/.zshrc`, `~/.zshenv`, `~/.p10k.zsh` | Shell + powerlevel10k prompt |
| `bash` | `~/.bashrc`, `~/.bash_profile`, `~/.profile`, `~/.bash_logout` | Fallback shell |
| `git` | `~/.gitconfig` | Identity + `gh` credential helper |
| `gh` | `~/.config/gh/config.yml` | GitHub CLI prefs. `hosts.yml` is gitignored — it holds the OAuth token |
| `kitty` | `~/.config/kitty/` | Terminal |
| `nvim` | `~/.config/nvim/` | Neovim (lua config, lazy-style layout) |
| `micro` | `~/.config/micro/` | micro editor + catppuccin schemes |
| `fastfetch` | `~/.config/fastfetch/` | Fetch tool |
| `opencode` | `~/.config/opencode/` | opencode config + plugin manifest |
| `claude` | `~/.claude/` | Claude Code settings + plugin manifests |
| `agents` | `~/.agents/` | Shared agent skill lockfile |
| `skills` | `~/.local/share/agent-skills/` | **Canonical agent skill store** — see below |
| `plasma` | `~/.config/` | KDE Plasma: kwin, shortcuts, panel layout, app configs |

`waybar/` is present but **not stowed** — it targets `~/waybar` rather than
`~/.config/waybar`, and this machine runs KDE Plasma rather than a wlroots
compositor. Fix the package layout before adding it to `bootstrap.sh`.

## Agent skills

Claude Code, opencode, and `~/.agents` each expect a `skills/` directory at a
fixed path. Those three are plain relative symlinks created by `bootstrap.sh`, not by stow —
stow can only create links that point inside its own package tree.

**To add a skill:** drop it in `skills/.local/share/agent-skills/` and commit.
All three tools pick it up immediately; no relinking needed.

## Notes

- **Plasma rewrites its own config files.** KDE writes via a temp-file-and-rename
  which can replace a symlink with a regular file. If `~/.config/kwinrc` stops
  being a symlink, re-run `stow -R plasma` from this directory and re-commit.
  Treat the `plasma` package as a periodic snapshot, not a live mirror.
- **Secrets stay out.** No `~/.ssh`, `~/.gnupg`, `~/.claude.json`,
  `~/.claude/.credentials.json`, or `gh/hosts.yml`. Machine-local state
  (histories, caches, sessions, `node_modules`) is not tracked either.

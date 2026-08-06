#!/usr/bin/env bash
# Set up dotfiles on a fresh machine.
#
#   git clone <repo> ~/dotfiles && ~/dotfiles/bootstrap.sh
#
# Stow handles everything except the agent-skill fan-out: the three tools each
# expect a `skills` directory at a fixed path, and stow can't produce a symlink
# that points somewhere outside its own package tree. Those are linked here.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh bash git gh kitty nvim micro fastfetch opencode claude agents skills plasma)

command -v stow >/dev/null || { echo "gnu stow is not installed"; exit 1; }

echo "==> stowing: ${PACKAGES[*]}"
stow -d "$DOTFILES" -t "$HOME" "${PACKAGES[@]}"

# One canonical skill store, three consumers. Relative targets so the links
# survive a differently-named home directory.
echo "==> linking agent skills"
mkdir -p "$HOME/.claude" "$HOME/.agents" "$HOME/.config/opencode"
link_skills() {
  local dest=$1 target=$2
  [ -L "$dest" ] && rm "$dest"
  [ -e "$dest" ] && { echo "    skipping $dest (exists and is not a symlink)"; return; }
  ln -s "$target" "$dest"
  echo "    $dest -> $target"
}
link_skills "$HOME/.claude/skills"          "../.local/share/agent-skills"
link_skills "$HOME/.agents/skills"          "../.local/share/agent-skills"
link_skills "$HOME/.config/opencode/skills" "../../.local/share/agent-skills"

echo "==> done"

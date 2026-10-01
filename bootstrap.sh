#!/usr/bin/env bash
# Set up dotfiles on a fresh machine.
#
#   git clone <repo> ~/dotfiles && ~/dotfiles/bootstrap.sh
#
# Stow handles everything except the agent-skill fan-out: each tool expects a
# `skills` directory at a fixed path, but stow can't produce a symlink that
# points outside its own package tree. skills/fix-skills.sh handles that and
# also acts as a repair tool after any skill install/upgrade.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh bash git gh kitty nvim micro fastfetch opencode claude agents skills plasma)

command -v stow >/dev/null || { echo "gnu stow is not installed"; exit 1; }

echo "==> stowing: ${PACKAGES[*]}"
stow -d "$DOTFILES" -t "$HOME" "${PACKAGES[@]}"

# One canonical skill store, all consumers share it via relative symlinks.
# Relative targets survive a differently-named home directory.
echo "==> linking agent skills"
"$DOTFILES/skills/fix-skills.sh"

# System-level packages that must be stowed into /etc (requires sudo).
echo "==> stowing system packages (keyd → /etc)"
sudo stow -d "$DOTFILES" -t /etc keyd

echo "==> done"

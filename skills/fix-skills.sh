#!/usr/bin/env bash
# fix-skills.sh — ensure all agent harnesses share the one canonical skill store.
#
# Run after any skill install / upgrade, or as a bootstrap step:
#
#   ~/dotfiles/skills/fix-skills.sh
#
# What it does:
#   • Creates the required parent directories
#   • For each harness's skills path:
#       – If already the correct symlink  → prints OK, leaves it alone
#       – If a symlink with a wrong target → re-points it
#       – If a real directory             → backs it up then replaces with symlink
#       – If missing                      → creates the symlink
#
# Idempotent: safe to run at any time.

set -euo pipefail

CENTRAL="$HOME/.local/share/agent-skills"
BACKUP_STAMP=$(date +%Y%m%d-%H%M%S)

# Each entry: "symlink_path|relative_target_from_that_path"
LINKS=(
  "$HOME/.claude/skills|../.local/share/agent-skills"
  "$HOME/.agents/skills|../.local/share/agent-skills"
  "$HOME/.config/opencode/skills|../../.local/share/agent-skills"
  "$HOME/.cursor/skills|../.local/share/agent-skills"
  "$HOME/.pi/agent/skills|../../.local/share/agent-skills"
  "$HOME/.pi/skills|../.local/share/agent-skills"
)

# Canonical user AGENTS.md is stowed at ~/.agents/AGENTS.md.
# Each harness has its own global filename; all of these are the same file.
AGENTS_LINKS=(
  "$HOME/.claude/AGENTS.md|../.agents/AGENTS.md"
  "$HOME/.claude/CLAUDE.md|../.agents/AGENTS.md"
  "$HOME/.cursor/AGENTS.md|../.agents/AGENTS.md"
  "$HOME/.config/opencode/AGENTS.md|../../.agents/AGENTS.md"
  "$HOME/.config/zed/AGENTS.md|../../.agents/AGENTS.md"
  "$HOME/.pi/agent/AGENTS.md|../../.agents/AGENTS.md"
)

# Cursor GUI/CLI have no official user-level AGENTS.md. An always-apply
# rule under ~/.cursor/rules is the closest on-disk hook (Help documents
# it; CLI may only pick it up for workspaces under $HOME).
CURSOR_RULE_DEST="$HOME/.cursor/rules/personal.mdc"
CURSOR_RULE_BODY='---
description: Personal global agent instructions
alwaysApply: true
---

Follow `~/.agents/AGENTS.md`. Read it at session start if it is not already in context. A project `AGENTS.md` or `.cursor/rules` wins on conflict.
'

# ── helpers ────────────────────────────────────────────────────────────────────

green()  { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
red()    { printf '\033[31m%s\033[0m\n' "$*"; }

fix_link() {
  local dest=$1 target=$2
  local parent; parent=$(dirname "$dest")

  mkdir -p "$parent"

  # Resolve what the link *would* point to (for display purposes)
  local abs_target; abs_target=$(cd "$parent" && realpath -m "$target" 2>/dev/null || echo "?")

  # Already correct symlink?
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$target" ]; then
    green "  OK  $dest -> $target"
    return
  fi

  # Wrong-target symlink → just fix the target
  if [ -L "$dest" ]; then
    local old; old=$(readlink "$dest")
    rm "$dest"
    ln -s "$target" "$dest"
    yellow "  FIX $dest  (was -> $old, now -> $target)"
    return
  fi

  # Real directory → back it up and replace
  if [ -d "$dest" ]; then
    local bak="${dest}.bak-${BACKUP_STAMP}"
    mv "$dest" "$bak"
    ln -s "$target" "$dest"
    yellow "  BAK $dest → backed up to $bak, now -> $target"
    return
  fi

  # Doesn't exist → create it
  ln -s "$target" "$dest"
  green "  NEW $dest -> $target"
}

# ── verify central store exists ────────────────────────────────────────────────

if [ ! -d "$CENTRAL" ]; then
  red "ERROR: central skill store not found at $CENTRAL"
  red "Run 'stow -d ~/dotfiles -t ~ skills' first (or re-run bootstrap.sh)."
  exit 1
fi

echo "Central store: $CENTRAL"
echo "Skills: $(ls "$CENTRAL" | wc -l | tr -d ' ') packages"
echo ""

# ── apply each link ────────────────────────────────────────────────────────────

for entry in "${LINKS[@]}"; do
  dest="${entry%%|*}"
  target="${entry##*|}"
  fix_link "$dest" "$target"
done

echo ""
echo "AGENTS.md:"
for entry in "${AGENTS_LINKS[@]}"; do
  dest="${entry%%|*}"
  target="${entry##*|}"
  fix_link "$dest" "$target"
done

echo ""
echo "Cursor user rule:"
mkdir -p "$(dirname "$CURSOR_RULE_DEST")"
if [ -f "$CURSOR_RULE_DEST" ] && [ "$(cat "$CURSOR_RULE_DEST")" = "$CURSOR_RULE_BODY" ]; then
  green "  OK  $CURSOR_RULE_DEST"
else
  printf '%s' "$CURSOR_RULE_BODY" > "$CURSOR_RULE_DEST"
  green "  NEW $CURSOR_RULE_DEST  (alwaysApply pointer to ~/.agents/AGENTS.md)"
fi

echo ""
echo "All harnesses linked."

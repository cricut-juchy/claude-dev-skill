#!/bin/bash
# /dev skill installer for Claude Code
# Usage:
#   bash install.sh
#
# Idempotent — safe to re-run at any time.
# On update: removes old skill files first, then installs fresh from source.

set -e

SRC="./commands"
DEST="$HOME/.claude/commands"

if [ ! -d "$SRC" ]; then
  echo "Error: commands/ directory not found. Run this script from the repo root."
  exit 1
fi

# Detect fresh install vs update
if [ -f "$DEST/dev.md" ]; then
  echo "Existing /dev skill detected — updating..."
  rm -rf "$DEST/dev.md" "$DEST/dev"
else
  echo "Installing /dev skill..."
fi

mkdir -p "$DEST/dev"

# Copy all skill files from source
cp "$SRC/dev.md" "$DEST/dev.md"
for f in "$SRC"/dev/*.md; do
  cp "$f" "$DEST/dev/$(basename "$f")"
done

echo ""
echo "Done! Open Claude Code and type /dev to get started."

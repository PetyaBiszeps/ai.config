#!/usr/bin/env sh

set -eu

AI_CONFIG_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"

SOURCE="$AI_CONFIG_DIR/agents/skills"
TARGET="$HOME/.agents/skills"

echo "==> Linking agent skills"

mkdir -p "$HOME/.agents"

if [ -L "$TARGET" ]; then
  rm "$TARGET"
elif [ -e "$TARGET" ]; then
  echo "Error: $TARGET exists and is not a symlink"
  exit 1
fi

ln -s "$SOURCE" "$TARGET"

echo "==> Agent skills linked"

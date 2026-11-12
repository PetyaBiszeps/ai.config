#!/usr/bin/env sh

set -eu

AI_CONFIG_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"

. "$AI_CONFIG_DIR/scripts/utils/link.sh"

echo "==> Linking AI instructions"

link_path "$AI_CONFIG_DIR/instructions/AGENTS.md" "$HOME/.codex/AGENTS.md"
link_path "$AI_CONFIG_DIR/instructions/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

echo "==> Linking AI skills"

mkdir -p "$AI_CONFIG_DIR/skills"

link_path "$AI_CONFIG_DIR/skills" "$HOME/.agents/skills"
link_path "$AI_CONFIG_DIR/skills" "$HOME/.claude/skills"

echo "==> AI config applied"

#!/usr/bin/env sh

set -eu

PACKAGE="superpowers@openai-curated"

if ! command -v codex >/dev/null 2>&1; then
  echo "==> Skip: Codex CLI is not installed"
  exit 0
fi

if codex plugin list --json | grep -Eq '"pluginId"[[:space:]]*:[[:space:]]*"superpowers@[^"]+"'; then
  echo "==> Codex Superpowers already installed"
  exit 0
fi

echo "==> Installing Codex Superpowers"
codex plugin add "$PACKAGE"

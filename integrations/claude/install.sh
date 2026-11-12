#!/usr/bin/env sh

set -eu

PACKAGE="superpowers@claude-plugins-official"

if ! command -v claude >/dev/null 2>&1; then
  echo "==> Skip: Claude Code is not installed"
  exit 0
fi

INSTALLED="$(claude plugin list)"

if printf '%s\n' "$INSTALLED" | grep -Fq "$PACKAGE"; then
  echo "==> Claude Superpowers already installed"
  exit 0
fi

echo "==> Installing Claude Superpowers"
claude plugin install "$PACKAGE" --scope user

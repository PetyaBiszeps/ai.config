#!/usr/bin/env sh

set -eu

MARKETPLACE="superpowers-marketplace"
PACKAGE="superpowers@$MARKETPLACE"

if ! command -v claude >/dev/null 2>&1; then
  echo "==> Skip: Claude Code is not installed"
  exit 0
fi

if claude plugin list | grep -Fq "superpowers@"; then
  echo "==> Claude Superpowers already installed"
  exit 0
fi

if ! claude plugin marketplace list | grep -Fq "$MARKETPLACE"; then
  echo "==> Adding Superpowers marketplace"
  claude plugin marketplace add obra/superpowers-marketplace --scope user
fi

echo "==> Installing Claude Superpowers"
claude plugin install "$PACKAGE" --scope user

#!/usr/bin/env sh

set -eu

PACKAGE="npm:pi-superpowers-plus"

if ! command -v pi >/dev/null 2>&1; then
  echo "Error: Pi is not installed" >&2
  exit 1
fi

if pi list | grep -Fq "$PACKAGE"; then
  echo "==> Pi Superpowers Plus already installed"
  exit 0
fi

echo "==> Installing Pi Superpowers Plus"
pi install "$PACKAGE"

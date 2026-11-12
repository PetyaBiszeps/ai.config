#!/usr/bin/env sh

set -eu

AI_CONFIG_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"

for cli in pi codex claude; do
  echo "==> Installing $cli integrations"
  sh "$AI_CONFIG_DIR/integrations/$cli/install.sh"
done

echo "==> Integrations installed"

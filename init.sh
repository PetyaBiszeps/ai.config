#!/usr/bin/env sh

set -eu

AI_CONFIG_DIR="$(cd "$(dirname "$0")" && pwd -P)"

echo "==> Installing AI tools"
sh "$AI_CONFIG_DIR/scripts/download.sh"

echo "==> Done"

#!/usr/bin/env sh

set -eu

install_macos() {
  echo "==> Installing packages for macOS"
  brew install \
    pi-coding-agent
}

install_arch() {
  echo "==> Installing packages for Arch Linux"
  yay -S --needed --noconfirm --answerclean None --answerdiff None \
    pi-coding-agent-bin
}

case "$(uname -s)" in
  Darwin)
    install_macos
    ;;

  Linux)
    install_arch
    ;;

  *)
    echo "Unsupported operating system: $(uname -s)"
    exit 1
    ;;
esac

echo "==> Done"

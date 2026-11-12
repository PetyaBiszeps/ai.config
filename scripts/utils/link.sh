#!/usr/bin/env sh

link_path() {
  source="$1"
  target="$2"

  if [ ! -e "$source" ]; then
    echo "Skip: source does not exist: $source"
    return 0
  fi

  if [ -L "$target" ]; then
    if [ "$(readlink "$target")" = "$source" ]; then
      echo "Already linked: $target"
      return 0
    fi

    rm "$target"
  elif [ -e "$target" ]; then
    echo "Error: $target exists and is not a symlink" >&2
    return 1
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"

  echo "Linked: $target -> $source"
}

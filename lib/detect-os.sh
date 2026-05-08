#!/usr/bin/env bash
# Sets OS_KIND to one of: macos, wsl, linux
# Sourced by bootstrap.sh and apt-packages.sh.

case "$(uname -s)" in
  Darwin)
    OS_KIND=macos
    ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      OS_KIND=wsl
    else
      OS_KIND=linux
    fi
    ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    return 1 2>/dev/null || exit 1
    ;;
esac

export OS_KIND

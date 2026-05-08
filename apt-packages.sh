#!/usr/bin/env bash
# Install apt prereqs needed before brew can take over.
# Everything else (direnv, gh, jq, etc.) comes from the Brewfile so versions
# stay aligned across machines.

set -euo pipefail

source "$(dirname "$0")/lib/detect-os.sh"

if [[ "$OS_KIND" == "macos" ]]; then
  echo "apt-packages.sh: skipping on macOS"
  exit 0
fi

sudo apt-get update -y
sudo apt-get install -y \
  build-essential \
  curl \
  git \
  zsh \
  unzip \
  ca-certificates \
  procps \
  file

if [[ "$OS_KIND" == "wsl" ]]; then
  sudo apt-get install -y wslu
fi

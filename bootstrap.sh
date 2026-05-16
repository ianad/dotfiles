#!/usr/bin/env bash
# Portable dev-environment bootstrap.
#
# Curl-and-run:
#   curl -fsSL https://raw.githubusercontent.com/ianad/dotfiles/main/bootstrap.sh | bash
#
# Or, after the repo is cloned:
#   bash ~/dotfiles/bootstrap.sh
#
# Idempotent. Safe to re-run.

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/ianad/dotfiles}"
CLAUDE_REPO="${CLAUDE_REPO:-https://github.com/ianad/.claude}"
BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }

# ---- 1. Detect OS ------------------------------------------------------------
# When piped from curl the repo isn't on disk yet, so source detect-os.sh from
# the raw URL. After the clone it's available locally.
if [[ -f "$DOTFILES_DIR/lib/detect-os.sh" ]]; then
  # shellcheck disable=SC1091
  source "$DOTFILES_DIR/lib/detect-os.sh"
else
  # shellcheck disable=SC1090
  source <(curl -fsSL "$DOTFILES_REPO/raw/main/lib/detect-os.sh")
fi
log "Detected OS: $OS_KIND"

# ---- 2. Ensure git + curl ----------------------------------------------------
case "$OS_KIND" in
  macos)
    if ! xcode-select -p >/dev/null 2>&1; then
      log "Installing Xcode Command Line Tools (will prompt)"
      xcode-select --install || true
    fi
    ;;
  wsl|linux)
    if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
      log "Installing git/curl via apt"
      sudo apt-get update -y
      sudo apt-get install -y git curl ca-certificates
    fi
    ;;
esac

# ---- 3. Clone dotfiles repo --------------------------------------------------
if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
  log "Cloning $DOTFILES_REPO to $DOTFILES_DIR"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  log "Dotfiles repo already at $DOTFILES_DIR"
fi

# ---- 4. apt prereqs (Linux only) --------------------------------------------
if [[ "$OS_KIND" != "macos" ]]; then
  log "Running apt-packages.sh"
  bash "$DOTFILES_DIR/apt-packages.sh"
fi

# ---- 5. Homebrew -------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Activate brew in this shell (portable across Apple Silicon, Intel, Linuxbrew)
for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [[ -x "$brew_path" ]]; then
    eval "$("$brew_path" shellenv)"
    break
  fi
done

# ---- 6. brew bundle ----------------------------------------------------------
log "Running brew bundle"
brew bundle --file="$DOTFILES_DIR/Brewfile"

# ---- 6b. Python CLI tools (via uv, which brew bundle just installed) --------
# `uv tool install` is idempotent — re-running is a no-op when up to date.
if command -v uv >/dev/null 2>&1; then
  log "Installing Python CLI tools via uv"
  uv tool install dbt-core --with dbt-snowflake
fi

# ---- 7. oh-my-zsh ------------------------------------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
fi

# ---- 8. ~/.claude ------------------------------------------------------------
if [[ ! -d "$HOME/.claude/.git" ]]; then
  log "Cloning $CLAUDE_REPO to ~/.claude"
  git clone "$CLAUDE_REPO" "$HOME/.claude"
else
  log "~/.claude already present"
fi
if [[ -x "$HOME/.claude/setup-plugins.sh" ]]; then
  log "Running ~/.claude/setup-plugins.sh"
  bash "$HOME/.claude/setup-plugins.sh"
else
  warn "~/.claude/setup-plugins.sh not found or not executable; skipping"
fi

# ---- 9. Back up conflicts and stow ------------------------------------------
backup_conflicts() {
  local src="$1" target="$2" backup="$3"
  local rel real
  while IFS= read -r -d '' f; do
    rel="${f#$src/}"
    if [[ -e "$target/$rel" || -L "$target/$rel" ]]; then
      real="$(readlink -f "$target/$rel" 2>/dev/null || true)"
      # Already a symlink into the dotfiles repo? leave it alone.
      if [[ "$real" == "$f" ]]; then
        continue
      fi
      mkdir -p "$backup/$(dirname "$rel")"
      mv "$target/$rel" "$backup/$rel"
      warn "backed up $target/$rel -> $backup/$rel"
    fi
  done < <(find "$src" -type f -print0)
}

mkdir -p "$BACKUP_DIR"
backup_conflicts "$DOTFILES_DIR/home" "$HOME" "$BACKUP_DIR"
# Drop empty backup dir to keep things tidy when nothing was moved.
rmdir "$BACKUP_DIR" 2>/dev/null || true

log "Stowing dotfiles into \$HOME"
stow -d "$DOTFILES_DIR" -t "$HOME" home

# ---- 10. Done ----------------------------------------------------------------
log "All done. Restart your shell:  exec zsh"

# ~/.zshrc — managed by ~/dotfiles (stowed). Edit the source, not the symlink.

# ---- oh-my-zsh ---------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
# Custom theme lives at ~/.oh-my-zsh/custom/themes/cognician.zsh-theme (stowed).
# Falls back to robbyrussell if the custom theme isn't present yet.
if [[ -f "$ZSH/custom/themes/cognician.zsh-theme" ]]; then
  ZSH_THEME="cognician"
else
  ZSH_THEME="robbyrussell"
fi
plugins=(git npm)
source $ZSH/oh-my-zsh.sh

# Suppress brew's "you can opt out of analytics" / cleanup hints.
export HOMEBREW_NO_ENV_HINTS=1

# ---- Homebrew (portable: Apple Silicon, Intel, Linuxbrew) -------------------
for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [[ -x "$brew_path" ]]; then
    eval "$($brew_path shellenv)"
    break
  fi
done

# ---- PATH --------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"
[[ -d "$HOME/.lmstudio/bin" ]] && export PATH="$HOME/.lmstudio/bin:$PATH"

# Java (openjdk@17 via brew) — only if installed
if [[ -n "${HOMEBREW_PREFIX:-}" && -d "$HOMEBREW_PREFIX/opt/openjdk@17/bin" ]]; then
  export PATH="$HOMEBREW_PREFIX/opt/openjdk@17/bin:$PATH"
fi

# ---- NVM (brew install if available, else standalone $HOME/.nvm) ------------
export NVM_DIR="$HOME/.nvm"
if [[ -n "${HOMEBREW_PREFIX:-}" && -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]]; then
  source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
  [[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ]] && \
    source "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi

# ---- Bun ---------------------------------------------------------------------
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  [[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
fi

# ---- direnv ------------------------------------------------------------------
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# ---- thefuck -----------------------------------------------------------------
command -v thefuck >/dev/null && eval "$(thefuck --alias)"

# ---- WSL niceties ------------------------------------------------------------
if grep -qi microsoft /proc/version 2>/dev/null; then
  alias ii=explorer.exe
fi

# ---- claude → ccs profile routing -------------------------------------------
# direnv (.envrc) per project sets $CCS_PROFILE; this dispatches `claude` to
# the right ccs workspace. With no profile set, fall back to default ccs.
function claude() {
  if [[ -n $CCS_PROFILE ]]; then
    echo "Using CCS Profile: $CCS_PROFILE"
    ccs "$CCS_PROFILE" "$@"
  else
    echo "No CCS Profile set, using default profile"
    command "ccs" "$@"
  fi
}

# ---- code() — resolve relative paths to absolute before launching VSCode ----
function code() {
  local args=()
  local arg
  for arg in "$@"; do
    if [[ -e "$arg" ]]; then
      args+=("${arg:A}")
    else
      args+=("$arg")
    fi
  done
  command code "${args[@]}"
}

# ---- Machine-local overrides & secrets (gitignored, not stowed) -------------
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

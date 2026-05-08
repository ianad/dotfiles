# Brewfile — declarative package list, applied via `brew bundle`.
# Works on macOS and Linuxbrew. Run via bootstrap.sh or:
#   brew bundle --file=~/dotfiles/Brewfile

# ---- Load-bearing for this dotfiles repo ------------------------------------
brew "stow"          # symlink farm — bootstrap.sh uses this to deploy ~/
brew "direnv"        # per-directory env, drives $CCS_PROFILE -> claude() routing

# ---- Core CLI ---------------------------------------------------------------
brew "git"
brew "gh"
brew "jq"
brew "fzf"
brew "ripgrep"
brew "bat"
brew "zsh"           # newer than the system zsh on most distros

# ---- Python -----------------------------------------------------------------
brew "python@3.13"
brew "uv"            # per AGENTS.md: default Python toolchain

# ---- Node (managed via NVM, not brew node) ----------------------------------
brew "nvm"

# ---- Compilers / build ------------------------------------------------------
brew "gcc"

# ---- Cloud / deployment -----------------------------------------------------
brew "awscli"
brew "aws-sam-cli"
brew "vercel-cli"
brew "snowflake-cli"

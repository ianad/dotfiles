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
brew "tmux"
brew "just"          # command runner
brew "thefuck"       # command-typo corrector (aliased in .zshrc)
brew "bfg"           # bulk git history rewriter
brew "magic-wormhole"

# ---- Python -----------------------------------------------------------------
brew "python@3.13"
brew "uv"            # per AGENTS.md: default Python toolchain

# ---- Node (managed via NVM, not brew node) ----------------------------------
brew "nvm"
brew "pnpm"

# ---- JVM / Java -------------------------------------------------------------
brew "openjdk@17"

# ---- Data / DB --------------------------------------------------------------
brew "duckdb"
brew "postgresql@14"
tap  "dbt-labs/dbt-cli"
brew "dbt-labs/dbt-cli/dbt"

# ---- AI dev tooling ---------------------------------------------------------
brew "opencode"

# ---- Compilers / build ------------------------------------------------------
brew "gcc"

# ---- Cloud / deployment -----------------------------------------------------
brew "awscli"
brew "aws-sam-cli"
brew "vercel-cli"
brew "snowflake-cli"

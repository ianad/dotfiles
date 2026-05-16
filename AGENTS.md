# CLAUDE.md / AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. `CLAUDE.md` is a symlink to `AGENTS.md` — edit `AGENTS.md`.

## What this repo is

Portable dev-environment dotfiles for macOS, Linux, and WSL. A single curl-and-run `bootstrap.sh` brings a fresh machine to a usable state; day-to-day changes flow through GNU stow.

## Common commands

| Task                              | Command                                    |
| --------------------------------- | ------------------------------------------ |
| Bootstrap or re-bootstrap         | `bash ~/dotfiles/bootstrap.sh`             |
| Re-stow (only when adding files)  | `stow -d ~/dotfiles -t ~ home`             |
| Un-stow / rollback symlinks       | `stow -D -d ~/dotfiles -t ~ home`          |
| Apply Brewfile changes            | `brew bundle --file=~/dotfiles/Brewfile`   |
| Apply apt changes (Linux/WSL)     | `bash ~/dotfiles/apt-packages.sh`          |

There is no build, lint, or test step. Shell scripts run under `set -euo pipefail`.

## Architecture

**Stow-based deployment.** Files under `home/` are GNU-stow targets — they become symlinks in `$HOME`. Editing the file via the repo path or via its symlink updates the same inode; re-stow only when adding or removing files. `.stow-local-ignore` keeps non-dotfile assets (`README.md`, `bootstrap.sh`, `Brewfile`, `apt-packages.sh`, `lib/`) out of the stow set — extend it when adding new top-level non-dotfile artifacts.

**Bootstrap flow (`bootstrap.sh`).** Idempotent and safe to re-run. Source `lib/detect-os.sh` to get `$OS_KIND` (`macos` | `wsl` | `linux`), then: ensure git/curl → clone this repo to `~/dotfiles` → run `apt-packages.sh` on Linux → install Homebrew → `brew bundle` → install oh-my-zsh → clone `~/.claude` and run its `setup-plugins.sh` → back up conflicting `$HOME` files to `~/.dotfiles-backup/<timestamp>/` → `stow home`. Anything new added to this script must preserve idempotency.

**OS branching.** Always source `lib/detect-os.sh` and switch on `$OS_KIND` rather than re-detecting. Linux-only logic (apt, wslu) belongs in `apt-packages.sh`; everything cross-platform belongs in the Brewfile.

**`claude()` router (`home/.zshrc`).** Shell function that reads `$CCS_PROFILE` (set by direnv via per-project `.envrc`) and dispatches `claude` to the matching `ccs` workspace. Enable a workspace per project by dropping an `.envrc` with `export CCS_PROFILE=<name>` and running `direnv allow`.

**External dependency.** `~/.claude` is a separate repo (`https://github.com/ianad/.claude`) cloned by bootstrap; its `setup-plugins.sh` runs automatically. The plugin manifest lives there, not here.

## Adding things

- New CLI tool available on macOS + Linuxbrew → `Brewfile`.
- Linux-only system package → `apt-packages.sh`.
- Python CLI tool (e.g., dbt Core) → `uv tool install` line in `bootstrap.sh` step 6b, not the Brewfile.
- New dotfile → drop under `home/<relative-path>` and re-stow.
- Shell helper shared by multiple scripts → `lib/` and source it.

## Gotchas

- On first bootstrap, real files in `$HOME` that clash with stow targets get moved to `~/.dotfiles-backup/<timestamp>/`, not deleted. Empty backup dirs get pruned. A pre-existing `~/.zshrc` becomes a symlink to `home/.zshrc` after bootstrap — machine-local edits (secrets, host-specific PATHs, one-off aliases) belong in `~/.zshrc.local`, which `home/.zshrc` sources at the end and is never stowed.
- `home/.gitconfig` uses `gh auth git-credential` as the credential helper, so `gh auth login` must have run before git pushes against GitHub work.
- `home/.zshrc` activates Homebrew portably by probing the three known shellenv paths (Apple Silicon, Intel, Linuxbrew). Shell config that depends on `$HOMEBREW_PREFIX` (e.g., `openjdk@17` PATH) must come after that block.
- Custom oh-my-zsh themes live under `home/.oh-my-zsh/custom/themes/` (stows to `~/.oh-my-zsh/custom/themes/`). Never place them under `~/.oh-my-zsh/themes/` — that's inside the oh-my-zsh git checkout and gets clobbered on `omz update`. `home/.zshrc` selects the `cognician` theme when its file is present and falls back to `robbyrussell` otherwise, so a partial deployment still gives a working prompt.

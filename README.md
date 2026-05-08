# dotfiles

Portable dev environment for macOS and Linux (including WSL).

## Bootstrap a fresh machine

```bash
curl -fsSL https://raw.githubusercontent.com/ianad/dotfiles/main/bootstrap.sh | bash
exec zsh
```

The bootstrap is idempotent — safe to re-run.

## What it does

1. Detects OS (`macos` / `wsl` / `linux`).
2. Installs Xcode CLT (macOS) or `git`, `curl`, `build-essential`, `zsh`, `wslu`, etc. (Linux).
3. Clones this repo to `~/dotfiles`.
4. Installs Homebrew if missing.
5. Runs `brew bundle` against `Brewfile` (stow, direnv, gh, ripgrep, uv, …).
6. Installs oh-my-zsh.
7. Clones `~/.claude` (a separate repo) and runs its `setup-plugins.sh`.
8. Backs up any conflicting files in `$HOME` to `~/.dotfiles-backup/<timestamp>/`.
9. Symlinks `home/*` into `$HOME` via GNU stow.

## Layout

| Path                              | Purpose                                                       |
| --------------------------------- | ------------------------------------------------------------- |
| `bootstrap.sh`                    | curl-and-run entrypoint                                       |
| `Brewfile`                        | declarative brew package list                                 |
| `apt-packages.sh`                 | apt prereqs (Linux only) — minimal, just enough to run brew   |
| `lib/detect-os.sh`                | sourced helper, sets `$OS_KIND`                               |
| `home/`                           | stowed into `$HOME`                                           |
| `home/.zshrc`                     | shell config (oh-my-zsh, direnv, NVM, `claude()` router)      |
| `home/.zshenv`                    | minimal env for non-interactive shells                        |
| `home/.gitconfig`                 | git config + gh credential helper                             |
| `home/.config/direnv/direnvrc`    | direnv customizations (currently empty stub)                  |

## The `claude()` router

`~/.zshrc` defines a `claude()` function that reads `$CCS_PROFILE` from direnv
and dispatches to the right `ccs` workspace. Drop a `.envrc` in any project:

```bash
echo 'export CCS_PROFILE=cognician' > .envrc
direnv allow
```

…and `claude` in that directory automatically uses the `cognician` profile.

## Adding a tool

- Brew package → add to `Brewfile`, run `brew bundle`.
- New dotfile → drop it in `home/`, re-run `bootstrap.sh` (or just `stow -d ~/dotfiles -t ~ home`).
- System (apt) package → add to `apt-packages.sh`, re-run it.

## Re-stowing after edits

Stow uses symlinks, so editing `~/.zshrc` edits the file in this repo. No
re-stow needed for content changes. Re-stow only when adding/removing files:

```bash
stow -d ~/dotfiles -t ~ home
```

## Conflict / rollback

On first run, anything in `$HOME` that would clash gets moved to
`~/.dotfiles-backup/<timestamp>/`. To roll back the whole thing:

```bash
stow -D -d ~/dotfiles -t ~ home   # remove symlinks
# restore backup contents from ~/.dotfiles-backup/<timestamp>/ as needed
```

## Repos this depends on

- `~/.claude` → <https://github.com/ianad/.claude> (cloned by bootstrap)

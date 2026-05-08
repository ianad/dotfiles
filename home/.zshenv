# ~/.zshenv — sourced for ALL zsh invocations (interactive, scripts, ssh).
# Keep this minimal: just enough so non-interactive shells can find user bins.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

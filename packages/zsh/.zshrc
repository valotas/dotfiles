#
# Executes commands at the start of an interactive session.
#

# Cursor agent shells: keep mise/PATH, skip interactive zsh niceties.
if [[ -n "$CURSOR_AGENT" ]]; then
  [[ -s "$HOME/.dotfiles/sh_setup.sh" ]] && source "$HOME/.dotfiles/sh_setup.sh"
  return
fi

_zsh_interactive="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/interactive.zsh"
[[ -s "$_zsh_interactive" ]] && source "$_zsh_interactive"
unset _zsh_interactive
[[ -s "$HOME/.dotfiles/sh_aliases.sh" ]] && source "$HOME/.dotfiles/sh_aliases.sh"
[[ -s "$HOME/.dotfiles/sh_setup.sh" ]] && source "$HOME/.dotfiles/sh_setup.sh"

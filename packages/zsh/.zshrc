#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
[[ -s "$HOME/.dotfiles/sh_aliases.sh" ]] && source "$HOME/.dotfiles/sh_aliases.sh"
[[ -s "$HOME/.dotfiles/sh_setup.sh" ]] && source "$HOME/.dotfiles/sh_setup.sh"
  
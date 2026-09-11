# ~/.bash_profile: executed by bash for login shells.
# Login bash skips ~/.profile when this file exists, so source ~/.bashrc
# when present (Ubuntu/Fedora). Do not own ~/.bashrc.

# for debugging
export _VALOTAS_ENV_COUNTER="${_VALOTAS_ENV_COUNTER}[bash_profile]"

. "$HOME/.dotfiles/sh_env.sh"

if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
else
  [ -f "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

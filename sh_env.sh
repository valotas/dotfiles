# this should be sourced in .profile and/or .zenv:
# [[ -s "$HOME/.dotfiles/env.sh" ]] && . "$HOME/.dotfiles/env.sh"

# for debugging
export _VALOTAS_ENV_COUNTER="${_VALOTAS_ENV_COUNTER}[e]"

export DOTFILES_DIR="$HOME/.dotfiles"
export ZPREZTODIR="$DOTFILES_DIR/prezto"

#
# Editors
#

export SYSTEMD_EDITOR="vim"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then # SSH mode
  export EDITOR='vim'
else # Local terminal mode
  export EDITOR='code -w'
fi

if [[ -z "$PAGER" ]]; then
  export PAGER='less'
fi

export VISUAL="$EDITOR"

# football-data.org stuff
export FOOTBALL_DATA_ORG_TOKEN="5ecd3132cf3b4299b70e7229192a49bd"
export FOOTBALL_DATA_ORG_USER="valotas@gmail.com"

# flyctl
if [[ -f "$HOME/.fly/bin/flyctl" ]]; then
  export FLYCTL_INSTALL="$HOME/.fly"
  export -U PATH=$FLYCTL_INSTALL/bin${PATH:+:$PATH}
fi


# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
if [ -d "$PNPM_HOME" ]; then
  export PATH=$PNPM_HOME:${PATH:+:$PATH}
  alias pn=pnpm
fi
# pnpm end

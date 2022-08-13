# this should be sourced in .profile and/or .zenv:
# [[ -s "$HOME/.dotfiles/env.sh" ]] && . "$HOME/.dotfiles/env.sh"

export SYSTEMD_EDITOR="vim"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then # SSH mode
  export EDITOR='vim'
else # Local terminal mode
  export EDITOR='code -w'
fi

export VISUAL="$EDITOR"

# football-data.org stuff
export FOOTBALL_DATA_ORG_TOKEN="5ecd3132cf3b4299b70e7229192a49bd"
export FOOTBALL_DATA_ORG_USER="valotas@gmail.com"

# sdkman
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# for debugging
export VALOTAS_VERSION="$HOME/.dotfiles/env.sh"

# flyctl
if [[ -f "$HOME/.fly/bin/flyctl" ]]; then
  export FLYCTL_INSTALL="$HOME/.fly"
  export -U PATH=$FLYCTL_INSTALL/bin${PATH:+:$PATH}
fi

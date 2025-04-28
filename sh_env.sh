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

function add_to_path {
    PATH=:$PATH
    export PATH=$1${PATH//:$1:/:}
}

# flyctl
if [[ -f "$HOME/.fly/bin/flyctl" ]]; then
  export FLYCTL_INSTALL="$HOME/.fly"
  add_to_path "$FLYCTL_INSTALL/bin"
fi


# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
if [ -d "$PNPM_HOME" ]; then
  export PATH=$PNPM_HOME:${PATH:+:$PATH}
  alias pn=pnpm
fi

# set CHROME_BIN to the path of the chrome binary
[[ $(command -v chromium) ]] && [[ -z "$CHROME_BIN" ]] && export CHROME_BIN=$(command -v chromium)

[[ -d "$HOME/.local/bin" ]] && add_to_path "$HOME/.local/bin"

# Android Studio commandline tools for MacOs
ANDROID_HOME=$HOME/Library/Android/sdk
ANDROID_CLI=$ANDROID_HOME/cmdline-tools/latest/bin
if [[ -d "$ANDROID_CLI" ]]; then
  export ANDROID_HOME
  add_to_path "$ANDROID_CLI:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"
fi

if [[ -f "$HOME/.config/local_env.sh" ]]; then
  source "$HOME/.config/local_env.sh"
fi

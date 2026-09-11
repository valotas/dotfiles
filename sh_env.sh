# Sourced from zshenv, bash_profile, bash_aliases, and sh_setup.sh.
[ -n "${_VALOTAS_ENV_SOURCED:-}" ] && return 0
_VALOTAS_ENV_SOURCED=1

# for debugging
export _VALOTAS_ENV_COUNTER="${_VALOTAS_ENV_COUNTER}[e]"

export DOTFILES_DIR="$HOME/.dotfiles"

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
  [ -n "$1" ] || return 0
  PATH=:$PATH
  export PATH=$1${PATH//:$1:/:}
}

[[ -d /opt/homebrew/bin ]] && add_to_path /opt/homebrew/bin
[[ -d "$HOME/.local/bin" ]] && add_to_path "$HOME/.local/bin"

# mise: one-shot PATH and env (PNPM_HOME, JAVA_HOME, tool bins).
# Interactive cwd/prompt hooks stay in sh_setup.sh (`mise activate`).
if command -v mise >/dev/null 2>&1; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(mise env -s zsh)"
  elif [ -n "${BASH_VERSION:-}" ]; then
    eval "$(mise env -s bash)"
  fi
fi

# pnpm global binaries: derive the dir from pnpm itself (after mise).
# `pnpm bin -g` refuses to print until that directory is already on PATH, so
# fall back to $PNPM_HOME/bin (pnpm's default global bin location).
if command -v pnpm >/dev/null 2>&1; then
  pnpm_bin="$(pnpm bin -g 2>/dev/null)"
  [ -z "$pnpm_bin" ] && [ -n "${PNPM_HOME:-}" ] && pnpm_bin="$PNPM_HOME/bin"
  [ -n "$pnpm_bin" ] && [ -d "$pnpm_bin" ] && add_to_path "$pnpm_bin"
  unset pnpm_bin
fi

# Consumed by the starship prompt; init stays in sh_setup.sh.
if [ "$(hostname -s)" = "m4air" ]; then
  export STARSHIP_MAIN_HOST=1
fi

# flyctl
if [[ -f "$HOME/.fly/bin/flyctl" ]]; then
  export FLYCTL_INSTALL="$HOME/.fly"
  add_to_path "$FLYCTL_INSTALL/bin"
fi

# set CHROME_BIN to the path of the chrome binary
[[ $(command -v chromium) ]] && [[ -z "$CHROME_BIN" ]] && export CHROME_BIN=$(command -v chromium)

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

if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

if [[ -d "$HOME/.cargo/bin" ]]; then
  add_to_path "$HOME/.cargo/bin"
fi

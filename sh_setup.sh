# Interactive hooks only. Env lives in sh_env.sh; source it in case this
# file is the first drop-in (Ubuntu ~/.bash_aliases, Fedora ~/.bashrc.d).
. "$HOME/.dotfiles/sh_env.sh"

case $- in
  *i*) ;;
  *) return 0 ;;
esac

[ -n "${_VALOTAS_SETUP_SOURCED:-}" ] && return 0
_VALOTAS_SETUP_SOURCED=1

export _VALOTAS_ENV_COUNTER="${_VALOTAS_ENV_COUNTER}[s]"

# mise (activate runs hook-env now and on cwd/prompt changes)
if command -v mise >/dev/null 2>&1; then
  [ -n "${BASH_VERSION:-}" ] && eval "$(mise activate bash)"
  [ -n "${ZSH_VERSION:-}" ] && eval "$(mise activate zsh)"
# vfox
elif command -v vfox >/dev/null 2>&1; then
  [ -n "${BASH_VERSION:-}" ] && eval "$(vfox activate bash)"
  [ -n "${ZSH_VERSION:-}" ] && eval "$(vfox activate zsh)"
fi

# starship
if [[ -z "$CURSOR_AGENT" ]] && command -v starship >/dev/null 2>&1; then
  [ -n "${BASH_VERSION:-}" ] && eval "$(starship init bash)"
  [ -n "${ZSH_VERSION:-}" ] && eval "$(starship init zsh)"
fi

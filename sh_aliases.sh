# for debugging
export _VALOTAS_ENV_COUNTER="${_VALOTAS_ENV_COUNTER}[a]"

alias la="ls -al"

if [[ -f "$HOME/.config/local_aliases.sh" ]]; then
  source "$HOME/.config/local_aliases.sh"
fi

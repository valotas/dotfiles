export _VALOTAS_ENV_COUNTER="${_VALOTAS_ENV_COUNTER}[s]"

# check the current shell (will be the full path of the shell)
shell="$(ps -p $$ -o comm=)"

# mise
if [[ $(command -v mise) ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
  export PATH="$HOME/.local/share/mise/shims:$PATH"
# vfox
elif [[ $(command -v vfox) ]]; then
  [[ $shell == *"bash" ]] && eval "$(vfox activate bash)"
  [[ $shell == *"zsh" ]] && eval "$(vfox activate zsh)"
fi

# starship
if [[ -z "$CURSOR_AGENT" && $(command -v starship) ]]; then
  # Show username@hostname when not on m4air
  if [[ "$(hostname -s)" == "m4air" ]]; then
    export STARSHIP_MAIN_HOST=1
  fi

  [[ $shell == *"bash" ]] && eval "$(starship init bash)"
  [[ $shell == *"zsh" ]] && eval "$(starship init zsh)"
fi

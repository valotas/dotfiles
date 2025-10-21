export _VALOTAS_ENV_COUNTER="${_VALOTAS_ENV_COUNTER}[s]"

# sdkman
sdkman="$HOME/.sdkman"
if [[ -s "$sdkman/bin/sdkman-init.sh" ]]; then
  source "$sdkman/bin/sdkman-init.sh"
  export SDKMAN_DIR="$sdkman"
fi

# nvm
[[ -s "$HOME/.nvm/nvm.sh" ]] && source "$HOME/.nvm/nvm.sh"  # This loads NVM

# check the current shell (will be the full path of the shell)
shell="$(ps -p $$ -o comm=)"

# vfox
if [[ $(command -v vfox) ]]; then 
  [[ $shell == *"bash" ]] && eval "$(vfox activate bash)"
  [[ $shell == *"zsh" ]] && eval "$(vfox activate zsh)"
fi

# starship
if [[ $(command -v starship) ]]; then
  # Show username@hostname when not on m4air
  if [[ "$(hostname -s)" != "m4air" ]]; then
    export STARSHIP_SHOW_PROMPT_DETAILS=1
  fi
  
  [[ $shell == *"bash" ]] && eval "$(starship init bash)"
  [[ $shell == *"zsh" ]] && eval "$(starship init zsh)"
fi

export _VALOTAS_ENV_COUNTER="${_VALOTAS_ENV_COUNTER}[s]"

# sdkman
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# nvm
[[ -s "$HOME/.nvm/nvm.sh" ]] && source "$HOME/.nvm/nvm.sh"  # This loads NVM

# vfox
if [[ $(command -v vfox) ]]; then 
  shell="$(ps -p $$ -o comm=)"
  [[ $shell == *"bash" ]] && eval "$(vfox activate bash)"
  [[ $shell == *"zsh" ]] && eval "$(vfox activate zsh)"
fi

# starship
if [[ $(command -v starship) ]]; then
  shell="$(ps -p $$ -o comm=)"
  [[ $shell == *"bash" ]] && eval "$(starship init bash)"
  [[ $shell == *"zsh" ]] && eval "$(starship init zsh)"
fi

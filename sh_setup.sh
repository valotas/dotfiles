export _VALOTAS_ENV_COUNTER="${_VALOTAS_ENV_COUNTER}[s]"

# sdkman
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# nvm
[[ -z "$NVM_BIN" ]] && [[ -s "$HOME/.nvm/nvm.sh" ]] && source "$HOME/.nvm/nvm.sh"  # This loads NVM

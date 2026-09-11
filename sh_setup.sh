export _VALOTAS_ENV_COUNTER="${_VALOTAS_ENV_COUNTER}[s]"

# check the current shell (will be the full path of the shell)
shell="$(ps -p $$ -o comm=)"

# mise (activate runs hook-env now and on cwd/prompt changes)
if [[ $(command -v mise) ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
  [[ $shell == *"bash" ]] && eval "$(mise activate bash)"
  [[ $shell == *"zsh" ]] && eval "$(mise activate zsh)"
# vfox
elif [[ $(command -v vfox) ]]; then
  [[ $shell == *"bash" ]] && eval "$(vfox activate bash)"
  [[ $shell == *"zsh" ]] && eval "$(vfox activate zsh)"
fi

# pnpm global binaries: derive the dir from pnpm itself (after mise/vfox).
if [[ $(command -v pnpm) ]]; then
  pnpm_bin="$(pnpm bin -g 2>/dev/null)"
  add_to_path "$pnpm_bin"
  unset pnpm_bin
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

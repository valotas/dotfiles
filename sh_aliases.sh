# for debugging
export _VALOTAS_ENV_COUNTER="${_VALOTAS_ENV_COUNTER}[a]"

alias la="ls -al"

if [[ -f "$HOME/.config/local_aliases.sh" ]]; then
  source "$HOME/.config/local_aliases.sh"
fi

# Check if nvim is installed, and if so, alias vim/vi to nvim
if command -v nvim >/dev/null 2>&1; then
  alias vim='nvim'
  alias vi='nvim'
fi

alias pn=pnpm

alias lzp="DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock lazydocker"

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

# fzf (ctrl-r history, ctrl-t files, alt-c dirs)
if command -v fzf >/dev/null 2>&1; then
  export FZF_TMUX_HEIGHT='30%'
  export FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT} --reverse --inline-info --color light,fg:-1,bg:-1,hl:#268bd2,fg+:#586e75,bg+:#eee8d5,hl+:#268bd2,info:#b58900,prompt:#b58900,pointer:#2aa198,marker:#2aa198,spinner:#b58900"
  export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"

  if [[ -n "${TMUX_PANE:-}" ]]; then
    export FZF_TMUX=1
  else
    export FZF_TMUX=0
  fi

  if command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi

  if command -v tree >/dev/null 2>&1; then
    export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
  fi

  [ -n "${BASH_VERSION:-}" ] && eval "$(fzf --bash)"
  [ -n "${ZSH_VERSION:-}" ] && eval "$(fzf --zsh)"
fi

# bash history: keep enough lines for the fzf ctrl-r widget
if [ -n "${BASH_VERSION:-}" ]; then
  HISTSIZE="${HISTSIZE:-10000}"
  HISTFILESIZE="${HISTFILESIZE:-10000}"
  HISTCONTROL="${HISTCONTROL:-ignoreboth}"
  shopt -s histappend
fi

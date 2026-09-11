#
# Executes commands at the start of an interactive session.
#

# Cursor agent shells: keep mise/PATH, skip interactive zsh niceties.
if [[ -n "$CURSOR_AGENT" ]]; then
  [[ -s "$HOME/.dotfiles/sh_setup.sh" ]] && source "$HOME/.dotfiles/sh_setup.sh"
  return
fi

_zsh_interactive="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/interactive.zsh"
[[ -s "$_zsh_interactive" ]] && source "$_zsh_interactive"
unset _zsh_interactive
[[ -s "$HOME/.dotfiles/sh_aliases.sh" ]] && source "$HOME/.dotfiles/sh_aliases.sh"
[[ -s "$HOME/.dotfiles/sh_setup.sh" ]] && source "$HOME/.dotfiles/sh_setup.sh"

#
# herdr auto-start (session "main"), skipped in Cursor/VS Code/agents.
# herdr is on PATH from sh_env.sh (`mise env`).
#

rehash
if (( $+commands[herdr] )); then
  if [[ -z "$CURSOR_AGENT" && -z "$VSCODE_PID" \
    && -z "$HERDR_ENV" && -z "$TMUX" && -z "$EMACS" && -z "$VIM" \
    && -z "$INSIDE_EMACS" && -z "$VSCODE_RESOLVING_ENVIRONMENT" \
    && "$TERM_PROGRAM" != "vscode" \
    && "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" \
    && -z "$SSH_TTY" ]]; then
    exec herdr --session main
  fi
  alias herdra='herdr --session'
  alias herdrl='herdr session list'

  t() {
    herdr --session "${1:-$(basename "$PWD")}"
  }

  ts() {
    local session
    session=$(herdr session list 2>/dev/null | awk 'NR > 1 { print $1 }' | fzf) || return
    herdr --session "$session"
  }

  # remotes still on tmux unless those hosts also get herdr
  tr() {
    local host="${1:?usage: tr host [session]}"
    local name="${2:-main}"
    ssh -t "$host" "tmux new-session -A -s ${name}"
  }
fi

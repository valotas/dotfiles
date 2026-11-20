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
# herdr auto-start (session "main").
# Plain Ghostty shells attach. Shells opened inside another app stay plain:
# Cursor, VS Code, Claude, T3 Code, and Pane.
# herdr is on PATH from sh_env.sh (`mise env`).
# HERDR_SKIP=1: plain Ghostty (AeroSpace Option+Enter) so herdr can be updated.
#

# True when this interactive shell belongs to an embedded terminal.
_herdr_opened_by_app() {
  case ${TERM_PROGRAM:-} in
    vscode|cursor|claude-desktop|t3code) return 0 ;;
  esac

  [[ -n ${CURSOR_AGENT:-}${VSCODE_PID:-}${VSCODE_INJECTION:-}${VSCODE_RESOLVING_ENVIRONMENT:-} ]] && return 0
  [[ -n ${CLAUDECODE:-}${CLAUDE_CODE_ENTRYPOINT:-} ]] && return 0
  [[ -n ${PANE_SESSION_ID:-}${PANE_PANEL_ID:-}${PANE_PANEL_KIND:-} ]] && return 0

  # Some hosts spawn a login shell without those markers. Walk parents.
  local pid=${PPID:-} cmdline i=0
  while (( i++ < 8 )); do
    [[ -z $pid || $pid == 0 || $pid == 1 ]] && return 1
    cmdline=$(command ps -ww -o command= -p "$pid" 2>/dev/null) || return 1
    case $cmdline in
      *"/Applications/Cursor.app"*|*"Cursor Helper"* \
      |*"/Applications/Visual Studio Code.app"*|*"Code Helper"* \
      |*"/Applications/Claude.app"* \
      |*"/Applications/T3 Code"*|*"T3 Code (Beta)"* \
      |*"/Applications/Pane.app"*|*"Pane Helper"*)
        return 0
        ;;
    esac
    pid=$(command ps -ww -o ppid= -p "$pid" 2>/dev/null) || return 1
    pid=${pid//[[:space:]]/}
  done
  return 1
}

rehash
if (( $+commands[herdr] )); then
  if ! _herdr_opened_by_app \
    && [[ -z $HERDR_ENV && -z $HERDR_SKIP && -z $TMUX && -z $EMACS && -z $VIM \
      && -z $INSIDE_EMACS && -z $SSH_TTY \
      && $TERMINAL_EMULATOR != JetBrains-JediTerm ]]; then
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
unset -f _herdr_opened_by_app

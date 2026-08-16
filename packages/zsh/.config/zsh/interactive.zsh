# Interactive zsh setup (replaces Prezto). Sourced from .zshrc.

#
# Environment
#

autoload -Uz is-at-least
if [[ $ZSH_VERSION != 5.1.1 && $TERM != dumb ]]; then
  if is-at-least 5.2; then
    autoload -Uz bracketed-paste-url-magic
    zle -N bracketed-paste bracketed-paste-url-magic
  elif is-at-least 5.1; then
    autoload -Uz bracketed-paste-magic
    zle -N bracketed-paste bracketed-paste-magic
  fi
  autoload -Uz url-quote-magic
  zle -N self-insert url-quote-magic
fi

setopt COMBINING_CHARS
setopt INTERACTIVE_COMMENTS
setopt RC_QUOTES
unsetopt MAIL_WARNING

[[ -r ${TTY:-} && -w ${TTY:-} && $+commands[stty] == 1 ]] && stty -ixon <$TTY >$TTY

setopt LONG_LIST_JOBS
setopt AUTO_RESUME
setopt NOTIFY
unsetopt BG_NICE
unsetopt HUP
unsetopt CHECK_JOBS

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[00;47;30m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#
# History
#

setopt BANG_HIST
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt HIST_BEEP

HISTFILE="${HISTFILE:-${ZDOTDIR:-$HOME}/.zsh_history}"
HISTSIZE=10000
SAVEHIST=$HISTSIZE

#
# Directory
#

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME
setopt CDABLE_VARS
setopt MULTIOS
setopt EXTENDED_GLOB
unsetopt CLOBBER

alias -- -='cd -'
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"
unset index

#
# Editor
#

bindkey -v

#
# Completion
#

if [[ $TERM != dumb ]]; then
  if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
    fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
  fi

  setopt COMPLETE_IN_WORD
  setopt ALWAYS_TO_END
  setopt PATH_DIRS
  setopt AUTO_MENU
  setopt AUTO_LIST
  setopt AUTO_PARAM_SLASH
  unsetopt MENU_COMPLETE
  unsetopt FLOW_CONTROL

  LS_COLORS=${LS_COLORS:-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'}

  autoload -Uz compinit
  _comp_path="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
  if [[ $_comp_path(#qNmh-20) ]]; then
    compinit -C -d "$_comp_path"
  else
    mkdir -p "$_comp_path:h"
    compinit -i -d "$_comp_path"
    touch "$_comp_path"
  fi
  unset _comp_path

  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
  zstyle ':completion:*:default' list-prompt '%S%M matches%s'
  zstyle ':completion::complete:*' use-cache on
  zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
  zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'm:{[:upper:]}={[:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  unsetopt CASE_GLOB
  zstyle ':completion:*:*:*:*:*' menu select
  zstyle ':completion:*:matches' group 'yes'
  zstyle ':completion:*:options' description 'yes'
  zstyle ':completion:*:options' auto-description '%d'
  zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
  zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
  zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
  zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
  zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
  zstyle ':completion:*' group-name ''
  zstyle ':completion:*' verbose yes
  zstyle ':completion:*' completer _complete _match _approximate
  zstyle ':completion:*:match:*' original only
  zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'
  zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
  zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
  zstyle ':completion:*' squeeze-slashes true
fi

#
# Aliases (from Prezto utility)
#

alias mkdir="${aliases[mkdir]:-mkdir} -p"
alias cp="${aliases[cp]:-cp} -i"
alias ln="${aliases[ln]:-ln} -i"
alias mv="${aliases[mv]:-mv} -i"
alias rm="${aliases[rm]:-rm} -i"

if [[ "$OSTYPE" == darwin* ]]; then
  alias ls="${aliases[ls]:-ls} -G"
  alias o='open'
else
  alias ls="${aliases[ls]:-ls} --color=auto"
  alias o='xdg-open'
fi
alias ll='ls -lh'
alias grep="${aliases[grep]:-grep} --color=auto"

#
# History substring search (Prezto/fish-style: arrows filter by typed text)
#

_hss_file="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
if [[ -s "$_hss_file" ]]; then
  source "$_hss_file"
  HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

  # Bind both normal and application cursor-key sequences.
  bindkey -M viins '^[[A' history-substring-search-up
  bindkey -M viins '^[[B' history-substring-search-down
  bindkey -M viins '^[OA' history-substring-search-up
  bindkey -M viins '^[OB' history-substring-search-down
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
fi
unset _hss_file

#
# fzf
#

if (( $+commands[fzf] )); then
  export FZF_TMUX_HEIGHT='30%'
  export FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT} --reverse --inline-info --color light,fg:-1,bg:-1,hl:#268bd2,fg+:#586e75,bg+:#eee8d5,hl+:#268bd2,info:#b58900,prompt:#b58900,pointer:#2aa198,marker:#2aa198,spinner:#b58900"
  export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"

  if [[ -n "$TMUX_PANE" ]]; then
    export FZF_TMUX=1
  else
    export FZF_TMUX=0
  fi

  if (( $+commands[rg] )); then
    export FZF_DEFAULT_COMMAND='rg --files'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi

  if (( $+commands[tree] )); then
    export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
  fi

  eval "$(fzf --zsh)"
fi

#
# tmux auto-start (session "main"), skipped in Cursor/VS Code/agents
#

if (( $+commands[tmux] )); then
  if [[ -z "$CURSOR_AGENT" && -z "$VSCODE_PID" \
    && -z "$TMUX" && -z "$EMACS" && -z "$VIM" && -z "$INSIDE_EMACS" \
    && -z "$VSCODE_RESOLVING_ENVIRONMENT" \
    && "$TERM_PROGRAM" != "vscode" \
    && "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" \
    && -z "$SSH_TTY" ]]; then
    tmux start-server
    if ! tmux has-session 2>/dev/null; then
      tmux new-session -d -s main \; set-option -t main destroy-unattached off &>/dev/null
    fi
    exec tmux attach-session -d
  fi
  alias tmuxa='tmux new-session -A'
  alias tmuxl='tmux list-sessions'
fi

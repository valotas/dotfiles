#!/bin/sh
# Idempotent. Safe to re-run after adding a @plugin line.
if ! command -v tmux >/dev/null 2>&1; then
  echo "skip tmux plugins: tmux not installed"
  exit 0
fi
TPM="${HOME}/.tmux/plugins/tpm"
if [ ! -d "$TPM" ]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM"
fi
"$TPM/bin/install_plugins"

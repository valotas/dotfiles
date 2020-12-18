# this should be sourced in .profile and/or .zenv:
# [[ -s "$HOME/dotfiles/env.sh" ]] && . "$HOME/dotfiles/env.sh"

# football-data.org stuff
export FOOTBALL_DATA_ORG_TOKEN="5ecd3132cf3b4299b70e7229192a49bd"
export FOOTBALL_DATA_ORG_USER="valotas@gmail.com"

# sdkman
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# for debugging
export VALOTAS_VERSION="dotfiles/env.sh"
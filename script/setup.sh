#!/bin/bash

BASEDIR=$(dirname -- "$(dirname -- "$(realpath -- "$0")")")

cd $BASEDIR && ./script/update.sh

echo "Stowing all directories in $BASEDIR/packages ..."
cd $BASEDIR && find packages -mindepth 1 -maxdepth 1 -type d | sed "s|^packages/||" | xargs stow -v 2 -t $HOME -d packages

#update the font cache
if command -v fc-cache >/dev/null 2>&1; then
  echo "Updating font cache..."
  fc-cache -vf ~/.fonts
fi

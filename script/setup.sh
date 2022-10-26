#!/bin/bash

BASEDIR=$(dirname -- "$( dirname -- "$( realpath -- "$0"; )"; )"; )

cd $BASEDIR && ./script/update.sh

echo "Stowing all directories in $BASEDIR/packages ..."
cd $BASEDIR && find -maxdepth 2 -path './packages/[^.]*' -type d | sed "s|^\./packages/||" | xargs stow -v 2 -t $HOME -d packages

#update the font cache
echo "Updating font cache..."
fc-cache -vf ~/.fonts

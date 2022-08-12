#!/bin/bash

echo "Stowing all directories in ./packages..."
find -maxdepth 2 -path './packages/[^.]*' -type d | sed "s|^\./packages/||" | xargs stow -v 2 -t $HOME -d packages

#update the font cache
echo "Updating font cache..."
fc-cache -vf ~/.fonts

#echo "Updating submodules"
#git submodule update --init
#git submodule foreach git pull origin master
#echo "...done"

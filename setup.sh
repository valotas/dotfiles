#!/bin/bash

echo "stow configs"
find  -maxdepth 1 -path './[^.]*' -type d -print | sed "s|^\./||" | xargs -L 1 stow

#update the font cache
echo "Updating font cache"
fc-cache -vf ~/.fonts

#echo "Updating submodules"
#git submodule update --init
#git submodule foreach git pull origin master
#echo "...done"

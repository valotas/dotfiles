#!/usr/bin/env sh

# pulls all the submodules which are our dependencies
git submodule update --init --recursive

# install sketchybar only on macOS
if [ "$(uname)" = "Darwin" ]; then
    # install sketchybar
    brew tap FelixKratz/formulae
    brew install sketchybar
    brew install --cask font-sketchybar-app-font

    # create a symlink for the main sketchybar
    ln -sf $(which sketchybar) $(dirname $(which sketchybar))/sketchybar_main
    # create a symlink for the main sketchybar
    ln -sf $(which sketchybar) $(dirname $(which sketchybar))/sketchybar_alternative

    # install SbarLua
    (git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)
fi
#!/usr/bin/env sh

# pulls all the submodules which are our dependencies
git submodule update --init --recursive

# install SbarLua
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)
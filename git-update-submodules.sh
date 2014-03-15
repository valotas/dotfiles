#!/bin/sh
git submodule foreach git pull origin master

echo 'Updated submodules make sure that you commit the changes'

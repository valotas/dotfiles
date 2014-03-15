# dotfiles
Just a collection of dotfiles that can be used in any pc of mine

## Installation

```sh
git clone git@github.com:valotas/dotfiles.git
cd dotfiles
./setup.sh
```

### Vim
There are some more things that should be taken care of for vim.

### Ctags
The `taglist` bundle needs the `exuberant-ctags` package. So just do a `sudo apt-get install exuberant-ctags`

### Airline
`vim-airline` need a patched version of fonts. Although I set that, I have to make sure that my terminal will be using the same fonts if I want to use `vim` within it. So go to `Edit > Profiles` select your profile and click edit. There change teh font at the first tab to `Droid Sans Mono for Powerline` which should be installed.

### jshint2.vim
`jshint2.vim` uses nodejs with the `jshint` to do the linting and that means that you must have them both installed. For the later just do a `sudo npm install -g jshint`

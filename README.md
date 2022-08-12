# dotfiles
Just a collection of dotfiles that can be used in any pc of mine

## Installation

The following

```sh
git clone git@github.com:valotas/dotfiles.git
find  -maxdepth 1 -path './[^.]*' -type d -print | sed "s|^\./||" | xargs -L 1 stow
```

should install every config under the existing directories

### Vim
There are some more things that should be taken care of for vim.

### Ctags
The `taglist` bundle needs the `exuberant-ctags` package. So just do a `sudo apt-get install exuberant-ctags`

### Airline
`vim-airline` need a patched version of fonts. Although I set that, I have to make sure that my terminal will be using the same fonts if I want to use `vim` within it. So go to `Edit > Profiles` select your profile and click edit. There change teh font at the first tab to `Droid Sans Mono for Powerline` which should be installed.

## Uninstalling 

In order to uninstall a directory:

```sh
stow -D [directory]
```

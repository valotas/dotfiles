# dotfiles
Just a collection of dotfiles that can be used in any pc of mine

## Installation

The following

```sh
git clone git@github.com:valotas/dotfiles.git
./setup.sh
```

should install every config under the packages directory.

To install an individual package:

```sh
cd packages
stow --target=$HOME --verbose=2 <package_name>
```

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

# Further reading

- [dotfiles](https://dotfiles.github.io/)
- [Sayonara, Prezto. Hello: dotfiles](https://naikoob.github.io/blog/2020/10/02/hello-dotfiles.html)
- [Using GNU Stow to manage your dotfiles](https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html)
- [Using git-submodules to version-control Vim plugins](https://gist.github.com/manasthakur/d4dc9a610884c60d944a4dd97f0b3560)
- [Dotfiles Are Meant to Be Forked](https://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/)
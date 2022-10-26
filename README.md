# dotfiles
Just a collection of dotfiles that can be used in any pc of mine

## Installation

The following

```sh
git clone git@github.com:valotas/dotfiles.git .dotfiles
./setup.sh
```

should install every config under the packages directory.

To install an individual package:

```sh
cd packages
stow --target=$HOME --verbose=2 <package_name>
```

### Vim

The configuration covers both vim and neovim as proposed [here](https://www.youtube.com/watch?v=X2_R3uxDN6g)

#### Adding a vim plugin

Clone the plugin to `packages/vim/.vim/pack/plugins/[opt|start]/[name]`. For example for nerdtree:

```sh
git submodule add --name nerdtree git@github.com:preservim/nerdtree.git packages/vim/.vim/pack/plugins/opt/nerdtree 
```

And then init the plagin in the `packages/vim/.vimrc`.

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
- [stow man page](https://linux.die.net/man/8/stow)

# dotfiles
Just a collection of dotfiles that can be used in any pc of mine

## Installation

The following

```sh
git clone git@github.com:valotas/dotfiles.git .dotfiles
./script/bootstrap.sh
./script/setup.sh
```

should install every config under the packages directory.

To install an individual package:

```sh
cd packages
stow --target=$HOME --verbose=2 <package_name>
```

### Updating

Just pull the latest changes and setup:

```sh
git pull origin master
./script/setup.sh
```

### Vim

The configuration covers both vim and neovim as proposed [here](https://www.youtube.com/watch?v=X2_R3uxDN6g)

#### Adding a vim plugin

Clone the plugin to `packages/vim/.vim/pack/plugins/[opt|start]/[name]`. For example for nerdtree:

```sh
git submodule add --name nerdtree git@github.com:preservim/nerdtree.git packages/vim/.vim/pack/plugins/opt/nerdtree 
```

And then init the plugin in the `packages/vim/.vimrc`.

## Uninstalling 

In order to uninstall a directory, from the root of the project do:

```sh
stow -d packages -D [directory_in_packages] -t $HOME
```

## Additional setup

The the [nerd fonts version of source code pro](https://www.nerdfonts.com/font-downloads) is installed but you might need to use it in your terminal emulator. The name should be `SauceCodePro Nerd Font`.

### wsl

For wsl, you still need to link some things manually to have vscode properly reading the same settings/keybindings on both in `windows` and `wsl`. So with the windows' command line do the following:

```batch
cd \Users\USER\AppData\Roaming\Code\User
mklink keybindings.json "\\wsl.localhost\Ubuntu\home\WSLUSER\.dotfiles\packages\vscode\.config\Code\User\keybindings.json"
mklink settings.json "\\wsl.localhost\Ubuntu\home\WSLUSER\.dotfiles\packages\vscode\.config\Code\User\settings.json"
mklink snippets "\\wsl.localhost\Ubuntu\home\WSLUSER\.dotfiles\packages\vscode\.config\Code\User\snippets"
```

# Usage

After installing you can still use some local (meaning machine specific) defined configuration. At the moment the following configuration can be adjusted per machine:

- `~/.gitconfig.local` is sourced by .gitconfig
- `~/.config/local_aliases.sh` is sourced by bash/zsh for alias declaration

# Further reading

- [dotfiles](https://dotfiles.github.io/)
- [Sayonara, Prezto. Hello: dotfiles](https://naikoob.github.io/blog/2020/10/02/hello-dotfiles.html)
- [Using GNU Stow to manage your dotfiles](https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html)
- [Using git-submodules to version-control Vim plugins](https://gist.github.com/manasthakur/d4dc9a610884c60d944a4dd97f0b3560)
- [Dotfiles Are Meant to Be Forked](https://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/)
- [stow man page](https://linux.die.net/man/8/stow)

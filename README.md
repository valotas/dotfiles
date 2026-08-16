# dotfiles
Just a collection of dotfiles that can be used in any pc of mine

## Installation

The following

```sh
git clone --recurse-submodules git@github.com:valotas/dotfiles.git .dotfiles
make bootstrap
make install
```

should fetch submodules, run machine-specific bootstrap steps, and stow every config under `packages/`.

If you already cloned without `--recurse-submodules`, `make bootstrap` (or the submodule commands below) will initialize them.

To install an individual package:

```sh
make install package=<package_name>
```

### Submodules

Dependencies live as git submodules:

| Name | Path | Purpose |
|------|------|---------|
| `nerdtree` | `packages/vim/.vim/pack/plugins/opt/nerdtree` | Classic vim file tree (fallback when not using LazyVim) |
| `zsh-history-substring-search` | `packages/zsh/.config/zsh/plugins/zsh-history-substring-search` | Fish/Prezto-style history filtering on ↑/↓ |

**After clone (if needed):**

```sh
git submodule update --init --recursive
```

**After pull** (when `.gitmodules` or submodule commits changed):

```sh
git pull origin master
git submodule sync --recursive
git submodule update --init --recursive
make install
```

**Check status:**

```sh
git submodule status
```

**Add a new submodule:**

```sh
git submodule add --name <name> <repo-url> <path-inside-repo>
git submodule update --init --recursive
```

Examples:

```sh
# vim pack plugin
git submodule add --name nerdtree https://github.com/preservim/nerdtree.git \
  packages/vim/.vim/pack/plugins/opt/nerdtree

# zsh plugin under XDG config (gets stowed to ~/.config/zsh/plugins/...)
git submodule add --name zsh-history-substring-search \
  https://github.com/zsh-users/zsh-history-substring-search.git \
  packages/zsh/.config/zsh/plugins/zsh-history-substring-search
```

Then wire the plugin in the relevant config (e.g. `packages/vim/.vimrc` or `packages/zsh/.config/zsh/interactive.zsh`) and commit `.gitmodules` plus the submodule gitlink.

**Update a submodule to the latest upstream commit:**

```sh
git -C <path-inside-repo> pull origin master   # or main
git add <path-inside-repo>
git commit -m "Update <name> submodule"
```

### Updating

```sh
git pull origin master
git submodule sync --recursive
git submodule update --init --recursive
make install
```

### Vim

The configuration covers both vim and neovim as proposed [here](https://www.youtube.com/watch?v=X2_R3uxDN6g). We are using [LazyVim](https://www.lazyvim.org/). Classic vim pack plugins (like nerdtree) are managed as submodules — see [Submodules](#submodules).

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

#!/usr/bin/env sh

# pulls all the submodules which are our dependencies
git submodule update --init --recursive

# install sketchybar only on macOS
if [ "$(uname)" = "Darwin" ]; then
  brew install herdr

  # install sketchybar (kept until YBar look is a keeper)
  brew tap FelixKratz/formulae
  brew install sketchybar
  brew install --cask font-sketchybar-app-font

  # install ybar (ninefiveb overlay lives in packages/aerospace/.config/ybar)
  brew tap NineFiveB/ybar
  brew trust ninefiveb/ybar
  brew install --HEAD ybar
  # Homebrew's keg currently ships YBar.app without YBar_YBarKit.bundle.
  # `make app` writes a complete bundle to ~/Applications/YBar.app.
  if [ ! -d "$HOME/Applications/YBar.app/Contents/Resources/YBar_YBarKit.bundle" ]; then
    (git clone --depth 1 https://github.com/NineFiveB/YBar.git /tmp/YBar-src && cd /tmp/YBar-src && make app)
  fi

  # create a symlink for the main sketchybar
  ln -sf $(which sketchybar) $(dirname $(which sketchybar))/sketchybar_main
  # create a symlink for the main sketchybar
  ln -sf $(which sketchybar) $(dirname $(which sketchybar))/sketchybar_alternative

  # install SbarLua
  (git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)
fi

# install tools on Ubuntu
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "$ID" = "ubuntu" ]; then
    echo "Installing tools on Ubuntu..."
    sudo apt-get update
    sudo apt-get install -y ripgrep fzf fd-find

    curl -fsSL https://herdr.dev/install.sh | sh

    # Install lazygit
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz

    # Install lazydocker
    LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazydocker.tar.gz lazydocker
    sudo install lazydocker /usr/local/bin
    rm lazydocker lazydocker.tar.gz

  fi
fi

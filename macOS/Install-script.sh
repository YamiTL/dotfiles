#!/bin/zsh

set -eu -o pipefail # fail on error and report it, debug all lines

echo -e "###### macOS installation script ######"

# Git Configuration
echo -e '\n### Configure git'
git config --global user.name "YamiTL"
git config --global user.email "yamitlemos@gmail.com"
echo -e 'Git has been configured!'

# echo -e '\n### running te commands echo; and eval $/usr/local/bin/brew shellenv'
# (echo; echo 'eval "$(/usr/local/bin/brew shellenv)"') >> /Users/yamilalemos/.zprofile
# eval "$(/usr/local/bin/brew shellenv)"

# install the apps
brew install keepassxc
brew install gh 
# brew install --cask google-chrome 
brew install microsoft-edge 
brew install slack 
brew install spotify 
brew install visual-studio-code 
# brew install warp 
brew install whatsapp 
# brew install wget
brew install nushell

# repos and other-repos folders
echo -e '\n### create ~/repos/'
mkdir -p ~/repos
echo -e '\n### cloning dotfiles'
if [ ! -d ~/repos/dotfiles ]; then
    git clone https://github.com/YamiTL/dotfiles ~/repos/dotfiles
else
    echo -e '\n ~/repos/doftiles found. Skipping!'
fi

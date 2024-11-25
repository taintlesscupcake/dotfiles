# Minimal zshrc

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=minimal

plugins=(
  git
  autojump
  urltools
  bgnotify
  zsh-autosuggestions
  zsh-syntax-highlighting
  asdf
)

source "$HOME/.aliases"

source $ZSH/oh-my-zsh.sh

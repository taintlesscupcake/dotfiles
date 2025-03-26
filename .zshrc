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
)

source "$HOME/.aliases"

source $ZSH/oh-my-zsh.sh

# Activate mise
eval "$("$HOME/.local/bin/mise" activate zsh)"
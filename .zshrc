# Minimal zshrc

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=minimal

plugins=(
  git
  fzf
  fzf-tab
  urltools
  bgnotify
  you-should-use
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-hangul
)

source $ZSH/oh-my-zsh.sh

# Activate mise
eval "$(mise activate zsh)"
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"
eval "$(mcfly init zsh)"

# Virtualenv configuration
export ENV_HOME="$HOME/.virtualenvs"
source $ENV_HOME/virtualenv.sh
export VIRTUAL_ENV_DISABLE_PROMPT=1

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

export EDITOR=nvim
export VISUAL=nvim

source "$HOME/.aliases"

# End of Docker CLI completions
export PATH="$HOME/.local/bin:$PATH"
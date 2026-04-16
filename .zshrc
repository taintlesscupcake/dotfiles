# shellcheck shell=bash disable=SC1091,SC2034
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

source "$ZSH/oh-my-zsh.sh"

# Activate mise
eval "$(mise activate zsh)"

export VIRTUAL_ENV_DISABLE_PROMPT=1
export PVM_HOME="${PVM_HOME:-$HOME/.pvm}"
if [ -f "$PVM_HOME/pvm.sh" ]; then
  source "$PVM_HOME/pvm.sh"
fi

eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"
eval "$(mcfly init zsh)"

function y() {
	local tmp
	local cwd
	tmp="$(mktemp -t "yazi-cwd.XXXXXX")"

	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd" || return
	rm -f -- "$tmp"
}
export EDITOR=nvim
export VISUAL=nvim

source "$HOME/.aliases"

# End of Docker CLI completions
export PATH="$HOME/.local/bin:$PATH"
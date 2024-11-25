# vim:ft=zsh ts=2 sw=2 sts=2
#
# Minimal Theme.

# # README
# This theme provides a clean and informative prompt with:
# - Git status information
# - SSH connection indicator
# - Virtual environment display
# - Minimalistic design with unicode characters

### Segment drawing
CURRENT_BG='NONE'

# Characters
local char_arrow="›"
local char_up_and_right="└"
local char_down_and_right="┌"
local char_vertical="─"

local newline=$'\n'
local lineup=$'\e[1A'
local linedown=$'\e[1B'

# Begin a segment
prompt_segment() {
  local bg fg text
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  [[ -n $3 ]] && text="$3" || text=""
  
  print -n "${bg}${fg}${text}"
}

# End the prompt
prompt_end() {
  print
  print -n "$(prepareVirtualEnvInfo)%F{85}${char_arrow}%f "
}

### Prompt components
prompt_git() {
  [[ $VCS != "" ]] && print -n "${vcs_info_msg_0_}"
}

prompt_dir() {
  prompt_segment "" 80 "%~"
}

prompt_line() {
  local termwidth spacing=""
  ((termwidth = ${COLUMNS} - 1))
  
  for i in {1..$termwidth}; do
    spacing="${spacing}${char_vertical}"
  done
  
  print -n "%F{236}${char_down_and_right}${spacing}%f"
}

# SEGMENT/VCS_STATUS_LINE ======================================================

export VCS="git"

local current_vcs="\":vcs_info:*\" enable $VCS"
local char_badge="%F{238} 𝗈𝗇 %f%F{236}${char_arrow}%f"
local vc_branch_name="%F{85}%b%f"

local vc_action="%F{238}%a %f%F{236}${char_arrow}%f"
local vc_unstaged_status="%F{80} M ${char_arrow}%f"

local vc_git_staged_status="%F{115} A ${char_arrow}%f"
local vc_git_hash="%F{151}%6.6i%f %F{236}${char_arrow}%f"
local vc_git_untracked_status="%F{74} U ${char_arrow}%f"


if [[ $VCS != "" ]]; then
  autoload -Uz vcs_info
  eval zstyle $current_vcs
  zstyle ':vcs_info:*' get-revision true
  zstyle ':vcs_info:*' check-for-changes true
fi

case "$VCS" in 
   "git")
    # git sepecific 
    zstyle ':vcs_info:git*+set-message:*' hooks use_git_untracked
    zstyle ':vcs_info:git:*' stagedstr $vc_git_staged_status
    zstyle ':vcs_info:git:*' unstagedstr $vc_unstaged_status
    zstyle ':vcs_info:git:*' actionformats "  ${vc_action} ${vc_git_hash}%m%u%c${char_badge} ${vc_branch_name}"
    zstyle ':vcs_info:git:*' formats " %c%u%m${char_badge} ${vc_branch_name}"
  ;;

  # svn sepecific 
  "svn")
    zstyle ':vcs_info:svn:*' branchformat "%b"
    zstyle ':vcs_info:svn:*' formats " ${char_badge} ${vc_branch_name}"
  ;;

  # hg sepecific 
  "hg")
    zstyle ':vcs_info:hg:*' branchformat "%b"
    zstyle ':vcs_info:hg:*' formats " ${char_badge} ${vc_branch_name}"
  ;;
esac

# Show untracked file status char on git status line
+vi-use_git_untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == "true" ]] &&
    git status --porcelain | grep -m 1 "^??" &>/dev/null; then
    hook_com[misc]=$vc_git_untracked_status
  else
    hook_com[misc]=""
  fi
}

# SEGMENT/SSH_STATUS ===========================================================

local ssh_marker=""

if [[ -n "$SSH_CLIENT" || -n "$SSH2_CLIENT" ]]; then
  ssh_marker="%F{115}SSH%f%F{236}:%f %F{80}$(hostname)%f"
fi

# SEGMENT/VIRTUALENV_STATUS ==================================================

function prepareVirtualEnvInfo() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "(%F{green}$(basename "$VIRTUAL_ENV")%f) "
  else
    echo ""
  fi
}

# UTILS ========================================================================

setopt PROMPT_SUBST

# Prepare git status line
prepareGitStatusLine() {
  echo '${vcs_info_msg_0_}'
} 

# Prepare prompt line limiter
printPsOneLimiter() {
  local termwidth
  local spacing=""
  
  ((termwidth = ${COLUMNS} - 1))
  
  for i in {1..$termwidth}; do
    spacing="${spacing}${char_vertical_divider}"
  done
  
  echo $ANSI_dim_black$char_down_and_right_divider$spacing$ANSI_reset
}

# ENV/VARIABLES/PROMPT_LINES ===================================================

PROMPT='%F{236}${char_up_and_right_divider} %f%F{80}%~%f${vcs_info_msg_0_}
$(prepareVirtualEnvInfo)%F{85}${char_arrow}%f '

RPROMPT='%{${lineup}%}${ssh_marker}%{${linedown}%}'

# ENV/HOOKS ==================================================================== 

prompt_minimal_main() {
  prompt_line
  print -n "%F{236}${char_up_and_right}%f "
  prompt_dir
  prompt_git
  prompt_end
}

prompt_minimal_precmd() {
  [[ $VCS != "" ]] && vcs_info
}

prompt_minimal_setup() {
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info
  
  add-zsh-hook precmd prompt_minimal_precmd
  
  setopt PROMPT_SUBST
  PROMPT='$(prompt_minimal_main)'
  RPROMPT='%{${lineup}%}${ssh_marker}%{${linedown}%}'
  
  # ... existing VCS and completion configuration ...
}

prompt_minimal_setup "$@"

# ENV/VARIABLES/LS_COLORS ======================================================

LSCOLORS=gxafexDxfxegedabagacad
export LSCOLORS

LS_COLORS=$LS_COLORS:"di=36":"ln=30;45":"so=34:pi=1;33":"ex=35":"bd=34;46":"cd=34;43":"su=30;41":"sg=30;46":"ow=30;43":"tw=30;42":"*.js=01;33":"*.json=33":"*.jsx=38;5;117":"*.ts=38;5;75":"*.css=38;5;27":"*.scss=38;5;169"
export LS_COLORS

# SEGMENT/COMPLETION ===========================================================

setopt MENU_COMPLETE

local completion_descriptions="%B%F{85} ${char_arrow} %f%%F{green}%d%b%f"
local completion_warnings="%F{yellow} ${char_arrow} %fno matches for %F{green}%d%f"
local completion_error="%B%F{red} ${char_arrow} %f%e %d error"

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
zstyle ':completion:*' verbose yes
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list "m:{a-z}={A-Z}"
zstyle ':completion:*' group-name ''

zstyle ':completion:*:*:*:*:descriptions' format $completion_descriptions
zstyle ':completion:*:*:*:*:corrections' format $completion_error
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS} "ma=38;5;253;48;5;23"
zstyle ':completion:*:*:*:*:warnings' format $completion_warnings
zstyle ':completion:*:*:*:*:messages' format "%d"

zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*:approximate:*' max-errors "reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )"
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns "*?.o" "*?.c~" "*?.old" "*?.pro"
zstyle ':completion:*:functions' ignored-patterns "_*"

zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# ==============================================================================

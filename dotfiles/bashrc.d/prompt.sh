# Sourcing git prompt utility if available (standard paths)
for f in /usr/lib/git-core/git-sh-prompt /etc/bash_completion.d/git-prompt /usr/share/git-core/git-prompt.sh; do
  [ -r "$f" ] && source "$f"
done

# Limit path length to 3 levels
export PROMPT_DIRTRIM=3

# Git prompt settings
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"

# Colors
RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
BLUE="\[\033[0;34m\]"
CYAN="\[\033[0;36m\]"
DARK_GRAY="\[\033[1;30m\]"
COLOR_NONE="\[\e[0m\]"

# Timer hooks
function start_timer() { TIMER=${TIMER:-$SECONDS}; }
trap 'start_timer' DEBUG

function set_bash_prompt () {
  local exit_code=$?
  
  # 1. Success/Failure symbol (Green checkmark for success, red cross with code for failure)
  local symbol="${GREEN}✔${COLOR_NONE}"
  if [ "$exit_code" -ne 0 ]; then
    symbol="${RED}✘ (${exit_code})${COLOR_NONE}"
  fi

  # 2. Duration calculation
  local duration=""
  if [ -n "$TIMER" ]; then
    local diff=$((SECONDS - TIMER))
    [ $diff -gt 1 ] && duration="${YELLOW}(took ${diff}s)${COLOR_NONE} "
  fi
  unset TIMER

  # 3. Dynamic SSH Context
  local context=""
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    context="${CYAN}\u@\h${COLOR_NONE} "
  fi

  # 4. Git Branch Info
  local git_info=""
  if type __git_ps1 &>/dev/null; then
    git_info=$(__git_ps1 " (${BLUE}%s${COLOR_NONE})")
  fi

  # 5. Form prompt string
  PS1="\n${context}${BLUE}\w${COLOR_NONE}${git_info} ${duration}\n${symbol} "
}

export PROMPT_COMMAND=set_bash_prompt

# Append history appending to PROMPT_COMMAND
if [ "$PROMPT_COMMAND" ]; then
  case ";$PROMPT_COMMAND;" in
    *";history -a;"*) ;;
    *) export PROMPT_COMMAND="$PROMPT_COMMAND; history -a" ;;
  esac
else
  export PROMPT_COMMAND="history -a"
fi

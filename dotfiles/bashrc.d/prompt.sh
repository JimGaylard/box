# Git prompt status configuration
export GIT_PS1_SHOWDIRTYSTATE=1

# Colors for prompt
RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
BLUE="\[\033[0;34m\]"
CYAN="\[\033[1;36m\]"
MY_BLUE="\[\033[1;34m\]"
LIGHT_RED="\[\033[1;31m\]"
DARK_GRAY="\[\033[1;30m\]"
WHITE="\[\033[1;37m\]"
LIGHT_GRAY="\[\033[0;36m\]"
MY_RED="\[\033[0;31m\]"
COLOR_NONE="\[\e[0m\]"

# Return the prompt symbol to use, colorized based on the return value of the
# previous command.
function set_prompt_symbol () {
  if test "$1" -eq 0 ; then
    PROMPT_SYMBOL=${GREEN}"^_^"${COLOR_NONE}
  else
    PROMPT_SYMBOL="${RED}0_o${COLOR_NONE}"
  fi
}

function set_bash_prompt () {
  # Set the PROMPT_SYMBOL variable. We do this first so we don't lose the
  # return value of the last command.
  set_prompt_symbol $?

  # Set the bash prompt variable.
  read -r -d '' PROMPT_STRING <<-_EOF_
${DARK_GRAY}this is a blank line${COLOR_NONE}\n\
${BLUE}\u${COLOR_NONE} \
${GRAY}\w${COLOR_NONE} \
${YELLOW}level:$SHLVL\n\
${PROMPT_SYMBOL}
_EOF_

  PS1="${PROMPT_STRING} "
}

# Tell bash to execute this function just before displaying its prompt.
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

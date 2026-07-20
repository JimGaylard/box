# Prefer GNU coreutils/tools over BSD (Darwin) equivalents.
# Homebrew installs these g-prefixed so system scripts keep BSD behaviour;
# these aliases only affect interactive shells (scripts with #!/bin/sh
# still hit the BSD versions). Each alias is guarded so a missing tool is a no-op.
command -v gsed  &>/dev/null && alias sed='gsed'
command -v gawk  &>/dev/null && alias awk='gawk'
command -v gfind &>/dev/null && alias find='gfind'
command -v ggrep &>/dev/null && alias grep='ggrep'
command -v gdate &>/dev/null && alias date='gdate'
command -v gtar  &>/dev/null && alias tar='gtar'
command -v gls   &>/dev/null && alias ls='gls --color=auto'

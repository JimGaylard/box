# 1Password SSH agent
#
# ~/.ssh/config already points the ssh binary at the 1Password agent via
# IdentityAgent, so `git push` works. Tools that speak SSH through a Go library
# instead of the ssh binary (dolt, and therefore `bd dolt push`) never read
# ssh_config — they only look at SSH_AUTH_SOCK, which macOS presets to its own
# launchd agent. Point it at 1Password so those tools authenticate too.
_op_agent_sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
if [ -S "$_op_agent_sock" ]; then
  export SSH_AUTH_SOCK="$_op_agent_sock"
fi
unset _op_agent_sock

# bd -> 1Password SSH agent
#
# `bd dolt push` authenticates to GitHub through a Go SSH client, which never
# reads ~/.ssh/config — so IdentityAgent doesn't reach it and it fails with
# "run `ssh-add <key>`" while `git push` works. It reads SSH_AUTH_SOCK, which
# macOS presets to its own launchd agent.
#
# Deliberately NOT exported globally: that would hand every process in every
# shell a path to the agent socket. Scoped to bd, for the length of one command.
bd() {
  local op_sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  if [ -S "$op_sock" ]; then
    SSH_AUTH_SOCK="$op_sock" command bd "$@"
  else
    command bd "$@"
  fi
}

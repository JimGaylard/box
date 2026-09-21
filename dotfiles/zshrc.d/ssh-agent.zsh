# bare bd -> refusal
#
# Agents go through the sanctioned wrappers, not bare `bd`. The 1Password SSH
# agent socket wiring (`bd dolt push` needs SSH_AUTH_SOCK, because its Go SSH
# client never reads ~/.ssh/config) used to live here; it now lives in
# `bd-hub`, so this function no longer injects anything. It refuses instead.
#
# Jim at the keyboard can still reach the real binary with `command bd`.
bd() {
  {
    echo "bd: bare bd is not used here."
    echo "  raw verbs:  bd-hub <verb>     (e.g. bd-hub dolt push)"
    echo "  creates:    bd-new <file.md>"
  } >&2
  return 1
}

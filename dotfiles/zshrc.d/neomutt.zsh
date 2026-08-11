# neomutt: free ^O from the macOS tty "discard" control char so the
# sidebar-open binding works. The stty must run in the shell that owns the
# tty, before neomutt starts — a backtick inside neomuttrc runs in a
# subshell whose stdin is not reliably the terminal (proven not to work,
# 2026-08-11). Guarded so a missing neomutt is a no-op.
if command -v neomutt >/dev/null 2>&1; then
  alias neomutt='stty discard undef 2>/dev/null; command neomutt'
fi

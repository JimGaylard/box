# nvim: an editor started by hand listens on the socket the layout tools expect,
# so pane-for / herdr-show (herdr-layout) and nvim-remote (show-me, tmux) can
# adopt and drive it instead of starting a second nvim.
#
#   under herdr (HERDR_ENV=1)   /tmp/nvim-herdr-<workspace>-<pane>   e.g. /tmp/nvim-herdr-wA-p9
#   under tmux                  /tmp/nvim-tmux-pane-<pane number>    e.g. /tmp/nvim-tmux-pane-15
#   elsewhere                   plain nvim
#
# Client calls (--server) and explicit --listen pass through untouched. A socket
# left behind by a killed nvim is removed first; a socket a live nvim still
# answers on is left alone and this nvim starts without --listen.
nvim() {
  local arg sock
  for arg in "$@"; do
    case "$arg" in
      --listen|--listen=*|--server|--server=*|--headless|-es|-Es) command nvim "$@"; return ;;
    esac
  done
  if [ "${HERDR_ENV:-}" = 1 ] && [ -n "${HERDR_WORKSPACE_ID:-}" ] && [ -n "${HERDR_PANE_ID:-}" ]; then
    sock="/tmp/nvim-herdr-${HERDR_WORKSPACE_ID}-${HERDR_PANE_ID#*:}"
  elif [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
    sock="/tmp/nvim-tmux-pane-${TMUX_PANE#%}"
  else
    command nvim "$@"; return
  fi
  if [ -S "$sock" ]; then
    if command nvim --server "$sock" --remote-expr 1 >/dev/null 2>&1; then
      command nvim "$@"; return          # a live nvim owns the socket already
    fi
    rm -f "$sock"                        # stale: the previous nvim died without cleaning up
  fi
  command nvim --listen "$sock" "$@"
}

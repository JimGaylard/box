#!/usr/bin/env bash
# Idempotently map /copyparty and /.cpr on tailscale serve to the local copyparty.
# Never uses funnel; refuses (exit 1) if Funnel is enabled before or after.
# Prints "CHANGED" when it set a mapping, "OK" when nothing needed doing,
# "SKIP: ..." (exit 0) when no tailscale CLI exists.
set -euo pipefail

BASE=http://127.0.0.1:3923
PATHS=(/copyparty /.cpr)

find_cli() {
  if [ -n "${TAILSCALE_BIN+set}" ]; then printf '%s' "$TAILSCALE_BIN"; return; fi
  if command -v tailscale >/dev/null 2>&1; then command -v tailscale; return; fi
  [ -n "${COPYPARTY_NO_APP_LOOKUP:-}" ] && return
  local app c
  app="$(mdfind "kMDItemCFBundleIdentifier == 'io.tailscale.ipn.macos'" 2>/dev/null | head -n1)"
  for c in "$app/Contents/MacOS/Tailscale" /Applications/Tailscale.app/Contents/MacOS/Tailscale; do
    if [ -x "$c" ]; then printf '%s' "$c"; return; fi
  done
}

ts="$(find_cli || true)"
if [ -z "$ts" ]; then echo "SKIP: tailscale CLI not found"; exit 0; fi

status() { "$ts" serve status --json; }

refuse_if_funnel() {
  local json="$1" when="$2"
  if jq -e '(.AllowFunnel // {}) | to_entries | any(.value == true)' <<<"$json" >/dev/null; then
    echo "REFUSE: Funnel is enabled ($when); copyparty must stay tailnet-only" >&2
    exit 1
  fi
}

current_proxy() { # json path -> proxy target of that path on any host, or empty
  jq -r --arg p "$2" '[.Web // {} | .[] | .Handlers[$p].Proxy // empty] | first // empty' <<<"$1"
}

json="$(status)"
refuse_if_funnel "$json" "before"

changed=0
for p in "${PATHS[@]}"; do
  target="$BASE$p"
  if [ "$(current_proxy "$json" "$p")" != "$target" ]; then
    "$ts" serve --bg --set-path "$p" "$target" >/dev/null
    changed=1
  fi
done

json="$(status)"
refuse_if_funnel "$json" "after"
for p in "${PATHS[@]}"; do
  [ "$(current_proxy "$json" "$p")" = "$BASE$p" ] || { echo "FAIL: $p not mapped" >&2; exit 1; }
done

if [ "$changed" = 1 ]; then echo CHANGED; else echo OK; fi

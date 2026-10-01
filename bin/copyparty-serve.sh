#!/usr/bin/env bash
# Idempotently map /copyparty on tailscale serve to the local copyparty, which
# runs with --rp-loc /copyparty so it serves its own assets under that prefix.
# Removes a stale /.cpr mapping (from the pre-rp-loc setup) from every host:port
# where it points at our copyparty (http://127.0.0.1:3923/.cpr); any other
# /.cpr is left alone.
# Never uses funnel; refuses (exit 1) if Funnel is enabled before or after.
# Prints "CHANGED" when it set or removed a mapping, "OK" when nothing needed doing,
# "SKIP: ..." (exit 0) when no tailscale CLI exists.
set -euo pipefail

BASE=http://127.0.0.1:3923
P=/copyparty
STALE=/.cpr

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

ours_ports() { # json path target -> ports of every host key whose path proxies to target
  jq -r --arg p "$2" --arg t "$3" \
    '[.Web // {} | to_entries[] | select(.value.Handlers[$p].Proxy == $t) | .key | sub("^.*:"; "")] | unique[]' <<<"$1"
}

json="$(status)"
refuse_if_funnel "$json" "before"

# serve --https blocks on an "enable it at <url>" prompt when the tailnet has
# HTTPS certificates off, so check first and never block.
if ! "$ts" status --json | jq -e '(.CertDomains // []) | length > 0' >/dev/null; then
  echo "REFUSE: HTTPS certificates are off on the tailnet; enable them in the admin console (DNS page), then re-run" >&2
  exit 1
fi

changed=0
if [ "$(current_proxy "$json" "$P")" != "$BASE$P" ]; then
  if ! setout="$("$ts" serve --bg --set-path "$P" "$BASE$P" 2>&1)"; then
    echo "FAIL: tailscale serve --set-path $P failed:" >&2
    echo "$setout" >&2
    exit 1
  fi
  changed=1
fi
while IFS= read -r port; do
  [ -n "$port" ] || continue
  if jq -e --arg port "$port" '.TCP[$port].HTTPS == true' <<<"$json" >/dev/null; then flag="--https=$port"; else flag="--http=$port"; fi
  if ! offout="$("$ts" serve "$flag" --set-path "$STALE" off 2>&1)"; then
    echo "FAIL: removing stale $STALE mapping on port $port failed:" >&2
    echo "$offout" >&2
    exit 1
  fi
  changed=1
done < <(ours_ports "$json" "$STALE" "$BASE$STALE")

json="$(status)"
refuse_if_funnel "$json" "after"
[ "$(current_proxy "$json" "$P")" = "$BASE$P" ] || { echo "FAIL: $P not mapped" >&2; exit 1; }
[ -z "$(ours_ports "$json" "$STALE" "$BASE$STALE")" ] || { echo "FAIL: stale $STALE still mapped to us" >&2; exit 1; }

if [ "$changed" = 1 ]; then echo CHANGED; else echo OK; fi

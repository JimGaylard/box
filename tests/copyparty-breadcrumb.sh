#!/usr/bin/env bash
# Offline test: run copyparty locally with the args the LaunchAgent uses and
# check every root-relative link/asset in a subfolder listing stays under
# /copyparty/ (so the breadcrumb "top" link is not an unmapped /).
# COPYPARTY_OLD_ARGS=1 runs the pre-rp-loc args; that must FAIL.
set -uo pipefail
fail() { echo "FAIL: $*" >&2; exit 1; }
bin="$(uv tool dir --bin 2>/dev/null)/copyparty"
[ -x "$bin" ] || { echo "SKIP: copyparty not installed"; exit 0; }

work="$(mktemp -d)"; pid=""
trap '[ -n "$pid" ] && kill "$pid" 2>/dev/null; wait 2>/dev/null' EXIT
mkdir -p "$work/share/sub"; echo hi > "$work/share/sub/f.txt"
port="$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1])')"

if [ -n "${COPYPARTY_OLD_ARGS:-}" ]; then vol="$work/share:copyparty:r"; extra=()
else vol="$work/share:/:r"; extra=(--rp-loc /copyparty); fi
"$bin" -i 127.0.0.1 -p "$port" -v "$vol" ${extra[@]+"${extra[@]}"} --ipa 127.0.0.0/8 --xdev -s --no-reload \
  >"$work/log" 2>&1 &
pid=$!

UA='Mozilla/5.0 (Macintosh) Firefox/130.0'
url="http://127.0.0.1:$port/copyparty/sub/"
html=""
for _ in $(seq 1 100); do
  kill -0 "$pid" 2>/dev/null || { cat "$work/log" >&2; fail "copyparty exited"; }
  html="$(curl -fs -A "$UA" "$url" 2>/dev/null)" && break
  html=""; sleep 0.2
done
[ -n "$html" ] || { cat "$work/log" >&2; fail "no listing from $url"; }

bad=0
while IFS= read -r l; do
  case "$l" in /copyparty/*) ;; *) echo "bad link: $l" >&2; bad=1;; esac
done < <(grep -oE '(href|src)="/[^"]*"' <<<"$html" | sed -E 's/^(href|src)="//; s/"$//')
sr="$(grep -oE 'SR ?= ?"[^"]*"' <<<"$html" | head -n1 | sed -E 's/.*"([^"]*)"/\1/')"
[ "$sr" = /copyparty ] || { echo "bad SR: '$sr'" >&2; bad=1; }
echo "top link: $(grep -oE 'href="[^"]*"[^>]*id="?goh|id="?goh"?[^>]*href="[^"]*"' <<<"$html" | head -n1)"
[ $bad = 0 ] || fail "root-relative links escape /copyparty/"
echo PASS

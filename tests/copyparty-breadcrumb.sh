#!/usr/bin/env bash
# Offline test: run copyparty locally with the ProgramArguments rendered from the LaunchAgent template and
# check every root-relative link/asset in a subfolder listing stays under
# /copyparty/ (so the breadcrumb "top" link is not an unmapped /).
# PLIST_TEMPLATE=path overrides the template (to prove it fails on an old one).
set -uo pipefail
fail() { echo "FAIL: $*" >&2; exit 1; }
bin="$(uv tool dir --bin 2>/dev/null)/copyparty"
[ -x "$bin" ] || { echo "SKIP: copyparty not installed"; exit 0; }

root="$(cd "$(dirname "$0")/.." && pwd)"
tpl="${PLIST_TEMPLATE:-$root/dotfiles/launchd/com.jimgaylard.copyparty.plist.j2}"
work="$(mktemp -d)"; pid=""
trap '[ -n "$pid" ] && kill "$pid" 2>/dev/null; wait 2>/dev/null' EXIT
home="$work/home"; mkdir -p "$home/workspace/scratch/copyparty/sub"; echo hi > "$home/workspace/scratch/copyparty/sub/f.txt"
port="$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1])')"

# Render the real template, take its ProgramArguments, swap only the -p value.
ANSIBLE_LOCAL_TEMP="$work/tmp" ANSIBLE_HOME="$work/ah" ansible localhost -c local -m template \
  -a "src=$tpl dest=$work/out.plist" \
  -e "{\"copyparty_home\":\"$home\",\"copyparty_bin\":\"$(dirname "$bin")\"}" >"$work/ansible.log" 2>&1 </dev/null \
  || { cat "$work/ansible.log" >&2; fail "template does not render"; }
args=()
while IFS= read -r a; do args+=("$a"); done < <(plutil -convert json -o - "$work/out.plist" \
  | jq -r --arg port "$port" '.ProgramArguments | . as $a | to_entries | map(if .key > 0 and $a[.key-1] == "-p" then $port else .value end) | .[]')
"${args[@]}" >"$work/log" 2>&1 &
pid=$!

# copyparty prints "port N is busy on interface ..." when the port is taken
# (the free port found above can be grabbed before it binds); report that
# distinctly so a clash is never mistaken for a breadcrumb regression.
clash_check() {
  local l
  l="$(sed -E $'s/\x1b\\[[0-9;]*m//g' "$work/log" | grep -iE 'is busy on interface|address already in use|errno 48' | head -n1)"
  [ -z "$l" ] || fail "port $port clash: $l"
}

UA='Mozilla/5.0 (Macintosh) Firefox/130.0'
url="http://127.0.0.1:$port/copyparty/sub/"
html=""
for _ in $(seq 1 100); do
  kill -0 "$pid" 2>/dev/null || { clash_check; cat "$work/log" >&2; fail "copyparty exited"; }
  html="$(curl -fs -A "$UA" "$url" 2>/dev/null)" && break
  html=""; sleep 0.2
done
[ -n "$html" ] || { clash_check; cat "$work/log" >&2; fail "no listing from $url"; }

bad=0
while IFS= read -r l; do
  case "$l" in /copyparty/*) ;; *) echo "bad link: $l" >&2; bad=1;; esac
done < <(grep -oE '(href|src)="/[^"]*"' <<<"$html" | sed -E 's/^(href|src)="//; s/"$//')
sr="$(grep -oE 'SR ?= ?"[^"]*"' <<<"$html" | head -n1 | sed -E 's/.*"([^"]*)"/\1/')"
[ "$sr" = /copyparty ] || { echo "bad SR: '$sr'" >&2; bad=1; }
echo "top link: $(grep -oE 'href="[^"]*"[^>]*id="?goh|id="?goh"?[^>]*href="[^"]*"' <<<"$html" | head -n1)"
[ $bad = 0 ] || fail "root-relative links escape /copyparty/"
echo PASS

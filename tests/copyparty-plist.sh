#!/usr/bin/env bash
# Offline test: render the copyparty LaunchAgent template and assert its shape.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
tpl="$root/dotfiles/launchd/com.jimgaylard.copyparty.plist.j2"
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
out="$work/out.plist"
fail() { echo "FAIL: $*" >&2; exit 1; }

[ -f "$tpl" ] || fail "template missing: $tpl"
ANSIBLE_LOCAL_TEMP="$work/tmp" ANSIBLE_HOME="$work/ah" ansible localhost -c local -m template \
  -a "src=$tpl dest=$out" \
  -e '{"copyparty_home":"/home/fake","copyparty_bin":"/home/fake/.local/bin"}' >"$work/ansible.log" 2>&1 </dev/null \
  || { cat "$work/ansible.log" >&2; fail "template does not render"; }
plutil -lint "$out" >/dev/null || fail "plutil -lint"

get() { plutil -extract "$1" raw -o - "$out"; }
[ "$(get Label)" = com.jimgaylard.copyparty ] || fail "label"
[ "$(get RunAtLoad)" = true ] || fail "RunAtLoad"
[ "$(get KeepAlive)" = true ] || fail "KeepAlive"
[ "$(get ThrottleInterval)" = 5 ] || fail "ThrottleInterval"
args="$(plutil -convert json -o - "$out" | jq -r '.ProgramArguments | join(" ")')"
want="/home/fake/.local/bin/copyparty -i 127.0.0.1 -p 3923 -v /home/fake/workspace/scratch/copyparty:/:r --rp-loc /copyparty --ipa 127.0.0.0/8 --xdev -s --no-reload"
[ "$args" = "$want" ] || fail "ProgramArguments: $args"
grep -q '/Users/' "$out" && fail "literal /Users/ in output"
grep -q '/home/fake/.local/state/copyparty/' "$out" || fail "logs not under .local/state/copyparty"
echo "PASS"

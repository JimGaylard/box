#!/usr/bin/env bash
# Offline test: bin/copyparty-serve.sh against a fake tailscale CLI.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
script="$root/bin/copyparty-serve.sh"
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }
[ -x "$script" ] || fail "script missing or not executable: $script"

# Fake CLI: state in $FAKE_STATE (serve JSON), calls logged to $FAKE_CALLS.
cat > "$work/tailscale" <<'STUB'
#!/usr/bin/env bash
echo "$*" >> "$FAKE_CALLS"
if [ "$1 $2" = "status --json" ]; then echo "${FAKE_CERTS:-{\"CertDomains\":[\"fake.ts.net\"]}}"; exit 0; fi
if [ "$1 $2 $3" = "serve status --json" ]; then cat "$FAKE_STATE"; exit 0; fi
if [ "$1 $2 $3" = "serve --bg --set-path" ]; then
  jq --arg p "$4" --arg t "$5" \
    '.Web["fake.ts.net:443"].Handlers[$p] = {Proxy: $t} | .TCP["443"] = {HTTPS: true}' \
    "$FAKE_STATE" > "$FAKE_STATE.new" && mv "$FAKE_STATE.new" "$FAKE_STATE"
  exit 0
fi
echo "unexpected: $*" >&2; exit 9
STUB
chmod +x "$work/tailscale"
export FAKE_STATE="$work/state.json" FAKE_CALLS="$work/calls" TAILSCALE_BIN="$work/tailscale"
A=http://127.0.0.1:3923/copyparty; B=http://127.0.0.1:3923/.cpr
run() { : > "$FAKE_CALLS"; out="$("$script" 2>&1)"; rc=$?; }
sets() { grep -c -- '--set-path' "$FAKE_CALLS"; }

# 1. empty -> sets both, reports changed
echo '{}' > "$FAKE_STATE"; run
[ $rc -eq 0 ] || fail "1: rc=$rc $out"
[ "$(sets)" = 2 ] || fail "1: expected 2 sets, got $(sets)"
grep -q -- "--set-path /copyparty $A" "$FAKE_CALLS" || fail "1: /copyparty target"
grep -q -- "--set-path /.cpr $B" "$FAKE_CALLS" || fail "1: /.cpr target"
case "$out" in *CHANGED*) ;; *) fail "1: no CHANGED marker: $out";; esac
grep -q funnel "$FAKE_CALLS" && fail "1: funnel invoked"

# 2. rerun -> no sets, reports ok
run
[ $rc -eq 0 ] || fail "2: rc=$rc"
[ "$(sets)" = 0 ] || fail "2: expected 0 sets, got $(sets)"
case "$out" in *CHANGED*) fail "2: CHANGED on idempotent rerun";; esac

# 3. one path differs -> only that one reset
jq '.Web["fake.ts.net:443"].Handlers["/.cpr"].Proxy = "http://127.0.0.1:1/x"' "$FAKE_STATE" > "$work/s" && mv "$work/s" "$FAKE_STATE"
run
[ "$(sets)" = 1 ] || fail "3: expected 1 set, got $(sets)"
grep -q -- "--set-path /.cpr $B" "$FAKE_CALLS" || fail "3: wrong path reset"

# 4. unrelated mapping is untouched
jq '.Web["fake.ts.net:443"].Handlers["/other"] = {Proxy: "http://127.0.0.1:9/"}' "$FAKE_STATE" > "$work/s" && mv "$work/s" "$FAKE_STATE"
run
[ "$(jq -r '.Web["fake.ts.net:443"].Handlers["/other"].Proxy' "$FAKE_STATE")" = "http://127.0.0.1:9/" ] || fail "4: other mapping disturbed"
grep -q -- '/other' "$FAKE_CALLS" && fail "4: touched /other"

# 5. funnel enabled beforehand -> refuse, set nothing
echo '{"AllowFunnel":{"fake.ts.net:443":true}}' > "$FAKE_STATE"; run
[ $rc -ne 0 ] || fail "5: should refuse under funnel"
[ "$(sets)" = 0 ] || fail "5: set paths despite funnel"
case "$out" in *[Ff]unnel*) ;; *) fail "5: no funnel message";; esac

# 6. funnel appearing after the set -> refuse
cat > "$work/tailscale6" <<'STUB'
#!/usr/bin/env bash
if [ "$1 $2 $3" = "serve --bg --set-path" ]; then
  jq '.AllowFunnel = {"fake.ts.net:443": true} | .Web["fake.ts.net:443"].Handlers["'"$4"'"] = {Proxy: "'"$5"'"}' "$FAKE_STATE" > "$FAKE_STATE.new" && mv "$FAKE_STATE.new" "$FAKE_STATE"; exit 0
fi
if [ "$1 $2" = "status --json" ]; then echo '{"CertDomains":["fake.ts.net"]}'; exit 0; fi
cat "$FAKE_STATE"
STUB
chmod +x "$work/tailscale6"; echo '{}' > "$FAKE_STATE"
TAILSCALE_BIN="$work/tailscale6" run
[ $rc -ne 0 ] || fail "6: should refuse when funnel appears after set"

# 7. CLI absent -> skip with message, rc 0
: > "$FAKE_CALLS"
out="$(TAILSCALE_BIN= COPYPARTY_NO_APP_LOOKUP=1 PATH=/usr/bin:/bin "$script" 2>&1)"; rc=$?
[ $rc -eq 0 ] || fail "7: rc=$rc"
case "$out" in *SKIP*) ;; *) fail "7: no SKIP message: $out";; esac

# 8. HTTPS certs off (CertDomains null/empty) -> refuse before any set, clear message
for certs in '{"CertDomains":null}' '{"CertDomains":[]}'; do
  echo '{}' > "$FAKE_STATE"; FAKE_CERTS="$certs" run
  [ $rc -ne 0 ] || fail "8: should refuse without certs ($certs)"
  [ "$(sets)" = 0 ] || fail "8: set paths without certs"
  case "$out" in *"HTTPS certificates are off"*"admin console"*) ;; *) fail "8: unclear message: $out";; esac
done

# 9. a failing set shows the CLI's output
cat > "$work/tailscale9" <<'STUB'
#!/usr/bin/env bash
if [ "$1 $2" = "status --json" ]; then echo '{"CertDomains":["fake.ts.net"]}'; exit 0; fi
if [ "$1 $2 $3" = "serve --bg --set-path" ]; then echo "enable it at https://example/enable-me"; exit 1; fi
echo '{}'
STUB
chmod +x "$work/tailscale9"
TAILSCALE_BIN="$work/tailscale9" run
[ $rc -ne 0 ] || fail "9: should fail when set fails"
case "$out" in *enable-me*) ;; *) fail "9: CLI output swallowed: $out";; esac

echo PASS

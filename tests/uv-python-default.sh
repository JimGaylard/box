#!/usr/bin/env bash
# Sandbox test: tasks/uv.yml's `uv python install --default` step reports
# changed on the first run and ok on the second. Real ~/.local/bin is never
# touched: HOME, UV_PYTHON_BIN_DIR and UV_PYTHON_INSTALL_DIR point into a temp
# dir. Needs network once (the CPython download) and a Darwin host.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(realpath "$(mktemp -d)")"   # realpath: uv mis-owns links under the /var symlink
fail() { echo "FAIL: $*" >&2; exit 1; }

cat >"$work/pb.yml" <<YML
- hosts: localhost
  connection: local
  gather_facts: true
  tasks:
    - import_tasks: $root/tasks/uv.yml
YML
export HOME="$work" UV_PYTHON_BIN_DIR="$work/.local/bin" UV_PYTHON_INSTALL_DIR="$work/.local/share/uv/python"
export ANSIBLE_LOCAL_TEMP="$work/tmp" ANSIBLE_HOME="$work/ah"
run() { ansible-playbook -i localhost, --tags uv-python "$work/pb.yml" 2>&1 </dev/null | tee "$work/run$1.log" | grep -E "^localhost +:"; }

echo "-- first run"; run 1 | grep -q "changed=1 " || fail "first run should report changed=1"
echo "-- second run"; run 2 | grep -q "changed=0 " || fail "second run should report changed=0"
[ -L "$work/.local/bin/python3" ] || fail "python3 not linked in sandbox .local/bin"
echo "PASS"

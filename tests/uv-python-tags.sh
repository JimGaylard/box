#!/usr/bin/env bash
# Offline test (nothing is applied; --list-tasks only): the uv python task is
# reachable by its tags through the REAL playbooks/macos.yml.
# include_tasks is dynamic, so --list-tasks shows only the "Setup uv" include
# itself, and that include must carry uv-python and packages or the tag filter
# never loads tasks/uv.yml. The task's own tags are checked through a static
# import_tasks wrapper, where --list-tasks does see inside, including the
# negative: --tags dotfiles must not select it.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(realpath "$(mktemp -d)")"
fail() { echo "FAIL: $*" >&2; exit 1; }
export ANSIBLE_LOCAL_TEMP="$work/tmp" ANSIBLE_HOME="$work/ah"
list() { ansible-playbook -i localhost, "$@" --list-tasks 2>&1 </dev/null; }
task="Install uv's managed Python as default"

for t in uv-python packages; do
  list "$root/playbooks/macos.yml" --tags "$t" | grep -q "Setup uv" \
    || fail "macos.yml --tags $t does not reach the Setup uv include"
  echo "ok: macos.yml --tags $t reaches Setup uv"
done

cat >"$work/pb.yml" <<YML
- hosts: localhost
  tasks:
    - import_tasks: $root/tasks/uv.yml
YML
for t in uv-python packages; do
  list "$work/pb.yml" --tags "$t" | grep -q "$task" || fail "uv.yml --tags $t lacks the python task"
  echo "ok: uv.yml --tags $t lists the python task"
done
if list "$work/pb.yml" --tags dotfiles | grep -q "$task"; then fail "--tags dotfiles selects the python task"; fi
echo "ok: --tags dotfiles does not list the python task"
echo "PASS"

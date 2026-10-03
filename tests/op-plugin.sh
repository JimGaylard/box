#!/usr/bin/env bash
# Offline test (nothing is applied): the 1Password shell-plugin module.
# dotfiles/zshrc.d/op.zsh must parse, guard on CLAUDECODE and a readable
# ~/.config/op/plugins.sh, and be deployed by tasks/dotfiles.yml (Darwin,
# tag dotfiles, mode 0644). Behaviour is checked with a fake HOME and a stub
# plugins.sh: gh becomes a function normally, and stays untouched under Claude Code.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(realpath "$(mktemp -d)")"
fail() { echo "FAIL: $*" >&2; exit 1; }
mod="$root/dotfiles/zshrc.d/op.zsh"
task="Deploy 1Password shell plugins (Zsh)"

[[ -f $mod ]] || fail "dotfiles/zshrc.d/op.zsh does not exist"
echo "ok: op.zsh exists"
zsh -n "$mod" || fail "op.zsh fails zsh -n"
echo "ok: op.zsh passes zsh -n"
grep -q 'CLAUDECODE' "$mod" || fail "op.zsh does not guard on CLAUDECODE"
grep -q -- '-r ~/.config/op/plugins.sh' "$mod" || fail "op.zsh does not guard on -r ~/.config/op/plugins.sh"
echo "ok: op.zsh carries both guards"

export ANSIBLE_LOCAL_TEMP="$work/tmp" ANSIBLE_HOME="$work/ah"
cat >"$work/pb.yml" <<YML
- hosts: localhost
  tasks:
    - import_tasks: $root/tasks/dotfiles.yml
YML
ansible-playbook -i localhost, "$work/pb.yml" --tags dotfiles --list-tasks 2>&1 </dev/null \
  | grep -q "$task" || fail "dotfiles.yml --tags dotfiles does not list '$task'"
echo "ok: dotfiles.yml --tags dotfiles lists the op.zsh task"
block="$(grep -A8 -- "- name: $task" "$root/tasks/dotfiles.yml")"
grep -q 'zshrc.d/op.zsh' <<<"$block" || fail "task does not copy zshrc.d/op.zsh"
grep -q "mode: '0644'" <<<"$block" || fail "task mode is not 0644"
grep -q '== "Darwin"' <<<"$block" || fail "task is not Darwin-only"
echo "ok: task copies op.zsh, Darwin, 0644"

mkdir -p "$work/home/.config/op"
echo 'gh() { :; }' >"$work/home/.config/op/plugins.sh"
out="$(env -u CLAUDECODE HOME="$work/home" zsh -c "source '$mod'; whence -w gh" 2>&1 || true)"
[[ $out == *function* ]] || fail "CLAUDECODE unset: gh is not a function ($out)"
echo "ok: CLAUDECODE unset -> gh is a function"
out="$(CLAUDECODE=1 HOME="$work/home" zsh -c "source '$mod'; whence -w gh" 2>&1 || true)"
[[ $out != *function* ]] || fail "CLAUDECODE=1: gh was wrapped ($out)"
echo "ok: CLAUDECODE=1 -> gh is not a function"
echo "PASS"

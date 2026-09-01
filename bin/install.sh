#!/bin/bash

set -eu

if ! ansible-galaxy collection list 2>/dev/null | grep -q 'community.crypto'; then
  ansible-galaxy collection install community.crypto
fi

if ! ansible-galaxy collection list 2>/dev/null | grep -q 'community.general'; then
  ansible-galaxy collection install community.general
fi

# The macOS playbook installs everything via Homebrew and has no
# become/sudo tasks, so never prompt for a become password on Darwin.
if [ "$(uname)" = "Darwin" ]; then
  ansible-playbook "$@"
elif [ -n "${ANSIBLE_BECOME_PASS:-}" ]; then
  ansible-playbook "$@"
else
  ansible-playbook --ask-become-pass "$@"
fi

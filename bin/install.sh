#!/bin/bash

set -eu

if ! ansible-galaxy collection list 2>/dev/null | grep -q 'community.crypto'; then
  ansible-galaxy collection install community.crypto
fi

if ! ansible-galaxy collection list 2>/dev/null | grep -q 'community.general'; then
  ansible-galaxy collection install community.general
fi

# The macOS playbook has no become tasks; it prompts for the sudo password
# itself (vars_prompt) for casks whose pkg installer needs it.
if [ "$(uname)" = "Darwin" ]; then
  ansible-playbook "$@"
elif [ -n "${ANSIBLE_BECOME_PASS:-}" ]; then
  ansible-playbook "$@"
else
  ansible-playbook --ask-become-pass "$@"
fi

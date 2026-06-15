#!/bin/bash

set -eu

if ! ansible-galaxy collection list 2>/dev/null | grep -q 'community.crypto'; then
  ansible-galaxy collection install community.crypto
fi

if ! ansible-galaxy collection list 2>/dev/null | grep -q 'community.general'; then
  ansible-galaxy collection install community.general
fi

# Retrieve sudo password from macOS keychain if on macOS and unset
if [ -z "${ANSIBLE_BECOME_PASS:-}" ] && [ "$(uname)" = "Darwin" ]; then
  if security find-generic-password -s "sudo" -a "$USER" -w &>/dev/null; then
    export ANSIBLE_BECOME_PASS=$(security find-generic-password -s "sudo" -a "$USER" -w)
  fi
fi

if [ -n "${ANSIBLE_BECOME_PASS:-}" ]; then
  ansible-playbook "$@"
else
  ansible-playbook --ask-become-pass "$@"
fi

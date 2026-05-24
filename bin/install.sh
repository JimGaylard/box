#!/bin/bash

set -eu

if ! ansible-galaxy collection list 2>/dev/null | grep -q 'community.crypto'; then
  ansible-galaxy collection install community.crypto
fi

ansible-playbook --ask-become-pass "$@"

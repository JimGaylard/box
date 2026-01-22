#!/bin/bash

set -eu

ansible-galaxy collection install community.crypto --force-with-deps
ansible-playbook --ask-become-pass $1

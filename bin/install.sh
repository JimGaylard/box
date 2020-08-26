#!/bin/bash

set -eu

ansible-playbook --ask-become-pass playbooks/main.yml

#!/bin/bash

set -eu

ansible-playbook --ask-become-pass $1

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal workstation setup repository using Ansible playbooks to configure development environments. It installs packages and deploys dotfiles to the home directory.

## Commands

**Install on a system (requires Ansible):**
```bash
bin/install.sh playbooks/debian.yml   # For Debian/Ubuntu
bin/install.sh playbooks/redhat.yml   # For Fedora/RHEL
```

The install script runs `ansible-playbook --ask-become-pass` on the specified playbook.

## Structure

- `playbooks/` - Ansible playbooks per distro family (debian.yml, redhat.yml)
- `dotfiles/` - Configuration files deployed to home directory
- `bin/` - Installation scripts

## Playbook Architecture

Each distro playbook:
1. Installs system packages via the distro's package manager (apt/dnf)
2. Copies dotfiles from `dotfiles/` to `~/` (e.g., bashrc → ~/.bashrc)
3. Sets up Neovim with vim-plug and installs plugins

Dotfiles are copied with `force: yes`, overwriting existing files.

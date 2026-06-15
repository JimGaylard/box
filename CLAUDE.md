# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal workstation setup repository using Ansible playbooks to configure development environments. It installs packages and deploys dotfiles to the home directory.

## Commands

**Install on a system (requires Ansible):**
```bash
bin/install.sh playbooks/debian.yml   # For Debian/Ubuntu
bin/install.sh playbooks/redhat.yml   # For Fedora/RHEL
bin/install.sh playbooks/macos.yml    # For macOS (Darwin)
```

The install script runs `ansible-playbook --ask-become-pass` on the specified playbook.

## Structure

- `playbooks/` - Ansible playbooks per distro family (debian.yml, redhat.yml, macos.yml)
- `dotfiles/` - Configuration files deployed to home directory
- `bin/` - Installation scripts

## Playbook Architecture

Each distro/OS playbook:
1. Installs system packages via the system package manager (apt/dnf/homebrew)
2. Copies dotfiles from `dotfiles/` to `~/` (e.g., bashrc → ~/.bashrc)
3. Sets up Neovim with vim-plug and installs plugins

Dotfiles are copied with `force: yes`, overwriting existing files.

## Key Behaviors & Tips

- **Keychain Password Integration**: On macOS, `bin/install.sh` automatically retrieves the sudo password from the system keychain (`security find-generic-password -s "sudo" -a "$USER" -w`) if the `ANSIBLE_BECOME_PASS` environment variable is not set.
- **Selective Provisioning**: To only update dotfiles and skip installing packages or setup modules, run with the `dotfiles` tag:
  ```bash
  bin/install.sh playbooks/macos.yml --tags dotfiles
  ```
- **Zsh Completion Order**: In `dotfiles/zshrc`, `compinit` must be initialized *before* modular configurations in `~/.zshrc.d/` are sourced to ensure functions using `compdef` (such as `uv` or `aws` completions) do not cause "command not found: compdef" errors.


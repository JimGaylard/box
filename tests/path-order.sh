#!/usr/bin/env bash
# Offline test: in a fresh login shell built from the repo's zshrc, ~/.local/bin
# (uv's managed python), ~/go/bin and ~/.cargo/bin must each precede
# /opt/homebrew/bin. Pass a dotfiles dir as $1 to test another checkout.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
dots="${1:-$root/dotfiles}"
work="$(mktemp -d)"
fail() { echo "FAIL: $*" >&2; exit 1; }

cp "$dots/zshrc" "$work/.zshrc"
cp -R "$dots/zshrc.d" "$work/.zshrc.d"
order="$(env -i HOME="$work" PATH=/usr/bin:/bin zsh -l -i -c 'print -l $path' 2>/dev/null </dev/null)"
echo "$order" | nl -ba
idx() { echo "$order" | grep -nxF "$1" | head -1 | cut -d: -f1; }
brew="$(idx /opt/homebrew/bin)"
[ -n "$brew" ] || fail "/opt/homebrew/bin not on PATH"
for d in "$work/.local/bin" "$work/go/bin" "$work/.cargo/bin"; do
  i="$(idx "$d")"
  [ -n "$i" ] || fail "$d not on PATH"
  [ "$i" -lt "$brew" ] || fail "$d (#$i) is not ahead of /opt/homebrew/bin (#$brew)"
done
echo "PASS"

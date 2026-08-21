#!/bin/sh
# Read-only verification for dev-cli-tools. Exits non-zero if a core tool is missing.
fail=0
for t in rg fd fzf bat eza zoxide jq gh; do
  if command -v "$t" >/dev/null 2>&1; then
    echo "OK   $t"
  else
    echo "FAIL $t: not installed"
    fail=1
  fi
done
grep -q 'fzf --zsh' "$HOME/.zshrc" 2>/dev/null \
  && echo "OK   fzf shell integration line present" \
  || { echo "FAIL fzf integration missing from ~/.zshrc (Ctrl-R won't work)"; fail=1; }
grep -q 'zoxide init' "$HOME/.zshrc" 2>/dev/null \
  && echo "OK   zoxide init line present" \
  || { echo "FAIL zoxide init missing from ~/.zshrc"; fail=1; }
exit $fail

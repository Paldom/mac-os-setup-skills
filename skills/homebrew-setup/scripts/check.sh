#!/bin/sh
# Read-only verification for homebrew-setup. Exits non-zero on failure.
fail=0
if ! command -v brew >/dev/null 2>&1; then
  echo "FAIL brew: not on PATH"
  exit 1
fi
echo "OK   brew: $(brew --version | head -1)"
prefix=$(brew --prefix)
arch=$(uname -m)
if [ "$arch" = "arm64" ] && [ "$prefix" != "/opt/homebrew" ]; then
  echo "FAIL prefix: $prefix on arm64 (expected /opt/homebrew - Rosetta-era install?)"
  fail=1
elif [ "$arch" = "x86_64" ] && [ "$prefix" != "/usr/local" ]; then
  echo "FAIL prefix: $prefix on x86_64 (expected /usr/local)"
  fail=1
else
  echo "OK   prefix: $prefix ($arch)"
fi
if grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  n=$(grep -c 'brew shellenv' "$HOME/.zprofile")
  if [ "$n" -eq 1 ]; then echo "OK   .zprofile: shellenv line present once"
  else echo "WARN .zprofile: shellenv line appears $n times (dedupe)"; fi
else
  echo "FAIL .zprofile: no brew shellenv line (new terminals won't find brew)"
  fail=1
fi
exit $fail

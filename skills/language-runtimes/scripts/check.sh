#!/bin/sh
# Read-only verification for language-runtimes: detects managers and conflicts.
# Exits non-zero only on a two-managers-one-runtime conflict.
fail=0
managers_node=""; managers_py=""; managers_java=""
[ -d "$HOME/.nvm" ] && managers_node="$managers_node nvm"
command -v fnm >/dev/null 2>&1 && managers_node="$managers_node fnm"
command -v pyenv >/dev/null 2>&1 && managers_py="$managers_py pyenv"
# uv coexists with interpreter managers (it can consume their pythons) - report, don't count
command -v uv >/dev/null 2>&1 && echo "INFO python: uv present ($(uv --version 2>/dev/null))"
command -v jenv >/dev/null 2>&1 && managers_java="$managers_java jenv"
if command -v mise >/dev/null 2>&1; then
  mise ls 2>/dev/null | grep -qi '^node' && managers_node="$managers_node mise"
  mise ls 2>/dev/null | grep -qi '^python' && managers_py="$managers_py mise"
  mise ls 2>/dev/null | grep -qi '^java' && managers_java="$managers_java mise"
fi
report() { # $1 runtime, $2 managers, $3 version-cmd
  set -- "$1" "$2" "$3"
  n=$(echo "$2" | wc -w | tr -d ' ')
  v=$(eval "$3" 2>/dev/null | head -1)
  if [ "$n" -gt 1 ]; then
    echo "FAIL $1: multiple managers active:$2 (pick one)"
    fail=1
  elif [ "$n" -eq 1 ]; then
    echo "OK   $1: manager$2 -> ${v:-not installed}"
  else
    echo "INFO $1: no version manager (${v:-runtime absent})"
  fi
}
report node "$managers_node" "node -v"
report python "$managers_py" "python3 --version"
report java "$managers_java" "java --version"
exit $fail

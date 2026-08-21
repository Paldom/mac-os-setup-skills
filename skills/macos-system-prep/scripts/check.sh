#!/bin/sh
# Read-only verification for macos-system-prep. Exits non-zero on failure.
fail=0
check() { # $1 label, $2 command
  if out=$(eval "$2" 2>&1); then
    echo "OK   $1: $out"
  else
    echo "FAIL $1: $out"
    fail=1
  fi
}
check "macOS version" "sw_vers -productVersion"
check "architecture" "uname -m"
check "Xcode CLT path" "xcode-select -p"
check "git" "git --version"
check "clang" "clang --version | head -1"
if [ "$(uname -m)" = "arm64" ]; then
  if /usr/bin/pgrep -q oahd; then
    echo "OK   rosetta: installed (oahd running)"
  else
    echo "INFO rosetta: not installed (fine unless Intel-only binaries are needed)"
  fi
fi
[ -d "$HOME/Developer" ] || [ -d "$HOME/src" ] || [ -d "$HOME/projects" ] \
  && echo "OK   source dir: present" || echo "INFO source dir: none of ~/Developer ~/src ~/projects exists yet"
exit $fail

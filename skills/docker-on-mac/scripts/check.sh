#!/bin/sh
# Read-only verification for docker-on-mac. Exits non-zero on failure.
fail=0
if ! command -v docker >/dev/null 2>&1; then
  echo "FAIL docker CLI not on PATH"
  exit 1
fi
echo "OK   docker CLI: $(docker --version)"
if docker info >/dev/null 2>&1; then
  echo "OK   engine reachable (context: $(docker context show 2>/dev/null))"
else
  echo "FAIL engine not reachable - is the runtime (Desktop/OrbStack/colima) started?"
  fail=1
fi
if docker run --rm hello-world >/dev/null 2>&1; then
  echo "OK   hello-world ran"
else
  echo "FAIL hello-world failed"
  fail=1
fi
exit $fail

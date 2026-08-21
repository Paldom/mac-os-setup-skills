#!/bin/sh
# Read-only verification for web-dev-setup. Exits non-zero if a started service fails its probe.
fail=0
command -v pnpm >/dev/null 2>&1 && echo "OK   pnpm: $(pnpm --version)" || echo "INFO pnpm: not installed"
if command -v psql >/dev/null 2>&1; then
  if psql -d postgres -Atc 'select 1;' >/dev/null 2>&1; then
    echo "OK   postgres: reachable ($(psql --version))"
  else
    echo "FAIL postgres: psql present but connection failed (service started? PATH major matches data dir?)"
    fail=1
  fi
else
  echo "INFO postgres: psql not on PATH (keg-only versioned formula needs a PATH line)"
fi
if command -v redis-cli >/dev/null 2>&1; then
  if [ "$(redis-cli ping 2>/dev/null)" = "PONG" ]; then
    echo "OK   redis: PONG"
  else
    echo "FAIL redis: installed but not answering (brew services start redis)"
    fail=1
  fi
else
  echo "INFO redis: not installed"
fi
exit $fail

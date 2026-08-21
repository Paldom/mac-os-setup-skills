---
name: web-dev-setup
description: Adds full-stack web extras to a Mac dev environment - pnpm (corepack gone from Node 25+), pinned PostgreSQL and Redis via brew services with keg-only PATH fixes, and an API client. Use for "set up my Mac for web development", "install postgres/redis locally", "brew services database", "install pnpm", "psql not found". Not for Node version managers, Docker databases, deploys, or SQL debugging.
---

# Web Dev Setup

Layers the web-stack specifics on top of a working base: a fast package
manager, local databases run the boring-reliable way (brew services,
pinned majors), and an API client.

## When NOT to use

- Node/Python versions → `language-runtimes` (prerequisite for pnpm use)
- Databases in containers (prod parity, multiple versions) →
  `docker-on-mac`; this skill is the brew-services path
- Project `npm install`/schema work/SQL → project work
- DB GUI browsers → `mac-dev-apps` (`dbeaver-community`/`tableplus`)

## Prerequisites

`brew` present; for pnpm, a Node runtime (→ `language-runtimes`).

## Safety rails

- **Pin the Postgres major** (`postgresql@17`/`@18`). Major upgrades
  require `pg_upgrade` — a blind `brew upgrade` across majors strands the
  data directory. Never uninstall/upgrade an existing versioned postgres
  without explicit consent and a backup note.
- brew-services databases bind localhost by default — keep it that way;
  no config changes toward 0.0.0.0.
- PATH additions are grep-guarded appends to `~/.zshrc`.

## Workflow

Ask which components the user wants — pnpm, databases, API client — and
do only those ("install pnpm" alone means pnpm alone; done = the selected
subset). Before starting a database, inventory what's already there:

```sh
brew services list
lsof -nP -iTCP:5432 -sTCP:LISTEN 2>/dev/null   # something already on the postgres port?
brew list --versions | grep -E '^postgresql|^redis'
```

An existing instance/data dir means a deliberate plan (reuse it, or a
different port), not a second install on 5432.

### 1. pnpm

```sh
brew install pnpm     # standalone binary formula (no runtime node dependency)
pnpm --version
```

Why brew, not corepack: **corepack stopped shipping with Node 25+** (still
present in Node 24 LTS). Brew's pnpm works regardless of Node version and
updates with everything else. In repos with a `packageManager` field, pnpm
respects the pin. (Yarn wanted instead? `npm i -g corepack && corepack
enable`, per Yarn's docs. Bun as an extra runtime/test-runner:
`brew install oven-sh/bun/bun` — a complement, not a Node replacement.)

### 2. PostgreSQL (pinned major)

Pick the major once and use it consistently (`PG=postgresql@17` below —
substitute @18 the same way everywhere; the unversioned alias tracks the
newest major, which is exactly what we avoid):

```sh
PG=postgresql@17
brew install "$PG"
brew services start "$PG"           # launchd service, starts at login
```

Versioned formulae are **keg-only** — `psql` isn't on PATH until:

```sh
grep -q "$PG" ~/.zshrc || echo "export PATH=\"$(brew --prefix $PG)/bin:\$PATH\"" >> ~/.zshrc
```

Verify (fresh shell):

```sh
psql --version
psql -d postgres -c 'select version();'   # default superuser = your macOS username, no password
# The bare-`psql` "database <user> does not exist" quirk: create it once,
# but DON'T blanket-swallow errors - only ignore already-exists:
createdb "$USER" 2>&1 | grep -v 'already exists' || true
```

### 3. Redis

```sh
brew install redis
brew services start redis
redis-cli ping        # PONG
```

### 4. API client

```sh
brew install --cask bruno      # git-friendly, offline, no account
# or: brew install --cask postman
```

### 5. Verify

```sh
brew services list    # postgresql@17 + redis "started"
sh "${CLAUDE_SKILL_DIR}/scripts/check.sh"
```

## Output spec

Done means: pnpm runs; postgres (pinned major) and redis show `started` in
`brew services list` and answer a query/ping in a fresh shell; API client
installed; user warned about the pg_upgrade rule. Report actual outputs.

## Gotchas

- `psql: command not found` after install = keg-only PATH, not a broken
  install.
- `FATAL: database "<user>" does not exist` on bare `psql` = the default-db
  quirk; `createdb $USER` or `psql -d postgres`.
- brew services runs per-user at login. If the service shows `error`,
  check `brew services info postgresql@17` and the log it names —
  a stale postmaster.pid after a crash is the usual cause.
- Homebrew's `postgresql` unversioned alias follows the newest major
  (currently 18) — installing by alias then re-installing later can jump
  majors; that's why this skill pins.
- Redis's AGPL-era licensing rarely matters for plain local dev, but org
  policy may prohibit AGPL software outright — `valkey` is the BSD-fork
  drop-in when it does.
- Multiple postgres majors side by side: both keg-only, both can run —
  keep distinct ports (`port` in each postgresql.conf) or run one at a
  time via services.

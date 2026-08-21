---
name: language-runtimes
description: Sets up language runtimes on macOS the modern way - mise for Node LTS, Java Temurin LTS, Go and Ruby, uv for Python, rustup for Rust; one manager per runtime, preserving existing nvm/pyenv/jenv first. Use for "install node/python/java versions", "set up mise/uv", "runtime version managers", "manager conflicts". Not for project dependencies, pnpm/databases, Android JDK wiring, or OS packages.
license: MIT
---

# Language Runtimes

Installs the full runtime lineup — Node, Python, Java, Go, Rust, Ruby on
request — under the modern manager set: **mise** for everything except
Python (**uv**) and Rust (**rustup**). One manager per runtime; competing
managers racing to put shims first in PATH is the top cause of "node is
weird" machines.

## When NOT to use

- Project-level deps (`npm install`, venvs, requirements.txt) → native
- pnpm/corepack, databases → `web-dev-setup`
- JDK specifically for Android Studio/Gradle → `mobile-dev-setup`
- Upgrading installed runtimes → `mac-maintenance`

## Prerequisites

`brew` present (→ `homebrew-setup`).

## The rules

1. **Detect before installing.** `[ -d ~/.nvm ]`, `command -v pyenv jenv
   mise asdf uv fnm volta conda sdk`, `grep -E
   'nvm|pyenv|jenv|mise|asdf|fnm|volta|conda|sdkman' ~/.zshrc ~/.zprofile
   ~/.zshenv 2>/dev/null`, and `type -a node python3 java` to see what
   actually wins PATH today.
2. **Preserve existing.** A working manager stays (an nvm/pyenv/jenv setup
   is not broken — don't stack mise on top of it for the same runtime).
   Multiple already present → show the conflict, ask which to keep,
   disable the loser's init line (with consent), don't delete its data.
   An **explicit user tool choice wins** ("install nvm" means nvm —
   classic-manager details: [references/runtime-versions.md](references/runtime-versions.md)).
3. **Boundaries:** uv owns Python entirely (don't enable mise's python);
   rustup owns Rust; mise owns node/java/go/ruby.

## Safety rails

- `.zshrc` additions are grep-guarded appends; back up before edits.
- Never `sudo pip/npm/gem` and never modify system Python/Ruby — macOS's
  runtimes are part of the OS.
- Disabling a manager = comment/remove its init lines; deleting `~/.nvm`,
  `~/.pyenv` etc. only on explicit request (it deletes installed runtimes).

## Workflow (fresh machine — the default)

```sh
brew install mise uv rustup
grep -q 'mise activate' ~/.zshrc || echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
eval "$(mise activate zsh)"                  # current shell too

# Node - LTS
mise use -g node@lts
# .nvmrc/.node-version support is off by default:
mise settings add idiomatic_version_file_enable_tools node

# Java - Temurin LTS (plain temurin tracks the latest NON-LTS - pin the LTS)
mise use -g java@temurin-25

# Go
mise use -g go@latest

# Ruby (on request; never system Ruby - it's EOL 2.6, immutable)
# mise use -g ruby@3

# Python - uv owns it
uv python install 3.13        # 3.14 is current; 3.13 has the broadest wheel coverage - ask
# Plain `python3` on PATH from uv too? add --default (shims into ~/.local/bin -
# make sure that dir is on PATH):
#   uv python install 3.13 --default
uv tool install ruff          # CLI tools (pipx replacement; installs to ~/.local/bin)
# projects: uv init / uv add / uv run / uv sync

# Rust - rustup (brew formula; NOT brew's `rust`)
export PATH="$(brew --prefix rustup)/bin:$PATH"   # + grep-guarded .zshrc line
rustup default stable
```

## Existing classic setups (nvm / pyenv / jenv)

Preserve-existing wins — keep them running, don't migrate unasked:

- **nvm**: already sourced from `.zshrc`; `nvm install --lts && nvm alias
  default 'lts/*'` for a new version. Slow-startup mitigation: `--no-use`
  on the source line (defers activation; doesn't zero the cost — full
  lazy-load needs zsh-nvm or switching to mise/fnm).
- **pyenv**: builds from source — needs `brew install openssl readline
  sqlite3 xz zlib tcl-tk`; init lines per its README. uv coexists fine
  (it can use pyenv's interpreters).
- **jenv**: `jenv add <jdk-home>`, `jenv versions`, `jenv global <name>`;
  JDKs from versioned Temurin casks (`brew install --cask temurin@25`).

Migration to mise/uv only on explicit request: install the modern manager,
move the global default over, comment out the old init lines, leave the
old data dirs untouched.

## Verify

```sh
sh "${CLAUDE_SKILL_DIR}/scripts/check.sh"
```

Fresh shell: `node -v` (LTS major), `python3 --version` or `uv run python
--version`, `java --version` (Temurin LTS), `go version`, `rustc
--version` — each resolving from its one manager (`type -a node` shows
exactly one manager's path).

## Output spec

Done means: every requested runtime installed with exactly one manager
active per runtime, global defaults set, init lines present once,
fresh-shell verification passes, and any pre-existing setup was preserved
or consciously replaced.

## Gotchas

- **Two managers, one runtime** = flaky versions + slow shells. `type -a
  node` / `which -a python3` expose the race.
- Plain `temurin` cask / `java@latest` = newest non-LTS JDK; the LTS is
  the versioned pin (`temurin-25`). Multiple JDKs: `/usr/libexec/java_home
  -V`.
- `uv self update` errors on brew installs (standalone-installer feature)
  — update via `brew upgrade uv`.
- mise's `.nvmrc` parsing is opt-in (the `idiomatic_version_file` setting
  above); without it, per-project Node pins silently don't apply.
- Node's corepack no longer ships with Node 25+ — pnpm/yarn install
  changed; that's `web-dev-setup` territory.
- Homebrew's `openjdk` formulae are keg-only and need a `sudo ln -sfn`
  step before `java_home` sees them — Temurin casks and mise's java avoid
  this.
- Facts that age (current LTS lines, versions, classic-manager commands):
  [references/runtime-versions.md](references/runtime-versions.md).

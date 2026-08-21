---
name: homebrew-setup
description: Installs and configures Homebrew on macOS - official installer, shellenv line in ~/.zprofile, brew doctor, and the Brewfile/brew bundle workflow with mas. Use for "install homebrew", "brew command not found", "brew doctor problems", "set up a Brewfile", "brew bundle dump/restore". Not for choosing which tools or apps to install, upgrade runs, or Xcode Command Line Tools.
---

# Homebrew Setup

Installs Homebrew correctly (right prefix, PATH wired for every future
shell), verifies it, and establishes the Brewfile workflow that makes the
machine reproducible. This skill **owns** the brew line in `~/.zprofile` and
the Brewfile regeneration workflow — other skills install packages but never
rewrite those.

## When NOT to use

- Which CLI tools to install → `dev-cli-tools`; GUI apps → `mac-dev-apps`
- Routine `brew update`/`upgrade`/`cleanup` runs → `mac-maintenance`
- Xcode CLT missing → `macos-system-prep` (prerequisite of this skill)
- Local databases as services → `web-dev-setup`

## Prerequisites

`xcode-select -p` must resolve. If not, stop and run `macos-system-prep`
first — and never let the Homebrew installer and the CLT GUI installer run
at the same time.

## Safety rails

- The installer script asks for the admin password and prints what it will
  do — let the user see that; don't suppress output.
- Append to `~/.zprofile` only with a grep-guard (idempotent; no duplicate
  lines on re-run).
- `brew bundle dump` refuses an existing Brewfile; `--force` overwrites
  it and `brew bundle cleanup --force` **uninstalls** everything not
  listed — update via temp-candidate + diff + user approval, never a
  blind `--force`.
- Analytics: surface `brew analytics off` as a choice; don't decide silently.

## Workflow

### 1. Detect

```sh
command -v brew && brew --prefix && brew --version
```

Already installed → skip to step 3. Prefix sanity: `/opt/homebrew` on Apple
Silicon, `/usr/local` on Intel. An `/usr/local` brew on an arm64 machine is
a Rosetta-era install — flag it instead of piling a second install on top.

### 2. Install

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then wire PATH for future **login shells** (macOS terminal tabs are login
shells, so this covers normal use; non-login contexts inherit PATH from
their parent):

```sh
BREW_BIN=/opt/homebrew/bin/brew; [ -x "$BREW_BIN" ] || BREW_BIN=/usr/local/bin/brew
# Inspect any existing shellenv line first - a stale /usr/local line on an
# arm64 machine must be REPLACED (backup first), not treated as "already done":
grep -n 'shellenv' ~/.zprofile 2>/dev/null
# If none (or after removing a stale one):
grep -q "${BREW_BIN} shellenv" ~/.zprofile 2>/dev/null || {
  echo >> ~/.zprofile
  echo "eval \"\$(${BREW_BIN} shellenv)\"" >> ~/.zprofile
}
eval "$(${BREW_BIN} shellenv)"
```

### 3. Verify

```sh
brew --version
brew --prefix          # matches architecture
brew doctor            # "ready to brew" - warnings are advisory, errors are not
```

Confirm in a **new** terminal that `brew` resolves (that's the whole point
of the `.zprofile` line). Optionally: `brew analytics off`.

### 4. Brewfile workflow (reproducibility)

`brew bundle` is built into brew (no tap needed). Core loop:

```sh
# Snapshot current machine -> Brewfile. Note: dump REFUSES an existing file
# (it does not prompt). To update an existing Brewfile safely: dump to a
# temp candidate, diff, then replace only after the user approves.
brew bundle dump --describe --file=/tmp/Brewfile.candidate
diff -u ~/Brewfile /tmp/Brewfile.candidate    # show the user; then move over ~/Brewfile
# (First-ever snapshot with no existing file: dump straight to ~/Brewfile.)

# Restore/converge a machine from the file (installs AND upgrades listed items)
brew bundle install --file=~/Brewfile
# Check without changing anything (exit code for scripts)
brew bundle check --file=~/Brewfile
# List what's installed but NOT in the file (review before any cleanup --force)
brew bundle cleanup --file=~/Brewfile
```

Default file resolution when `--file` is omitted: `./Brewfile`, or with
`--global`: `~/.Brewfile` (and XDG variants). Brewfile entries cover `brew`
(formulae), `cask`, `tap`, `mas "App", id: N` (needs `brew install mas` and
an App Store sign-in), and `vscode "publisher.extension"`.

Recommend: keep the Brewfile in a dotfiles repo (see `dotfiles-setup`) and
re-dump after intentional installs. This file is infrastructure — the
10-minute path from a blank Mac back to all your tools.

### 5. Verify script

```sh
sh "${CLAUDE_SKILL_DIR}/scripts/check.sh"
```

Details that age (current version, support tiers, cask renames):
[references/homebrew-facts.md](references/homebrew-facts.md).

## Output spec

Done means: `brew doctor` passes in a fresh shell, the shellenv line exists
exactly once in `~/.zprofile`, and (if requested) a Brewfile exists and
`brew bundle check` passes. Report actual outputs.

## Gotchas

- `brew install docker` installs the **CLI formula only** (no engine); the
  Docker Desktop cask is `docker-desktop` (renamed from `docker` mid-2025;
  the old token still resolves). Container-runtime choice → `docker-on-mac`.
- `mas` cannot sign in to the App Store (`mas signin` is gone) — the user
  signs into the App Store app once, then `mas install <id>` works.
- Migrated-from-Intel Macs often carry a `/usr/local` brew alongside
  `/opt/homebrew`; `type -a brew` exposes it. One brew per architecture —
  don't maintain both.
- Homebrew requires macOS Sonoma 14+ (current tiers) and drops Intel to
  best-effort from late 2026 — on older/Intel machines expect missing
  bottles and slow source builds.
- `brew bundle install` also **upgrades** listed packages by default; use
  `HOMEBREW_BUNDLE_NO_UPGRADE=1` when that's unwanted.

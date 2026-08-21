---
name: mac-maintenance
description: Runs recurring update maintenance on a developer Mac - brew update/upgrade with cask auto_updates semantics, cleanup, Brewfile re-capture, mas and macOS updates, Oh My Zsh and runtime managers, safe disk reclaim. Use for "update everything", "upgrade brew packages", "run maintenance", "why didn't brew update chrome". Not for first-time installs, broken Homebrew, or project dependency bumps.
---

# Mac Maintenance

The recurring "keep it current" pass, run safely: show before changing,
respect self-updating apps and pinned majors, never surprise-restart the
machine. Designed to be re-run weekly/monthly — every step is idempotent.

## When NOT to use

- First-time setup of anything → the respective setup skill
- Broken brew (`doctor` errors) → `homebrew-setup`
- Project dependency upgrades (package.json, lockfiles) → project work
- macOS **major**-version migration → manual, deliberate; only point at
  System Settings

## Safety rails

- **Timing check:** ask/warn if the user is mid-release or pre-demo —
  upgrade waves before deadlines are self-inflicted outages.
- Show `brew outdated` **before** `brew upgrade`; list, then act.
- `softwareupdate --install` may restart — explicit consent, never
  `--restart` unattended; prefer `--recommended --os-only` for scripts.
- Never blind-upgrade databases across **majors** — versioned formulae
  (`postgresql@17`) stay within their major, but unversioned installs
  (`postgresql` alias, `mysql`) can jump and strand the data dir
  (pg_upgrade territory). Never `brew bundle cleanup --force` or `docker
  system prune` without showing the removal list first.
- Report what changed, what was skipped and why.

## Workflow

### 1. Homebrew core pass

```sh
brew update                 # refresh brew + metadata (not the packages)
brew outdated               # SHOW the user this list first
brew services list          # data-bearing services in the outdated list?
```

Before upgrading, scan the outdated list for **major-version-sensitive
packages**: database services installed via *unversioned* formulae
(`postgresql` alias, `mysql`, `mongodb-*`) can jump majors and strand
data (versioned `postgresql@17` stays within 17.x — that's why we pin).
Exclude those from the pass (`brew pin <formula>` makes it stick) or
handle them deliberately with the user. Then:

```sh
brew upgrade                # upgrade unpinned formulae + non-auto-update casks
brew cleanup --dry-run && brew autoremove --dry-run   # preview what goes
brew cleanup && brew autoremove                        # then reclaim
brew doctor                 # advisory warnings are fine; errors are not
```

Cask semantics — the perennial confusion: casks marked `auto_updates`
(Chrome, VS Code, Slack, …) are **skipped by design** — the apps update
themselves. Forcing brew ownership: `brew upgrade --cask --greedy` (or the
narrower `--greedy-auto-updates`) — usually unnecessary; default to
letting self-updaters work.

### 2. Brewfile re-capture (if the user keeps one)

Ask where the tracked Brewfile lives (`~/Brewfile` or
`~/dotfiles/Brewfile`), then update it via candidate + diff — a blind
`dump --force` flattens curated comments and captures accidental installs:

```sh
BF=~/Brewfile   # or ~/dotfiles/Brewfile - the user's tracked copy
brew bundle check --file="$BF" || echo "drift"
brew bundle dump --describe --file=/tmp/Brewfile.candidate
diff -u "$BF" /tmp/Brewfile.candidate     # user approves, then replace $BF
```

### 3. App Store + macOS

```sh
mas outdated && mas update            # App Store apps (signed-in App Store required)
softwareupdate --list                 # read-only
# with consent + restart warning:
sudo softwareupdate --install --recommended --os-only
```

### 4. Shell & runtime layer (detect, then update what exists)

```sh
[ -d ~/.oh-my-zsh ] && zsh -ic 'omz update'                 # omz is a shell function - needs interactive zsh
command -v mise >/dev/null && { brew upgrade mise 2>/dev/null; mise outdated; mise upgrade; }
[ -d ~/.nvm ] && echo "nvm: on request - nvm install 'lts/*' --reinstall-packages-from=default (new version, migrates globals; old versions stay until nvm uninstall)"
command -v pyenv >/dev/null && echo "pyenv: new Python versions are installed, not upgraded - pyenv install <ver> on request"
command -v uv >/dev/null && uv tool upgrade --all           # uv itself updates via brew
command -v pipx >/dev/null && pipx upgrade-all
command -v rustup >/dev/null && rustup update               # toolchains; rustup itself via brew
command -v gh >/dev/null && gh extension upgrade --all
npm outdated -g 2>/dev/null; echo "npm -g: review the list above (outdated exits non-zero when items exist), then npm update -g"
```

Rules: managers update *within* configured ranges (mise respects
mise.toml; pnpm respects `packageManager` pins) — don't bump project pins
here. gcloud installed via brew cask updates via brew, not `components
update` (dual-ownership drift).

### 5. Disk reclaim (on request)

Read-only first: `docker system df`, `brew cleanup --dry-run`,
`du -sh ~/Library/Developer/Xcode/DerivedData 2>/dev/null`. Then safe
reclaims: `brew cleanup -s`, `npm cache verify`. **Destructive tier —
show the list, then confirm:** `docker system prune` (volumes excluded by
default; `--volumes` deletes data — treat as data loss); `xcrun simctl
list devices unavailable` then `xcrun simctl delete unavailable`
(irreversibly deletes those simulators **and their app data**);
DerivedData deletion (rebuild cost).

### 6. One-command habit (optional)

`brew install topgrade` runs ~everything (brew, mas, npm, rustup, mise,
uv, omz, gh, …). Ship it **with a reviewed config**, not defaults:

```toml
# ~/.config/topgrade.toml
[misc]
disable = ["system", "mas"]   # OS + App Store stay manual/consented
[brew]
autoremove = true
```

`topgrade --dry-run` first. Prefer the manual routine above when the user
dislikes meta-tools.

### 7. Report

Summarize: upgraded (with notable version jumps), skipped (auto-update
casks, pinned majors, deferred OS update), disk reclaimed, and anything
that now needs a new shell/restart.

## Output spec

Done means: the pass ran in the order above with consents honored,
`brew doctor` is clean-or-advisory, Brewfile matches reality (if kept),
and the user got the change report. Nothing pinned or major-version
-sensitive moved without explicit approval.

## Gotchas

- `brew update` vs `upgrade` naming trips apt users — update = metadata,
  upgrade = packages.
- brew auto-updates itself before installs (24h cadence) — a "quick
  install" sometimes triggers a long metadata refresh; that's normal.
- `mas update` needs the App Store signed in; it can't purchase.
- `nvm install --lts` installs a **new** version — old ones remain until
  `nvm uninstall`; global packages migrate only with
  `--reinstall-packages-from`.
- `uv self update` fails on brew installs by design (standalone-installer
  feature) — `brew upgrade uv`.
- Post-upgrade breakage checklist: `xcode-select -p` after macOS updates
  (CLT pointer), reshim after runtime-manager changes, restart brew
  services if a database minor bumped.

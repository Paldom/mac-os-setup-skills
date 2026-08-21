---
name: macos-dev-setup
description: Orchestrates a complete fresh-Mac developer setup - inventories the machine, plans core steps (system prep, security, Homebrew, shell, git, runtimes, editor, dotfiles), asks which optional tracks to add, then runs each area skill in order with verification. Use for "set up my new Mac", "fresh macOS to dev environment", "make this Mac dev-ready". Not for a single area - use the focused skill.
license: MIT
---

# macOS Dev Setup (orchestrator)

Takes a Mac from fresh install (or half-configured) to a working dev
environment by sequencing the focused skills in this collection —
**plan first, install second**. Nothing is installed before the user has
seen and trimmed the plan.

## When NOT to use

Any single-area request routes to its focused skill:
`macos-system-prep` (CLT/updates/Rosetta) · `macos-security-baseline` ·
`macos-defaults` · `homebrew-setup` · `zsh-setup` · `dev-cli-tools` ·
`git-ssh-identity` · `language-runtimes` · `dotfiles-setup` ·
`editor-setup` · `mac-dev-apps` · `docker-on-mac` · `web-dev-setup` ·
`mobile-dev-setup` · `cloud-dev-setup` · `ai-dev-tools` ·
`mac-maintenance` (updates).

## Execution model

One agent, one session, this skill as conductor: for each selected area,
follow that skill's workflow (read its SKILL.md if not already loaded),
respect its safety rails, run its verification, and **stop on failure** —
report and fix before moving on. Each area skill re-checks its own
prerequisites, so a resumed or partial run is safe. Harness note: if the
platform can't load sibling skills, apply each area's canonical steps in
the same order and say so.

## Workflow

### 1. Inventory (read-only, before any proposal)

```sh
sw_vers && uname -m
xcode-select -p 2>/dev/null; command -v brew && brew --version
git config --global user.email 2>/dev/null; ls ~/.ssh/id_* 2>/dev/null
command -v node python3 docker 2>/dev/null; ls ~/.oh-my-zsh 2>/dev/null
df -h / | tail -1        # free disk
```

Existing pieces are **preserved** — the plan covers only gaps (never
reinstall brew, never touch existing SSH keys). Two inventory answers
shape the plan:
- **Existing dotfiles repo?** Restoring one happens **early** (right after
  Homebrew, before shell/git areas would write files it owns) — restoring
  last would overwrite freshly written config. *Creating* a new dotfiles
  repo stays last (it captures everything).
- **Disk gate:** heavy tracks have thresholds — don't start the iOS track
  under ~60 GB free (Xcode + runtimes + expansion headroom) or Android
  under ~20 GB; surface the number and let the user decide.

### 2. Propose the plan, ask twice, then go

**Core sequence** (order is load-bearing):

| # | Area | Skill | Why this position |
|---|---|---|---|
| 1 | OS updates, CLT, Rosetta | macos-system-prep | everything needs the CLT; update before installing |
| 2 | FileVault, firewall, Touch ID sudo | macos-security-baseline | before secrets land on disk |
| 3 | Homebrew + Brewfile | homebrew-setup | the package layer for all below |
| 4 | zsh + prompt | zsh-setup | owns .zshrc structure others append to |
| 5 | CLI toolbelt | dev-cli-tools | needs brew + .zshrc |
| 6 | git + SSH identity | git-ssh-identity | before first clone |
| 7 | Runtime managers | language-runtimes | before any project work |
| 8 | macOS defaults | macos-defaults | cosmetic; anytime after 1 |
| 9 | Editor | editor-setup | |
| 10 | Dotfiles repo | dotfiles-setup | last: captures everything above |

**Optional tracks — opt-in only, never transitively:** mac-dev-apps ·
docker-on-mac · web-dev-setup · mobile-dev-setup (asks iOS/Android) ·
cloud-dev-setup (asks providers) · ai-dev-tools (asks which CLIs).

Ask the user to confirm/trim the core + tracks (mention disk/time for
heavy tracks: full Xcode ~40–50 GB, Android ~15 GB). The stack is the
modern default throughout — Starship for the shell, mise + uv + rustup
for runtimes — with existing setups (Oh My Zsh, nvm/pyenv/jenv) preserved
per each skill's detect-first rules; only deviate if the user asks.

### 3. Execute with verification bracketing

Per area: run the skill's workflow → run its check (each ships a
read-only `scripts/check.sh` or verify commands) → only then advance.
A failed check stops the run; fix or explicitly defer with the user.

### 4. Final verification + manual-steps report

Run checks **only for areas that were selected**, each command separately
(no `&&` chains — one failure must not hide the rest), reading real
output:

```sh
brew doctor                                   # if homebrew area ran
git config --global user.email                # if git area ran
ssh -T git@github.com                         # success = "Hi <user>!..." text with EXIT CODE 1 (normal)
node -v; python3 --version                    # if runtimes area ran
docker info --format '{{.ServerVersion}}'     # if docker track ran (no image pull)
```

End with two lists: **done** (per area, with verify output) and **manual
steps remaining** — typically: App Store sign-in (Xcode/mas apps),
FileVault recovery-key storage, license keys (Parallels/VPN), Settings
Sync sign-in, Raycast hotkey, subscription logins for AI CLIs. The
machine isn't "done" until the user knows exactly what's left.

## Safety rails (inherited + orchestration-level)

- Every area skill's rails apply unchanged (consent for sudo/restarts,
  no secrets in chat, backup-before-modify, idempotent re-runs).
- No optional track installs without explicit selection; no "while I'm at
  it" additions.
- Long run interrupted? Re-invoke: completed areas verify clean and skip.
  (Resumption is safe for installs; preference-style changes like
  `macos-defaults` simply re-apply the chosen values — prior values are
  only recoverable if that skill's snapshot step was taken.)

## Output spec

Done means: every selected area's own verification passed, the final
whole-machine checks ran, and the summary lists done/deferred/manual
items. Recommend `mac-maintenance` as the recurring follow-up cadence.

## Gotchas

- The classic ordering mistake: Homebrew before CLT finishes (silent
  stalls) — area 1 completes before area 3 starts, no parallelizing those.
- Half-set-up machines hide breakage: run verifications even for areas
  being skipped as "already done".
- OS updates (area 1) may restart the machine — schedule the session
  accordingly; everything after resumes cleanly.
- Multi-hour tracks (Xcode download) go last within the selected set so a
  stall doesn't block the rest.

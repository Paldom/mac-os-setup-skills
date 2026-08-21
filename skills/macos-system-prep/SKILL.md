---
name: macos-system-prep
description: Prepares a fresh Mac's OS baseline for development - macOS software updates, Xcode Command Line Tools, optional Rosetta 2, and a source directory. Use for "new Mac before Homebrew", "install Command Line Tools", "xcode-select", "invalid active developer path", "clang not found", "install Rosetta". Not for security hardening, GUI tweaks, full Xcode, installing packages, or routine update runs.
license: MIT
---

# macOS System Prep

Takes a factory-fresh (or freshly upgraded) Mac to the point where package
managers and dev tools can be installed: current macOS, Xcode Command Line
Tools (CLT), optional Rosetta 2, and a home for source code. This is the
first step of any Mac dev setup — Homebrew refuses to build on stale SDKs and
needs the CLT.

## When NOT to use

- Security hardening (FileVault, firewall, Touch ID sudo) → `macos-security-baseline`
- Finder/Dock/keyboard preference tweaks → `macos-defaults`
- Installing Homebrew or any packages → `homebrew-setup`
- Full Xcode, iOS simulators, `xcodebuild` → `mobile-dev-setup`
- Whole-machine end-to-end setup → `macos-dev-setup`

## Scope assumptions

Apple Silicon primary (Intel notes inline); self-administered machine with an
admin account; macOS Sonoma 14 or newer (Homebrew's current minimum). Not for
MDM-managed fleets.

## Safety rails

- `softwareupdate --install` can trigger a **restart** — always warn and get
  explicit consent first; never pass `--restart` unattended.
- Rosetta install and CLT install are Apple-signed system changes — run only
  with user consent.
- Never run the CLT installer and the Homebrew installer in parallel — both
  can trigger CLT installation and the race causes silent failures.
- Everything here is idempotent: re-running detection commands is free.

## Workflow

### 1. Identify the machine

```sh
sw_vers                 # macOS version
uname -m                # arm64 = Apple Silicon, x86_64 = Intel
```

If `uname -m` prints `x86_64` on a machine the user says is Apple Silicon,
the shell is running under Rosetta — confirm with
`sysctl -n sysctl.proc_translated` (1 = translated). **Hard stop**: have
the user relaunch a native terminal (Get Info → untick "Open using
Rosetta") and do not install anything until `uname -m` prints `arm64` —
translated shells produce Intel Homebrew installs and duplicate-prefix
messes.

### 2. Update macOS first

Check what is pending (read-only, no admin needed):

```sh
softwareupdate --list
```

If updates exist, ask the user to install via **System Settings → General →
Software Update** (preferred — clear restart UX), or with consent:

```sh
sudo softwareupdate --install --recommended
```

Warn: OS updates may restart the Mac. Do this before Homebrew — formulae
assume a current SDK, and installing tools on a stale OS bakes in
problems. Note: `--os-only` would skip Command Line Tools updates —
don't add it here; after the OS update, re-run `softwareupdate --list`
and install any offered "Command Line Tools" item too.

### 3. Xcode Command Line Tools

Check, then install only if missing:

```sh
xcode-select -p >/dev/null 2>&1 && echo "CLT present: $(xcode-select -p)" || xcode-select --install
```

`xcode-select --install` opens a GUI dialog — the user must click Install and
accept the license; it takes 10–20 minutes. Wait for it to finish before any
other install step. Verify:

```sh
xcode-select -p        # expect /Library/Developer/CommandLineTools (or Xcode.app path)
git --version
clang --version
```

The CLT provides `git`, `clang`, `make`, and the macOS SDK — enough for
Homebrew and most non-Apple-platform development. Full Xcode is a separate,
multi-GB decision that belongs to `mobile-dev-setup`.

**Recurring gotcha:** macOS **major upgrades often invalidate the CLT**.
On "invalid active developer path", diagnose before anything destructive:
`xcode-select -p` — if it points at a moved/deleted Xcode, fix the pointer
(`sudo xcode-select -r` to reset, or `-s` to a valid path); if it points
at a missing/stale CLT, re-run `xcode-select --install`. Full CLT reset
(destructive to the CLT only, with consent) is the last resort:
`sudo rm -rf /Library/Developer/CommandLineTools` then
`xcode-select --install`.

### 4. Rosetta 2 (Apple Silicon, optional)

Only needed for remaining Intel-only apps and binaries. Apple keeps Rosetta
as a general-purpose tool **through macOS 27**, then narrows it to legacy
games in macOS 28 — treat any x86_64 dependency as a migration ticket, not a
foundation. Recommend installing on demand (macOS also prompts automatically
when an Intel binary first runs). With consent:

```sh
[ "$(uname -m)" = "arm64" ] && sudo softwareupdate --install-rosetta --agree-to-license
```

Skip entirely on Intel Macs.

### 5. Queue the sign-ins (manual, two minutes now — unblocks later steps)

Later steps silently depend on these; have the user do them now:

- **Apple Account**: System Settings → sign in (needed for App Store,
  full Xcode, iCloud choices).
- **App Store app**: open it and confirm the account is active — `mas`
  installs (Amphetamine, Xcode) fail without it and `mas` cannot sign in
  itself.

### 6. Source directory

Create a non-cloud-synced home for code (iCloud-synced Desktop/Documents and
source trees don't mix — sync churn, node_modules uploads):

```sh
mkdir -p ~/Developer
```

`~/Developer` gets a special Finder icon and is the conventional choice;
`~/src` or `~/projects` work the same.

### 7. Verify and hand off

```sh
sh "${CLAUDE_SKILL_DIR}/scripts/check.sh"
```

All checks green → next steps are `macos-security-baseline` (security) and
`homebrew-setup` (packages). Do not start Homebrew's installer while the CLT
dialog is still running.

## Output spec

Done means: `softwareupdate --list` shows no pending recommended updates (or
the user deferred them knowingly), `xcode-select -p` resolves, `git --version`
and `clang --version` print versions, Rosetta decision recorded, and a source
directory exists. Report each check's actual output, not assumptions.

## Gotchas

- CLT install stalls at "finding software" → Apple's catalog hiccup; retry,
  or download the CLT pkg from developer.apple.com/download/all/ manually.
- Only one CLT version can be installed at a time; Software Update keeps it
  current after OS updates.
- `xcode-select -p` pointing at `/Applications/Xcode.app/...` is fine — full
  Xcode includes the CLT function; don't "fix" it here.
- Intel Macs: everything above works, but Homebrew moves Intel to Tier 3
  support from September 2026 — set expectations for an aging platform.

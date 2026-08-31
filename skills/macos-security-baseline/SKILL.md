---
name: macos-security-baseline
description: Hardens a developer Mac's security basics - FileVault disk encryption, the application firewall, and Touch ID for sudo via /etc/pam.d/sudo_local. Use for "enable Touch ID for sudo", "is my Mac encrypted", "turn on FileVault", "secure/harden my Mac for work", "firewall setup". Not for OS updates or Command Line Tools, SSH keys and commit signing, or bypassing Gatekeeper for blocked apps.
license: MIT
---

# macOS Security Baseline

Enables the three security wins every developer Mac should have — FileVault,
firewall, Touch ID for sudo — without ever weakening macOS protections. A dev
machine holds SSH keys, cloud sessions, and source code: treat it as a
privileged endpoint.

## When NOT to use

- OS updates, Command Line Tools, Rosetta → `macos-system-prep`
- SSH keys, commit signing, GitHub auth → `git-ssh-identity`
- "App is blocked by Gatekeeper" → not this skill's job; never disable
  Gatekeeper globally (`spctl --master-disable` was removed in Sequoia).
  Point the user at the per-app System Settings override and stop.
- Finder/Dock/keyboard tweaks → `macos-defaults`

## Safety rails

- **FileVault recovery key:** instruct the user to store it in a password
  manager. Never ask for it, never echo it, never write it to a file. It must
  not appear in this chat.
- PAM changes gate `sudo` itself — always back up first, keep a working root
  terminal open while testing, and verify in a **new** shell before closing.
- Ask consent before every `sudo` command here.
- Never automate security *weakening* (Gatekeeper exceptions, firewall off,
  SIP changes) — refuse and explain.

## Workflow

### 1. FileVault (manual, user-driven)

Check state (read-only): `fdesetup status`

If off, have the user enable it themselves: **System Settings → Privacy &
Security → FileVault → Turn On**. They choose iCloud escrow (no key to
store — recovery goes through the Apple Account) or a personal recovery
key, which must go **immediately** into their password manager (somewhere
accessible off this device) — never into this session. Encryption may show
"in progress" for a while; that counts as done here. Do not run `sudo
fdesetup enable` — the GUI flow handles the recovery ceremony correctly.

### 2. Application firewall

Check both state and policy (read-only):

```sh
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
/usr/libexec/ApplicationFirewall/socketfilterfw --getblockall
```

Enable via **System Settings → Network → Firewall**, or with consent:

```sh
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```

If "block all incoming" is already ON, that's an existing deliberate
policy — report it and leave it (turning it off would be an automated
weakening); just note it blocks reaching local dev servers from other
devices. For fresh setups, the default per-app prompting is right.

### 3. Touch ID for sudo

The update-surviving mechanism (macOS Sonoma+) is `/etc/pam.d/sudo_local` —
**never edit `/etc/pam.d/sudo`**, which macOS updates overwrite. With
consent:

Three cases — never blindly overwrite an existing `sudo_local` (it may
carry customization like `pam_reattach`):

```sh
# Case 1: pam_tid already active - done, touch nothing
sudo grep -q '^auth.*pam_tid' /etc/pam.d/sudo_local 2>/dev/null && echo "already enabled"

# Case 2: file exists WITHOUT active pam_tid - show it, timestamped backup,
# then uncomment/insert ONLY the pam_tid line (anchored pattern; keep the rest)
sudo cp /etc/pam.d/sudo_local "/etc/pam.d/sudo_local.bak.$(date +%Y%m%d%H%M%S)"
sudo sed -i '' 's/^#auth\([[:space:]]*sufficient[[:space:]]*pam_tid.so\)/auth\1/' /etc/pam.d/sudo_local
sudo grep -q '^auth.*pam_tid' /etc/pam.d/sudo_local || \
  printf 'auth       sufficient     pam_tid.so\n' | sudo tee -a /etc/pam.d/sudo_local >/dev/null

# Case 3: no file - create from Apple's template (anchored uncomment;
# full-string seds silently no-op on the template's whitespace)
sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
```

(`tee` under sudo writes the file root-owned with default 0644 — correct
for PAM; confirm with `stat -f '%Su %OLp' /etc/pam.d/sudo_local`.)

Verify **in a new terminal** (keep the current one open as a fallback):

```sh
sudo -k && sudo true   # should prompt for Touch ID, not password
```

Caveats worth stating when relevant:
- Works out of the box in Terminal, Ghostty, kitty, Alacritty, VS Code's
  terminal. iTerm2 needs Settings → Advanced → "Allow sessions to survive
  logging out and back in" set to **No**.
- Inside `tmux`, Touch ID needs the third-party `pam_reattach` module
  (`brew install pam-reattach`, add its line to `sudo_local`) — optional.
- After a macOS update, if Touch ID sudo stops working, check that
  `/etc/pam.d/sudo_local` still exists (it should — that's the point) and
  that nobody had edited `/etc/pam.d/sudo` instead.

### 4. Leave the rest alone

Gatekeeper, SIP, automatic security responses, and background system-data
updates stay **on**. If a tool demands disabling any of them, that is a
red flag to investigate, not a setup step.

### 5. Verify

```sh
sh "${CLAUDE_SKILL_DIR}/scripts/check.sh"
```

## Output spec

Done means: `fdesetup status` reports FileVault On or "encryption in
progress" (or the user explicitly deferred), firewall global state is
enabled, and Touch ID sudo is in one of three recorded states — enabled
(verified in a fresh shell), unavailable (no Touch ID hardware — password
fallback is fine, not a failure), or deferred by the user. No security
feature was weakened. Report actual command output.

## Gotchas

- `sed 's/#auth       sufficient     pam_tid.so/.../'` style full-string
  matches fail when Apple changes template spacing — always anchor on
  `^#auth`.
- Touch ID sudo doesn't work over SSH sessions or in `su` shells — password
  fallback still applies (pam_tid is `sufficient`, not `required`, so
  nothing breaks).
- On Macs without Touch ID (external non-Touch keyboards, clamshell mode),
  the password prompt appears as usual; Apple Watch approval works if
  enabled in System Settings.

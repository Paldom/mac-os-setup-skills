---
name: mac-dev-apps
description: Installs the GUI app baseline for a developer Mac via casks and mas - browsers, Slack/Zoom, terminals (Ghostty/Warp/iTerm2), Raycast/Rectangle, DB clients, Amphetamine, VPNs - flagging sign-ins and licenses. Use for "install my Mac apps", "apps for a new Mac", "install chrome/slack/raycast", "terminal app recommendation". Not for CLI tools, editors, Docker, or cloud/AI CLIs.
---

# Mac Dev Apps

Installs GUI applications with the *current* cask tokens (several classics
were renamed, deprecated, or never existed) and flags every app whose setup
can't be automated: App Store sign-ins, license keys, permission prompts.

## When NOT to use

- CLI toolbelt → `dev-cli-tools` · Editors → `editor-setup` ·
  Docker/OrbStack → `docker-on-mac` · Cloud CLIs → `cloud-dev-setup` ·
  AI agent CLIs → `ai-dev-tools`
- Deep per-app configuration (Raycast extensions, iTerm2 profiles) → do the
  install here; in-app config is the user's taste

## Prerequisites

`brew` present (→ `homebrew-setup`). App Store items additionally need the
user signed into the **App Store app** (mas cannot sign in for them).

## Safety rails

- Ask which groups/apps — never install a fixed list unprompted.
- Report skipped/unavailable apps with the reason and an alternative;
  don't silently drop them.
- Casks may prompt for the admin password (privileged helper installs —
  normal for VPNs/Parallels); tell the user to expect it.

## Workflow

### 1. Offer the groups, install the chosen ones

Preflight any token you're unsure about — `brew info --cask <token>`
catches renames/tombstones before a failed install:

```sh
# Browsers            brew install --cask google-chrome firefox
# Comms               brew install --cask slack zoom
# Terminal (pick one) brew install --cask ghostty     # recommended default: fast, native, open source
#                     brew install --cask warp        # AI-forward (account for AI features)
#                     brew install --cask iterm2      # mature, most configurable
# Launcher/windows    brew install --cask raycast     # subsumes Spotlight+window snapping for most
#                     brew install --cask rectangle   # standalone snapping, if not Raycast
#                     brew install --cask aerospace   # i3-style tiling (no SIP changes needed)
# Design/media        brew install --cask figma pika vlc spotify
# Databases           brew install --cask dbeaver-community   # or tableplus
# Files/storage       brew install --cask google-drive
# Git GUI             brew install --cask github      # GitHub Desktop
# VPN                 brew install --cask nordvpn openvpn-connect
# VMs                 brew install --cask parallels   # license required; parallels@18 etc. for owned versions
# JetBrains gateway   brew install --cask jetbrains-toolbox
# Passwords           brew install --cask 1password
```

Verified token table incl. renames/tombstones:
[references/app-catalog.md](references/app-catalog.md).

### 2. App Store apps via mas

```sh
brew install mas
mas install 937984704    # Amphetamine (keep-awake; App Store-exclusive, no cask)
```

User must already be signed into the App Store app; `mas` v7 has no signin
command. If the app was **never acquired** on this Apple Account,
`mas install` can fail — `mas get <id>` acquires free apps, or open the
App Store page and click Get once, then retry. Xcode
(`mas install 497799835`) belongs to `mobile-dev-setup`.

### 3. Flag the manual steps (per installed app)

General rule: **every account-backed app needs its own sign-in** (Slack,
Zoom, GitHub Desktop, Google Drive, Spotify, 1Password, …) and every paid
app its license (Parallels, TablePlus, JetBrains IDEs) — list each
installed app's step, don't assume. Specific ones worth calling out:

- **Raycast**: replace Spotlight — System Settings → Keyboard → Keyboard
  Shortcuts → Spotlight: untick ⌘Space, then set ⌘Space in Raycast.
  (Don't script symbolichotkeys — fragile.)
- **Warp**: works without an account; sign-in unlocks AI/sync features.
- **NordVPN / OpenVPN / Parallels**: sign-in or license key + a
  system-extension approval prompt in System Settings → Privacy & Security.
- **Ghostty/iTerm2**: select the Nerd Font in the profile if a prompt theme
  is in use (→ `zsh-setup`).

### 4. Record and verify

Suggest refreshing the Brewfile afterwards (→ `homebrew-setup` dump
workflow). Verify: `brew list --cask` matches the chosen set; apps launch.

## Output spec

Done means: chosen apps installed with current tokens, mas items installed
(or queued behind an App Store sign-in the user was told about), every
manual step listed per app, unavailable requests reported with
alternatives.

## Gotchas

- **Renamed/defunct tokens bite old guides**: `docker`→`docker-desktop`
  (container runtime → `docker-on-mac` anyway), `messenger` cask is
  deprecated+disabled (use messenger.com), `filezilla` has no cask (use
  `cyberduck` cask or direct download), fonts need no tap anymore.
- GUI casks mostly ship their own updaters (`auto_updates`) — plain `brew
  upgrade` skips them intentionally; `mac-maintenance` covers `--greedy`
  semantics.
- Parallels' unversioned cask tracks the newest major (subscription);
  owners of a perpetual license install their major: `parallels@18`.
- From Sept 2026, official casks must be signed+notarized — very niche
  unsigned apps may vanish from brew; download from the vendor then.
- Raycast vs Rectangle overlap: Raycast includes window management —
  installing both is fine but redundant; ask.

---
name: macos-defaults
description: Applies developer-friendly macOS preferences via defaults write - Finder path bar and hidden files, Dock autohide and cleanup, fast key repeat, autocorrect off, screenshot location - with correct apply steps and verification. Use for "show hidden files", "faster key repeat", "screenshot folder", "clean up the Dock", "macOS defaults". Not for security settings, app installs, or shell config.
license: MIT
---

# macOS Defaults

Applies the quality-of-life `defaults write` tweaks developers actually want,
with the correct apply step for each domain and verification afterwards.
These keys are undocumented implementation details — this skill exists
because half the copy-pasted commands on the internet are stale (wrong
domain, dead key, missing apply step).

## When NOT to use

- FileVault / firewall / Touch ID sudo → `macos-security-baseline`
- Installing apps (Raycast, Rectangle, …) → `mac-dev-apps`
- Shell/prompt configuration → `zsh-setup`
- Editor settings → `editor-setup`

## Safety rails

- Show the user the grouped command list and confirm before applying —
  several tweaks change visible state (Dock contents, Finder views).
- Dock decluttering keeps a keep-list (Apps launcher, Notes, the user's
  daily apps) — never strip the Dock bare unasked. The full reset
  (`persistent-apps -array`) removes all pins; it deletes no apps and is
  reversible by re-pinning, but it's an explicit request, not a default.
- Only QoL preferences here — never write security-, update-, or
  Gatekeeper-related domains.
- After a macOS major upgrade, re-verify with `defaults read` before
  re-applying; keys drift across majors.

## Workflow

1. **Pick the set.** Offer the curated groups below; apply only what the
   user wants. The full verified key table with GUI equivalents and
   per-version caveats is in
   [references/verified-defaults.md](references/verified-defaults.md) —
   consult it before adding anything not listed here.

2. **Snapshot before writing** (real rollback — `defaults delete` only
   restores factory behavior, not the user's previous values):

```sh
for k in "com.apple.finder AppleShowAllFiles" "com.apple.dock autohide" "NSGlobalDomain KeyRepeat"; do
  echo "$k = $(defaults read $k 2>&1)"; done > ~/defaults-before-$(date +%Y%m%d%H%M%S).txt
defaults export com.apple.dock ~/dock-backup-$(date +%Y%m%d%H%M%S).plist   # before ANY Dock change, esp. clearing pins
```

(Snapshot every key you're about to write, not just these three.)

3. **Apply** (each block ends with its apply step):

```sh
# --- Finder ---
defaults write com.apple.finder AppleShowAllFiles -bool true        # hidden files (Cmd+Shift+. toggles too)
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # list view
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" # search current folder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder NewWindowTarget -string "PfHm"      # new windows open home
killall Finder

# --- Dock ---
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false                # stop reordering Spaces
# Optional decluttering, ASK FIRST - don't strip the Dock bare: keep the
# productivity staples (the Apps/Launchpad launcher, Notes, the user's
# daily apps). Ask for the keep-list; removing individual icons is drag-off
# or right-click -> Options -> Remove from Dock. Full reset only on request
# (clears EVERY pin - the user re-pins the keepers afterwards):
# defaults write com.apple.dock persistent-apps -array
killall Dock

# --- Keyboard (needs logout/login to take effect) ---
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false  # hold-to-repeat, no accent popup
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# --- Screenshots ---
mkdir -p "$HOME/Screenshots"                                        # folder MUST exist first
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"           # Tahoe defaults to HEIC on HDR displays
defaults write com.apple.screencapture disable-shadow -bool true
killall SystemUIServer 2>/dev/null || true                          # legacy apply; immediate on Tahoe

# --- Save/print panels expanded (set both key variants; applies to apps
# --- launched AFTER the change - no killall helps) ---
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# --- .DS_Store suppression on network/USB volumes (needs logout/login) ---
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
```

4. **Manual (GUI-only) steps** — tell the user, don't script:
   - Spotlight (optional tradeoff): **System Settings → Spotlight → Search
     Privacy…** — excluding the source directory (`~/Developer`) stops
     build/node_modules indexing CPU spikes, at the cost of Spotlight
     search over source files. Offer it, don't default it.
   - Safari Develop menu: **Safari → Settings → Advanced → "Show features
     for web developers"** (the old `IncludeDevelopMenu` defaults key is
     dead since Safari 17, and Safari's sandbox ignores terminal writes
     without Full Disk Access).
   - Trackpad tap-to-click / three-finger drag: use System Settings —
     the defaults keys for trackpad are the flakiest (cfprefsd caching).

5. **Verify and report** — one `defaults read` spot-check per APPLIED
   group, treated as a failure if it mismatches:

```sh
defaults read com.apple.finder ShowPathbar                    # Finder group: 1
defaults read com.apple.dock autohide                         # Dock group: 1
defaults read NSGlobalDomain KeyRepeat                        # Keyboard group: 2
defaults read com.apple.screencapture location                # Screenshots group: chosen path
defaults read NSGlobalDomain NSNavPanelExpandedStateForSaveMode2      # Panels group: 1
defaults read com.apple.desktopservices DSDontWriteNetworkStores      # .DS_Store group: 1
```

Tell the user which changes need **logout/login** (keyboard, .DS_Store
group) vs app relaunch (panels) vs already live (Finder/Dock/screenshots).

## Output spec

Done means: each requested group applied, apply-steps run, the per-group
spot-check matches, the before-snapshot file exists, and the user knows
what needs a logout. Rollback on request: restore values from the
snapshot (`defaults write` them back), or `defaults import com.apple.dock
<backup.plist> && killall Dock` for the Dock.

## Gotchas

- The screenshot folder is not auto-created — a nonexistent `location`
  silently falls back to Desktop.
- `_FXShowPosixPathInTitle` (full path in Finder title) is effectively dead
  on modern macOS — use the path bar instead; don't recommend it.
- `com.apple.symbolichotkeys` edits (e.g. freeing Cmd+Space for Raycast) are
  fragile across versions — do that in the GUI (System Settings → Keyboard →
  Keyboard Shortcuts).
- Writes that "don't stick": quit the target app first, or `killall
  cfprefsd` after writing; sandboxed apps (Safari) need their GUI.

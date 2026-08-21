# Verified macOS defaults keys (checked 2026-08-17, Sequoia 15 / Tahoe 26)

All keys below were re-verified against community documentation
(macos-defaults.com, mathiasbynens/dotfiles lineage, Apple support articles
where they exist) in August 2026. Everything except the network-.DS_Store key
is an **undocumented implementation detail** — after each macOS major
upgrade, spot-check with `defaults read` before re-applying.

**Contents:** [Finder](#finder) · [Dock](#dock) · [Keyboard](#keyboard) ·
[Screenshots](#screenshots) · [Panels](#panels) · [.DS_Store](#ds_store) ·
[Trackpad](#trackpad-gui-preferred) · [Hot corners](#hot-corners) ·
[Dead or broken keys](#dead-or-broken-keys) · [Apply steps](#apply-steps)

## Finder

| Key | Value | GUI equivalent |
|---|---|---|
| `com.apple.finder AppleShowAllFiles` | `-bool true` | none; Cmd+Shift+. per-session |
| `com.apple.finder ShowPathbar` | `-bool true` | View → Show Path Bar (⌥⌘P) |
| `com.apple.finder ShowStatusBar` | `-bool true` | View → Show Status Bar (⌘/) |
| `NSGlobalDomain AppleShowAllExtensions` | `-bool true` | Finder Settings → Advanced |
| `com.apple.finder FXPreferredViewStyle` | `"Nlsv"` list, `clmv` column, `glyv` gallery, `icnv` icon | View menu (applies to folders without saved views) |
| `com.apple.finder FXDefaultSearchScope` | `"SCcf"` current folder | Finder Settings → Advanced |
| `com.apple.finder FXEnableExtensionChangeWarning` | `-bool false` | Finder Settings → Advanced |
| `com.apple.finder _FXSortFoldersFirst` | `-bool true` | Finder Settings → Advanced ("Keep folders on top") |
| `com.apple.finder NewWindowTarget` | `"PfHm"` home, `PfDe` desktop, `PfLo` + `NewWindowTargetPath -string "file://$HOME/..."` custom | Finder Settings → General |

## Dock

| Key | Value | Note |
|---|---|---|
| `com.apple.dock autohide` | `-bool true` | Desktop & Dock pane |
| `com.apple.dock autohide-delay` | `-float 0` | no GUI |
| `com.apple.dock autohide-time-modifier` | `-float 0.3` | no GUI; animation speed |
| `com.apple.dock tilesize` | `-int 48` | Size slider |
| `com.apple.dock minimize-to-application` | `-bool true` | Desktop & Dock |
| `com.apple.dock show-recents` | `-bool false` | Desktop & Dock (present on Tahoe) |
| `com.apple.dock static-only` | `-bool true` | show only running apps; hides pins while set |
| `com.apple.dock persistent-apps` | `-array` (empty) | clears ALL pinned apps; reversible by re-pinning; also `persistent-others` for right side; may need a second `killall Dock` |
| `com.apple.dock mru-spaces` | `-bool false` | Desktop & Dock → Mission Control |

## Keyboard

All in `NSGlobalDomain`; **logout/login required** for the repeat keys,
app-relaunch for the rest.

| Key | Value | Note |
|---|---|---|
| `KeyRepeat` | `-int 2` | GUI minimum = 2; values below GUI range (1) work via defaults |
| `InitialKeyRepeat` | `-int 15` | GUI minimum = 15; 10 works via defaults |
| `ApplePressAndHoldEnabled` | `-bool false` | kills accent popover; can scope per-app, e.g. `defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false` |
| `NSAutomaticSpellingCorrectionEnabled` | `-bool false` | System Settings → Keyboard → Text Input → Edit… |
| `NSAutomaticCapitalizationEnabled` | `-bool false` | same pane |
| `NSAutomaticQuoteSubstitutionEnabled` | `-bool false` | same pane ("smart quotes") |
| `NSAutomaticDashSubstitutionEnabled` | `-bool false` | same pane |
| `NSAutomaticPeriodSubstitutionEnabled` | `-bool false` | same pane (double-space period) |

## Screenshots

Domain `com.apple.screencapture`. Folder must pre-exist (`mkdir -p`).

| Key | Value |
|---|---|
| `location` | `-string "$HOME/Screenshots"` |
| `type` | `"png"` (also jpg, pdf, heic; Tahoe defaults to HEIC+HDR on HDR displays) |
| `disable-shadow` | `-bool true` |
| `include-date` | `-bool false` (optional) |

GUI: Cmd+Shift+5 → Options → Save to → Other Location…
Apply: immediate on Tahoe; `killall SystemUIServer` was the traditional step
and remains harmless. Known Tahoe bug: `type pdf` + floating thumbnail can
fail to save — disable the thumbnail if hit.

## Panels

Set **both** old and `2`-suffixed variants (`NSGlobalDomain`):
`NSNavPanelExpandedStateForSaveMode(2) -bool true`,
`PMPrintingExpandedStateForPrint(2) -bool true`. Applies to newly launched
apps.

## .DS_Store

- `com.apple.desktopservices DSDontWriteNetworkStores -bool true` — the only
  Apple-documented key here (support.apple.com/102064); logout to apply.
- `com.apple.desktopservices DSDontWriteUSBStores -bool true` — community.

## Trackpad (GUI preferred)

Keys exist (`com.apple.AppleMultitouchTrackpad Clicking`,
`TrackpadThreeFingerDrag`, `NSGlobalDomain com.apple.swipescrolldirection`)
but are the flakiest category: cfprefsd caching, logout required, GUI may
show stale state. Recommend System Settings: Trackpad → Point & Click →
Tap to click; Accessibility → Pointer Control → Trackpad Options → Dragging
style: Three-Finger Drag.

## Hot corners

`com.apple.dock wvous-{tl,tr,bl,br}-corner -int N` + matching
`wvous-*-modifier -int 0`, then `killall Dock`. Values: 0/1 none, 2 Mission
Control, 4 Desktop, 5 screen saver, 10 display sleep, 12 Notification
Center, 13 Lock Screen, 14 Quick Note. (11 was Launchpad — removed in
Tahoe.) GUI: System Settings → Desktop & Dock → Hot Corners….

## Dead or broken keys

Do **not** recommend these:

- `com.apple.Safari IncludeDevelopMenu` — dead since Safari 17. GUI only:
  Safari Settings → Advanced → "Show features for web developers". Safari is
  sandboxed: terminal writes silently no-op without Full Disk Access.
- `com.apple.finder _FXShowPosixPathInTitle` — no longer shows the full path
  on modern macOS; use the path bar.
- `sudo spctl --master-disable` — removed in Sequoia; and it's a security
  weakening, out of scope regardless.
- `com.apple.symbolichotkeys` edits — fragile across versions; use System
  Settings → Keyboard → Keyboard Shortcuts.

## Apply steps

| Domain | Apply |
|---|---|
| com.apple.finder | `killall Finder` |
| com.apple.dock (incl. hot corners) | `killall Dock` |
| com.apple.screencapture | immediate (Tahoe); `killall SystemUIServer` legacy |
| NSGlobalDomain UI toggles | relaunch affected app |
| KeyRepeat/InitialKeyRepeat, trackpad, DSDontWrite* | logout/login |

Verify: `defaults read <domain> <key>`. Revert: `defaults delete <domain>
<key>`. Stubborn cache: `killall cfprefsd` after quitting the target app.

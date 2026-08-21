# Verified cask/mas catalog (checked live against formulae.brew.sh, 2026-08-17)

Tokens verified individually via the Homebrew cask API on the date above.
Re-verify tokens that matter with `brew info --cask <token>` before install.

## Working tokens

| App | Token | Notes |
|---|---|---|
| Google Chrome | `google-chrome` | auto_updates |
| Firefox | `firefox` | auto_updates |
| Slack | `slack` | auto_updates |
| Zoom | `zoom` | |
| Spotify | `spotify` | |
| Figma | `figma` | |
| Warp | `warp` | account sign-in for AI features |
| Ghostty | `ghostty` | config at ~/.config/ghostty/config |
| iTerm2 | `iterm2` | |
| Raycast | `raycast` | manual ⌘Space remap |
| Rectangle | `rectangle` | free/open source |
| Pika | `pika` | color picker |
| VLC | `vlc` | |
| DBeaver CE | `dbeaver-community` | |
| TablePlus | `tableplus` | freemium |
| GitHub Desktop | `github` | |
| Google Drive | `google-drive` | sign-in |
| NordVPN | `nordvpn` | sign-in + system extension approval |
| OpenVPN Connect | `openvpn-connect` | |
| Parallels Desktop | `parallels` (current major); `parallels@18` etc. exist | license; admin password |
| JetBrains Toolbox | `jetbrains-toolbox` | manages IntelliJ/PyCharm/... installs |
| 1Password | `1password` (+ `1password-cli`) | |
| Cyberduck | `cyberduck` | FileZilla replacement |
| VS Code / Cursor / Zed | `visual-studio-code` / `cursor` / `zed` | → editor-setup |
| OrbStack / Docker Desktop | `orbstack` / `docker-desktop` | → docker-on-mac |
| Android Studio | `android-studio` | → mobile-dev-setup |
| Temurin JDK | `temurin@25` (LTS) | → language-runtimes |
| Nerd Fonts | `font-meslo-lg-nerd-font`, `font-jetbrains-mono-nerd-font`, `font-fira-code-nerd-font` | no tap needed |

## Tombstones & traps

| Ask | Status | Do instead |
|---|---|---|
| `messenger` | deprecated AND disabled (2025-12) | messenger.com in a browser |
| `filezilla` | no cask/formula (removed 2018) | `cyberduck`, Transmit, or vendor download |
| `docker` (cask sense) | renamed → `docker-desktop` (2025-06); old token aliases; bare `brew install docker` = CLI formula only | be explicit: `--cask docker-desktop` |
| `google-cloud-sdk` | renamed → `gcloud-cli` | → cloud-dev-setup |
| `xcode` | never existed as a cask | App Store / `xcodes` → mobile-dev-setup |
| Amphetamine "cask" | App Store-exclusive; sites claiming a cask are junk | `mas install 937984704` |
| `brew tap homebrew/cask-fonts` | tap deleted | fonts install directly from homebrew/cask |

## mas (Mac App Store)

- `brew install mas`; requires the user signed into the **App Store app**
  (mas v7 removed `signin`). Mostly limited to previously-"purchased"
  (including free) apps; paid apps can't be bought through it.
- Useful ids: Amphetamine `937984704`, Xcode `497799835`.
- Brewfile line: `mas "Amphetamine", id: 937984704`.

## Update semantics

Casks marked auto_updates (Chrome, VS Code, Slack, …) self-update; plain
`brew upgrade` skips them. Forcing brew to manage them:
`brew upgrade --cask --greedy` (re-downloads apps that already updated —
usually unnecessary; see mac-maintenance).

## Notarization deadline

From **2026-09-01** official casks must point at signed + notarized apps.
Expect a handful of unmaintained niche casks to be disabled; fall back to
vendor downloads for those.

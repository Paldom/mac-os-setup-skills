# Homebrew facts (verified against brew.sh / docs.brew.sh / formulae.brew.sh, 2026-08-17)

Point-in-time facts that age; re-verify against docs.brew.sh when they matter.

## Versions & support

- Current line: Homebrew 6.x (6.0.0 shipped 2026-06-11; brought `brew trust
  <tap>` for third-party taps and CLI sandboxing).
- Supported macOS (Tier 1, as of this check): Tahoe 26, Sequoia 15,
  Sonoma 14 — installation docs state "Sonoma 14 or higher".
- Intel x86_64: drops to Tier 3 (no CI, no new bottles) in/after
  **September 2026**; scheduled removal in/after **September 2027**. Apple:
  Tahoe 26 is the final Intel macOS; Rosetta 2 is general-purpose only
  through macOS 27.
- Prefixes: `/opt/homebrew` (Apple Silicon), `/usr/local` (Intel). The
  installer's printed next-steps write `eval "$(/opt/homebrew/bin/brew
  shellenv zsh)"` into `${ZDOTDIR:-$HOME}/.zprofile` (the explicit `zsh`
  argument is new; the argument-less form also works).

## brew bundle (built-in since 4.5)

- Subcommands: `install` (default; **upgrades by default** — opt out with
  `--no-upgrade` or `HOMEBREW_BUNDLE_NO_UPGRADE`), `dump`, `check`,
  `cleanup` (needs `--force` to actually uninstall), `list`, `edit`, `add`,
  `remove`, `exec`.
- File resolution: `--file=PATH` → `HOMEBREW_BUNDLE_FILE` → `./Brewfile`;
  `--global` → `~/.Brewfile` (or XDG `~/.config/homebrew/Brewfile`).
- Entry types: `tap`, `brew`, `cask`, `mas "Name", id: N`,
  `vscode "publisher.ext"`, plus newer `go`/`cargo`/`uv`/`npm` entries.

## mas (Mac App Store CLI)

- `brew install mas`; v7+ has **no `signin`** command — sign into the App
  Store app manually first. `mas install <id>` / `mas get` require a
  signed-in Apple Account and (mostly) previously-"purchased" apps; paid
  apps can't be bought via mas. `mas update` (alias `upgrade`) updates.

## Cask token renames & traps (verified live)

| Ask | Correct token | Note |
|---|---|---|
| Docker Desktop | `docker-desktop` | renamed from `docker` 2025-06/07; old token aliases; bare `brew install docker` = CLI formula only |
| Google Cloud CLI | `gcloud-cli` | renamed from `google-cloud-sdk` |
| JDK LTS | `temurin@25` | plain `temurin` tracks latest (26, non-LTS) |
| Fonts | `font-meslo-lg-nerd-font`, `font-jetbrains-mono-nerd-font`, `font-fira-code-nerd-font` | cask-fonts tap is dead; fonts live in the main cask repo — no tap step |
| Facebook Messenger | — | `messenger` cask is deprecated AND disabled (2025-12) |
| FileZilla | — | no cask/formula exists (removed 2018); download from filezilla-project.org |
| Parallels | `parallels` (current major) | pinned majors like `parallels@18` exist for owned licenses |
| Xcode | — | no `xcode` cask; App Store or `xcodes` |

- Casks with `auto_updates true` (Chrome, VS Code, Slack, …) are skipped by
  plain `brew upgrade` — they self-update; `--greedy` forces brew-managed
  updates (see mac-maintenance).
- From **September 1, 2026** official casks must be signed + notarized —
  niche unsigned casks may disappear; `brew doctor` + cask audit before
  relying on one.

## Services & databases

- `brew services start|stop|run|list|info <formula>` manages launchd
  services (user-level; `sudo brew services` = system-level).
- `postgresql` alias currently points at `postgresql@18`; versioned
  formulae `postgresql@17` (17.x) and `@18` are keg-only. Pin a major
  explicitly for local dev — major upgrades need `pg_upgrade`, not `brew
  upgrade`.
- `redis` remains a valid formula (8.x, AGPL-side license); `valkey` is the
  BSD fork alternative. Homebrew deprecates neither.

## Maintenance pointers (detail in mac-maintenance)

- `brew update` = refresh brew+metadata; `brew upgrade` = upgrade packages.
- Auto-update before install/upgrade/tap every 24h by default
  (`HOMEBREW_AUTO_UPDATE_SECS`); periodic cleanup every 30 days.
- `brew cleanup` prunes caches >120 days; `brew autoremove` drops orphaned
  deps; `HOMEBREW_NO_ENV_HINTS=1` silences hint spam.

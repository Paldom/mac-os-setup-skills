# Changelog

All notable changes to this repository's skills are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning: [SemVer](https://semver.org) on the plugin manifest
(breaking skill-interface change → major, new skill → minor, fix → patch).

## [Unreleased]

## [0.3.0] - 2026-08-31

### Added
- Adopted the current skillskit gate: executed trigger evals scoring every trigger
  prompt against every skill description (rank-1 routing accuracy 86.5%), a security
  scan over skill content and bundled scripts, ruff lint and format, README-shape
  validation, pre-commit hooks and a write-time lint hook.

### Changed
- Skill descriptions sharpened where the eval gate showed a sibling outranking a
  skill on its own trigger prompts, or a stated non-trigger matching better than any
  trigger. Fixes changed the scope boundary, not just the wording.

### Fixed
- Findings the new lint gate surfaced in this repo's own scripts, fixed at the
  source; where a rule was wrong for a line it is suppressed there with its reason.


### Added
- Initial 18-skill catalog covering fresh-macOS-to-dev-environment setup
  (facts verified against primary sources, August 2026):
  - `macos-dev-setup` — plan-first orchestrator sequencing all areas with
    verification and opt-in optional tracks.
  - `macos-system-prep` — OS updates, Xcode Command Line Tools, Rosetta 2,
    source directory.
  - `macos-security-baseline` — FileVault, firewall, Touch ID for sudo via
    `sudo_local`.
  - `macos-defaults` — verified `defaults write` preferences with apply
    steps and per-version caveats.
  - `homebrew-setup` — install, shellenv, doctor, Brewfile/`brew bundle`
    workflow, mas.
  - `zsh-setup` — Oh My Zsh + plugins, Powerlevel10k/Starship variant
    choice, Nerd Fonts, `.zshrc` structure, startup profiling.
  - `dev-cli-tools` — modern CLI toolbelt with required shell integrations.
  - `git-ssh-identity` — git defaults, ed25519 + Keychain, gh auth, SSH
    commit signing, includeIf identities.
  - `language-runtimes` — one-manager-per-runtime strategy; classic
    (nvm/pyenv+pipx+poetry/jenv+Temurin) and modern (mise+uv) profiles.
  - `dotfiles-setup` — Stow/chezmoi/bare-git, adopt-don't-overwrite,
    secrets hygiene, idempotent bootstrap.
  - `editor-setup` — VS Code/Cursor/Zed install, `code` CLI, merged
    settings baseline, extensions.
  - `mac-dev-apps` — GUI app baseline with verified cask tokens and
    tombstones (docker→docker-desktop, dead messenger/filezilla).
  - `docker-on-mac` — Docker Desktop/OrbStack/Colima decision with 2026
    licensing, install, verify, multi-arch.
  - `web-dev-setup` — pnpm (post-corepack), pinned PostgreSQL + Redis via
    brew services, API client.
  - `mobile-dev-setup` — iOS/Android subtrack selection, full Xcode
    pointing/license/simulators, Android SDK env, RN/Flutter prereqs.
  - `cloud-dev-setup` — AWS/Azure/GCloud/Databricks/kubectl/Terraform-or-
    OpenTofu with SSO-first auth.
  - `ai-dev-tools` — Claude Code, Codex, Gemini, Copilot, Grok Build, Kimi
    Code via official installers with subscription auth and guardrails.
  - `mac-maintenance` — recurring safe update pass with cask
    `auto_updates` semantics and disk reclaim.
- README manual setup guide (article) aligned 1:1 with the skill catalog.
- `docs/setup-prompt.md` — paste-ready `/goal` orchestrating a full setup
  session.
- `skills.sh.json` groupings for the skills.sh listing.

### Changed
- `zsh-setup` is now modern-only: Starship + Homebrew-installed plugins by
  default; Oh My Zsh/Powerlevel10k preserved for existing setups and kept
  as a legacy path in the reference.
- `language-runtimes` now defaults to the modern set for every runtime:
  mise (Node LTS, Java Temurin LTS, Go, Ruby) + uv (Python) + rustup
  (Rust); classic nvm/pyenv/jenv preserved-if-present.
- `editor-setup` installs VS Code **and Cursor** by default (Zed on
  request).
- `ai-dev-tools` adds the **pi** coding agent (Earendil) with verified
  install/auth facts.
- `macos-system-prep` and the README guide now queue the Apple Account /
  App Store sign-ins up front (prerequisite for mas installs like
  Amphetamine and for Xcode).
- README: new "Prerequisites (to run this installer)" section (agent
  harness, git, npx/gh install routes); manual guide now shows a command
  for every step (softwareupdate, fdesetup, socketfilterfw) and follows
  the modern stack.

- Stack refinements: `dotfiles-setup` now defaults to **chezmoi**
  (Stow/bare-git remain), `mac-dev-apps` recommends **Ghostty** as the
  default terminal and adds AeroSpace as a tiling option, `dev-cli-tools`
  adds optional atuin, `web-dev-setup` notes Bun as an optional extra
  runtime.
- New `docs/setup-wizard.md`: interactive paste-ready wizard prompt
  (inventory → profile → costed editable manifest → gated execution with
  a resumable state file), linked from the README.

- `macos-defaults`: Dock decluttering now works from a keep-list
  (Apps/Launchpad launcher, Notes, daily apps) with per-icon removal; the
  full `persistent-apps -array` reset is explicit-request-only.

### Notes
- Repository scaffolded from the skills template.

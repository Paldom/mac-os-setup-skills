<p align="center">
  <img src="assets/icon.svg" alt="mac-os-setup-skills icon" width="128"/>
</p>

# Mac Os Setup Skills

[![CI](https://github.com/Paldom/mac-os-setup-skills/actions/workflows/ci.yml/badge.svg)](https://github.com/Paldom/mac-os-setup-skills/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![skills.sh](https://skills.sh/b/Paldom/mac-os-setup-skills)](https://skills.sh/Paldom/mac-os-setup-skills)

Agent Skills that take a Mac from a fresh macOS install to a working development
environment: shell, Homebrew, language runtimes, editors and CLI tooling,
dotfiles, SSH/git identity, and system preferences — automated where safe, with
precise manual steps where not (App Store sign-ins, security prompts, license
keys). Prefer doing it by hand? The same sequence is written up as a
[manual setup guide](#manual-setup-guide) below, kept aligned with the skills.

Agent Skills for [Claude Code](https://code.claude.com/docs/en/skills) (and any
[Agent Skills](https://agentskills.io)-compatible tool). Each skill is a folder under
[`skills/`](skills/) with a single-purpose `SKILL.md`, trigger evals, and optional
scripts/references — validated on every write, commit, and PR.

## Prerequisites (to run this installer)

The skills are executed *by an AI coding agent* — so before anything else you
need one running, plus a way to install the skills into it. On a factory-fresh
Mac the dependency-free path is:

1. **An agent harness** with Agent Skills support — e.g.
   [Claude Code](https://code.claude.com) (needs a Claude Pro/Max/Team or
   Console account; the native installer needs no Node or Homebrew):

   ```sh
   curl -fsSL https://claude.ai/install.sh | bash
   claude    # sign in via browser
   ```

2. **git** — ships with the Xcode Command Line Tools (also the first thing
   the setup itself does; Claude Code prompts for it if missing):

   ```sh
   xcode-select --install    # GUI installer; wait for it to finish
   git --version             # verify
   ```

3. **A skills install route** — pick the one whose prerequisite you have:
   - Claude Code plugin — needs nothing extra:

     ```sh
     claude    # then inside the session:
     # /plugin marketplace add Paldom/mac-os-setup-skills
     # /plugin install mac-os-setup-skills@mac-os-setup-skills
     ```

   - skills CLI — needs Node.js (`npx` ships with it; on a fresh Mac use the
     plugin route first and let the `language-runtimes` skill install Node
     properly later):

     ```sh
     node -v || echo "no Node yet - use the plugin route"
     npx skills add Paldom/mac-os-setup-skills
     ```

   - GitHub CLI ≥ 2.90 (needs Homebrew, which the setup installs anyway):

     ```sh
     brew install gh && gh --version
     gh skill install Paldom/mac-os-setup-skills
     ```

Also assumed throughout: an admin account on the Mac, network access, and —
for App Store items like Amphetamine and Xcode — an Apple Account (queued in
step 0 of the guide).

## Quick start

Install with the [skills CLI](https://skills.sh) — auto-detects 70+ agents
(Claude Code, Codex, Cursor, Copilot, pi, …):

```bash
npx skills add Paldom/mac-os-setup-skills                  # all detected agents
npx skills add Paldom/mac-os-setup-skills -a codex -a pi   # or target specific agents
```

Or with the [GitHub CLI](https://cli.github.com/manual/gh_skill_install) (≥ 2.90),
including version-pinned installs from releases:

```bash
gh skill install Paldom/mac-os-setup-skills
gh skill install Paldom/mac-os-setup-skills <skill> --pin <tag>
```

Or as a Claude Code plugin:

```
/plugin marketplace add Paldom/mac-os-setup-skills
/plugin install mac-os-setup-skills@mac-os-setup-skills
```

Or copy a single skill into a project:

```bash
git clone https://github.com/Paldom/mac-os-setup-skills.git
cp -r mac-os-setup-skills/skills/<skill-name> your-project/.claude/skills/
```

Then just describe the task — "set up my new Mac for development" activates the
orchestrator; "install homebrew" or "sign my commits" activates the focused
skill — or invoke one explicitly with `/<skill-name>`. Driving a whole setup
session? Two paste-ready prompts: the **interactive wizard**
([docs/setup-wizard.md](docs/setup-wizard.md)) that lets you fine-tune every
item through menus, or the mostly hands-off goal prompt
([docs/setup-prompt.md](docs/setup-prompt.md)).

## Skills

| Skill | Description |
| --- | --- |
| [macos-dev-setup](skills/macos-dev-setup/) | Orchestrates the complete fresh-Mac setup: inventories the machine, plans core steps, asks which optional tracks to add, runs each area skill in order with verification. |
| [macos-system-prep](skills/macos-system-prep/) | OS updates, Xcode Command Line Tools, optional Rosetta 2, and a source directory — the baseline before any tools. |
| [macos-security-baseline](skills/macos-security-baseline/) | FileVault, application firewall, and Touch ID for sudo via `/etc/pam.d/sudo_local` — without weakening macOS protections. |
| [macos-defaults](skills/macos-defaults/) | Developer-friendly `defaults write` preferences: Finder, Dock, keyboard, screenshots — with correct apply steps and verification. |
| [homebrew-setup](skills/homebrew-setup/) | Homebrew install, shellenv PATH wiring, `brew doctor`, and the Brewfile/`brew bundle` reproducibility workflow with mas. |
| [zsh-setup](skills/zsh-setup/) | Modern zsh: autosuggestions + syntax highlighting via Homebrew, the Starship prompt, Nerd Fonts, clean `.zshrc` structure, startup-time fixes. |
| [dev-cli-tools](skills/dev-cli-tools/) | The modern CLI toolbelt (ripgrep, fd, fzf, bat, eza, zoxide, jq, git-delta, lazygit, gh) plus the shell integration lines each needs. |
| [git-ssh-identity](skills/git-ssh-identity/) | Git config defaults, ed25519 SSH key in Apple Keychain, gh auth, SSH commit signing, work/personal identity split, global gitignore. |
| [language-runtimes](skills/language-runtimes/) | The modern runtime set: mise (Node, Java, Go, Ruby) + uv (Python) + rustup (Rust), one manager per runtime, preserving existing nvm/pyenv/jenv setups. |
| [dotfiles-setup](skills/dotfiles-setup/) | A dotfiles repo via chezmoi (Stow/bare-git alternatives): adopt without overwriting, secrets hygiene, Brewfile tracking, one-command restore. |
| [editor-setup](skills/editor-setup/) | VS Code + Cursor (Zed optional): install, `code`/`cursor` CLIs, merged settings.json baseline, curated extensions, Settings Sync. |
| [mac-dev-apps](skills/mac-dev-apps/) | GUI app baseline via casks + mas: browsers, comms, terminals (Ghostty default), Raycast/Rectangle, DB clients, utilities — with sign-in/license steps flagged. |
| [docker-on-mac](skills/docker-on-mac/) | Container runtime choice — Docker Desktop vs OrbStack vs Colima with 2026 licensing — install, verify, contexts, multi-arch. |
| [web-dev-setup](skills/web-dev-setup/) | Full-stack web extras: pnpm, pinned PostgreSQL + Redis via `brew services` (keg-only PATH fixes), API client. |
| [mobile-dev-setup](skills/mobile-dev-setup/) | iOS and/or Android toolchains: full Xcode + simulators, Android Studio + SDK/env vars/licenses, React Native/Flutter prerequisites. |
| [cloud-dev-setup](skills/cloud-dev-setup/) | AWS/Azure/Google Cloud/Databricks CLIs + kubectl + Terraform/OpenTofu — SSO auth with named profiles, never static keys. |
| [ai-dev-tools](skills/ai-dev-tools/) | AI coding agent CLIs (Claude Code, Codex, Gemini, Copilot, Grok Build, Kimi Code, pi) via official installers with subscription sign-ins and guardrails. |
| [mac-maintenance](skills/mac-maintenance/) | The recurring update pass: brew upgrade/cleanup, Brewfile re-capture, mas + macOS updates, runtime managers, safe disk reclaim. |

## Manual setup guide

The same path the skills automate, as a hands-on article. Order matters —
each phase builds on the previous one. Apple Silicon commands shown (Intel:
Homebrew lives in `/usr/local` instead of `/opt/homebrew`).

### 0. Update macOS, sign in, install the Command Line Tools

*Why: Homebrew and every compiler assume a current SDK; the Command Line
Tools provide `git`, `clang`, and `make`; and several later steps (App
Store apps like Amphetamine, full Xcode) silently require an Apple
Account — queue the sign-ins now so nothing blocks later.*

1. Update macOS (restart if asked):

   ```sh
   softwareupdate --list                        # see what's pending
   sudo softwareupdate --install --recommended  # or: System Settings → General → Software Update
   ```

2. **Prerequisite sign-ins (manual, two minutes):** System Settings →
   sign in with your **Apple Account**, then open the **App Store** app
   and confirm you're signed in — `mas` (used later for App Store
   installs) cannot sign in for you.
3. Install the Xcode Command Line Tools and wait for the GUI installer to
   finish (10–20 min) — don't start anything else meanwhile:

   ```sh
   xcode-select --install
   xcode-select -p    # verify: /Library/Developer/CommandLineTools
   ```

4. Apple Silicon only, optional: Rosetta 2 for remaining Intel-only apps
   (being phased out after macOS 27, so only if needed):

   ```sh
   sudo softwareupdate --install-rosetta --agree-to-license
   ```

5. Make a home for source code that iCloud won't sync:

   ```sh
   mkdir -p ~/Developer
   ```

→ Skill: [macos-system-prep](skills/macos-system-prep/)

### 1. Security basics

*Why: a dev machine holds SSH keys and cloud sessions — encrypt the disk
before secrets land on it, and make `sudo` pleasant so you never weaken it
out of frustration.*

1. **FileVault**: check with `fdesetup status`; enable via System Settings →
   Privacy & Security → FileVault → Turn On (the GUI handles the recovery
   ceremony — store a personal recovery key in your password manager).
2. **Firewall**:

   ```sh
   /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate    # check
   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
   ```
3. **Touch ID for sudo** (survives OS updates via `sudo_local`). On a
   fresh machine, create it from Apple's template; if `/etc/pam.d/sudo_local`
   already exists, back it up and just uncomment its `pam_tid` line instead:

   ```sh
   sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local
   ```

   Verify in a new terminal: `sudo -k && sudo true` → Touch ID prompt.
4. Leave Gatekeeper and SIP alone — a tool that demands disabling them is a
   red flag.

→ Skill: [macos-security-baseline](skills/macos-security-baseline/)

### 2. Homebrew

*Why: one package manager for CLI tools and GUI apps, and a `Brewfile` that
makes this whole machine reproducible.*

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
brew doctor    # "ready to brew"
```

Later, snapshot everything you install into a restorable manifest:

```sh
brew bundle dump --describe --file=~/Brewfile     # capture
brew bundle install --file=~/Brewfile             # restore on the next Mac
```

→ Skill: [homebrew-setup](skills/homebrew-setup/)

### 3. zsh, plugins, prompt

*Why: you'll live in this shell — autosuggestions and syntax highlighting pay
for themselves in a day, and Starship is the fast, actively maintained
prompt (Powerlevel10k is maintenance-only; no framework needed).*

```sh
brew install zsh-autosuggestions zsh-syntax-highlighting starship
brew install --cask font-jetbrains-mono-nerd-font
cat >> ~/.zshrc <<'EOF'
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
eval "$(starship init zsh)"
EOF
```

Keep `zsh-syntax-highlighting` last among plugins and the `starship` line
near the end of `~/.zshrc`. Then select the Nerd Font in your terminal
app's profile — installing alone doesn't apply it. (Already on Oh My Zsh
with Powerlevel10k? Both keep working — to modernize, blank `ZSH_THEME`
and add the starship line after `source $ZSH/oh-my-zsh.sh`.)

→ Skill: [zsh-setup](skills/zsh-setup/)

### 4. CLI toolbelt

*Why: modern replacements are faster, respect `.gitignore`, and the fzf/zoxide
integrations turn history search and directory jumps into muscle memory.*

```sh
brew install ripgrep fd fzf bat eza zoxide tree wget jq yq gh git-delta lazygit htop
echo 'source <(fzf --zsh)' >> ~/.zshrc          # Ctrl-R history, Ctrl-T files
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc    # z <dir-fragment> jumps
```

→ Skill: [dev-cli-tools](skills/dev-cli-tools/)

### 5. Git and SSH identity

*Why: ed25519 + Keychain means one passphrase prompt ever; SSH commit signing
gets the Verified badge with the key you already have.*

```sh
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global fetch.prune true
git config --global rebase.autoStash true
git config --global push.autoSetupRemote true
git config --global rerere.enabled true
git config --global merge.conflictstyle zdiff3

ssh-keygen -t ed25519 -C "you@example.com"      # set a passphrase
printf 'Host github.com\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519\n' >> ~/.ssh/config
/usr/bin/ssh-add --apple-use-keychain ~/.ssh/id_ed25519
gh auth login                                    # browser; uploads the key
ssh -T git@github.com                            # "Hi <you>!"

# Verified commits (upload the key AGAIN as a Signing key):
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
gh ssh-key add ~/.ssh/id_ed25519.pub --type signing
```

→ Skill: [git-ssh-identity](skills/git-ssh-identity/)

### 6. Language runtimes

*Why: projects need different versions; one manager per runtime keeps PATH
sane. The modern set: mise as the one polyglot manager (Node, Java, Go,
Ruby), uv for Python, rustup for Rust — covering every runtime without a
zoo of per-language managers.*

```sh
brew install mise uv rustup
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc && eval "$(mise activate zsh)"

mise use -g node@lts                # Node LTS
mise settings add idiomatic_version_file_enable_tools node   # honor .nvmrc files
mise use -g java@temurin-25         # Java - LTS pin (plain "latest" would be non-LTS)
mise use -g go@latest               # Go
uv python install 3.13              # Python (uv also replaces pip/pipx/poetry)
uv tool install ruff
echo 'export PATH="$(brew --prefix rustup)/bin:$PATH"' >> ~/.zshrc
rustup default stable               # Rust
```

Verify in a fresh shell: `node -v`, `java --version`, `go version`,
`uv run python --version`, `rustc --version`. (Existing nvm/pyenv/jenv
setups keep working — don't stack a second manager on the same runtime.)

→ Skill: [language-runtimes](skills/language-runtimes/)

### 7. macOS defaults

*Why: hidden files, path bar, fast key repeat, no smart quotes — small
frictions you hit hundreds of times a day.*

```sh
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
killall Finder Dock
```

Key-repeat changes need a logout/login. Also worth doing by hand: exclude
`~/Developer` in System Settings → Spotlight (build churn kills the indexer).

→ Skill: [macos-defaults](skills/macos-defaults/)

### 8. Editors

*Why: VS Code is the ecosystem default and Cursor adds the AI-first fork on
top — it imports VS Code's settings on first launch, so installing both
costs nothing extra; the CLI launchers and a couple of settings are what
make them feel set up.*

```sh
brew install --cask visual-studio-code cursor    # zed if you want the fast native one too
code --version && cursor --version
```

Merge into settings.json: `"editor.formatOnSave": true`,
`"files.trimTrailingWhitespace": true`, `"files.insertFinalNewline": true`
(exempt Markdown: `"[markdown]": {"files.trimTrailingWhitespace": false}`).
Launch Cursor once and accept the VS Code import. Sign into Settings Sync
(VS Code) and the Cursor account for cross-machine sync.

→ Skill: [editor-setup](skills/editor-setup/)

### 9. Apps

*Why: casks make GUI installs scriptable and Brewfile-restorable; `mas`
covers App Store-only apps like Amphetamine.*

```sh
brew install --cask ghostty    # recommended terminal (fast, native); warp or iterm2 if preferred
brew install --cask google-chrome firefox slack zoom spotify figma raycast rectangle dbeaver-community vlc pika
brew install mas && mas install 937984704    # Amphetamine - needs the App Store sign-in from step 0
```

Manual afterwards: Raycast's ⌘Space hotkey (free it from Spotlight in System
Settings → Keyboard Shortcuts), account sign-ins, VPN/Parallels licenses.
Watch for stale guides: the Docker Desktop cask is now `docker-desktop`,
`messenger` is gone, `filezilla` never had one (use `cyberduck`).

→ Skill: [mac-dev-apps](skills/mac-dev-apps/)

### 10. Dotfiles

*Why: everything you just configured should survive the next machine —
config in git, packages in the Brewfile. chezmoi handles multi-machine
templating and secrets references; restore is one command.*

```sh
brew install chezmoi
chezmoi init
chezmoi add ~/.zshrc ~/.zprofile ~/.gitconfig ~/Brewfile
chezmoi cd     # review, commit, add your private remote, push
# next Mac:  chezmoi init --apply <repo-url>
```

Never commit secrets: no `~/.ssh`, `~/.aws`, `.env`, tokens — scan with
`brew install gitleaks && gitleaks dir ~/.local/share/chezmoi` before the
first push. (Prefer plain symlinks? GNU Stow works too — see the skill.)

→ Skill: [dotfiles-setup](skills/dotfiles-setup/)

### Optional tracks

- **Containers** — pick by licensing: Docker Desktop (free under 250
  employees/$10M), OrbStack (fastest; paid for commercial use), Colima
  (free CLI). `brew install --cask docker-desktop` · `orbstack` · or
  `brew install colima docker && colima start`. Verify:
  `docker run --rm hello-world`.
  → [docker-on-mac](skills/docker-on-mac/)
- **Web** — `brew install pnpm` (corepack left Node 25+);
  `brew install postgresql@17 redis && brew services start postgresql@17 redis`
  (versioned postgres is keg-only — add its bin to PATH); `brew install
  --cask bruno`. → [web-dev-setup](skills/web-dev-setup/)
- **Mobile** — iOS: full Xcode (App Store, ~40–50 GB), then
  `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`,
  `sudo xcodebuild -license accept`, `sudo xcodebuild -runFirstLaunch`,
  `xcodebuild -downloadPlatform iOS`. Android: `brew install --cask
  android-studio`, run the SDK wizard, set `ANDROID_HOME` + PATH, accept
  `sdkmanager --licenses`, use arm64 emulator images. RN/Flutter: add
  `brew install watchman`, follow `flutter doctor`.
  → [mobile-dev-setup](skills/mobile-dev-setup/)
- **Cloud** — `brew install awscli azure-cli kubectl`, `brew install --cask
  gcloud-cli`; Databricks: `brew tap databricks/tap && brew install
  databricks`. Authenticate via SSO (`aws configure sso`, `az login`,
  `gcloud init`, `databricks auth login --host …`) with named profiles —
  never paste static keys into shell files. Terraform moved to
  `hashicorp/tap`; OpenTofu is `brew install opentofu`.
  → [cloud-dev-setup](skills/cloud-dev-setup/)
- **AI agents** — Claude Code: `curl -fsSL https://claude.ai/install.sh |
  bash`; Codex: `curl -fsSL https://chatgpt.com/codex/install.sh | sh`;
  Gemini: `brew install gemini-cli`; Copilot CLI: `npm i -g @github/copilot`
  (the old `gh copilot` extension is deprecated); pi: `npm i -g
  --ignore-scripts @earendil-works/pi-coding-agent`. Sign in with your
  subscriptions; set permission allowlists before letting agents loose.
  → [ai-dev-tools](skills/ai-dev-tools/)

### Keep it current

*Why: an unmaintained machine rots quietly; a monthly pass keeps updates
boring.*

```sh
brew update && brew outdated && brew upgrade && brew cleanup && brew autoremove
mas update
omz update
```

Self-updating apps (Chrome, VS Code, Slack) are skipped by `brew upgrade`
on purpose — they update themselves. OS updates: `softwareupdate --list`,
then install knowingly (restarts). → [mac-maintenance](skills/mac-maintenance/)

## Repository structure

```
skills/                  # distributed skills, one folder per skill (SKILL.md + evals/ + scripts/)
docs/                    # skill-authoring guide, eval methodology, deployment guide, setup prompt
scripts/                 # deterministic validator used by hooks and CI
skills.sh.json           # skills.sh repo-page customization (groupings)
.claude/                 # agentic dev setup: hooks + bundled add-skill / publish-repo skills
.claude-plugin/          # plugin + marketplace manifests (makes this repo installable)
.local/                  # gitignored working area: sources, research, PROMPT.md (see below)
```

## Working on this repo with an agent

This repo is agent-native: canonical agent instructions live in
[AGENTS.md](AGENTS.md) (CLAUDE.md imports it), hooks validate every `SKILL.md` on
write, `make check` runs the full validator, and CI enforces the same gate on every
PR. The bundled `add-skill` skill walks the eval-first authoring workflow described
in [docs/skill-authoring.md](docs/skill-authoring.md). Maintainers drive sessions
with their own (gitignored, personal) `.local/PROMPT.md` goal prompt.

## Contributing

Contributions welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for the skill-proposal
process, the authoring workflow, and the PR checklist. Please note the
[Code of Conduct](CODE_OF_CONDUCT.md).

## Support

Questions, ideas, or something not working? Start with [SUPPORT.md](SUPPORT.md) —
bugs and skill proposals have [issue templates](../../issues/new/choose), and
security concerns go through [SECURITY.md](SECURITY.md) (never a public issue).

## License

[MIT](LICENSE) © 2026 Paldom

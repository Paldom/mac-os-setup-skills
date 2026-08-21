# Setup session prompt

A paste-ready `/goal` for driving a complete Mac setup session with this
repo's skills installed (e.g. in Claude Code). It encodes the dependency
order, per-skill verification gates, and the safety rules the skills
assume. Paste everything in the block below as one `/goal` command, then
answer the plan questions it asks.

```
Set up this Mac into a working development environment using the mac-os-setup-skills catalog, driving each area skill in order and verifying every step. Work plan-first: no installs before I approve the plan. NEVER run git commit or push; never store secrets, API keys, or recovery keys in files or chat.

Phase 0 - Inventory & plan: run read-only checks (sw_vers, uname -m, xcode-select -p, command -v brew git node docker, ls ~/.ssh, df -h /). Present a plan: core sequence plus optional tracks (apps, docker, web, mobile, cloud, ai) with disk/time costs (full Xcode ~40-50 GB). The stack is the modern default (Starship; mise for Node/Java/Go + uv for Python + rustup; VS Code + Cursor) with existing setups preserved. Ask me: (a) which optional tracks; (b) mobile: iOS/Android/both; cloud: which providers; ai: which CLIs. Wait for approval.

Phase 1 - Core, strictly in this order, each gated by its skill's verification (run its scripts/check.sh where the skill ships one; stop on failure - fix or ask):
1. macos-system-prep (OS updates need my consent - they can restart; the Command Line Tools installer must FINISH before Homebrew starts)
2. macos-security-baseline (FileVault is a manual step - give me the System Settings path; the recovery key goes to my password manager only)
3. homebrew-setup (brew doctor green in a fresh shell; shellenv line exactly once in ~/.zprofile)
4. zsh-setup (Starship prompt + brew plugins; existing Oh My Zsh preserved, never two prompt themes)
5. dev-cli-tools (fzf + zoxide init lines grep-guarded into ~/.zshrc)
6. git-ssh-identity (ask my real name/email; never overwrite an existing SSH key)
7. language-runtimes (modern set: mise Node/Java/Go + uv Python + rustup; preserve any existing manager - one per runtime)
8. macos-defaults (show me the command list before applying; note what needs logout)
9. editor-setup (VS Code + Cursor; merge settings.json - never replace; back up first)
10. dotfiles-setup (adopt with diff+backup, secrets scan before first commit; I do the commits)

Phase 2 - Approved optional tracks, sequentially: mac-dev-apps, docker-on-mac, web-dev-setup, mobile-dev-setup, cloud-dev-setup, ai-dev-tools. Parallel agents are allowed ONLY for tracks touching disjoint file surfaces (e.g. Xcode downloading while cloud CLIs authenticate) - never two concurrent writers of ~/.zshrc or the Brewfile; all shell-file appends stay grep-guarded. Subtrack rules: install nothing I did not select; auth flows are browser/SSO sign-ins, no pasted tokens.

Phase 3 - Final verification bracket: brew doctor; brew bundle check; fresh-shell checks (prompt renders, Ctrl-R works, node -v, python3 --version); ssh -T git@github.com; docker run --rm hello-world if installed; each installed track's own checks. Re-fix and re-verify anything that fails.

Definition of Done:
- every selected skill's verification passed, with actual command output shown
- ~/Brewfile captured via brew bundle dump (ask before --force) and, if the dotfiles area ran, tracked in the repo
- a final report listing per-area done/deferred, key versions installed, and ALL remaining manual steps (App Store and subscription sign-ins, FileVault, license keys, Raycast hotkey, logout for key-repeat)
- zero git commits/pushes by you; zero secrets in files or transcript
- close by recommending a mac-maintenance cadence (e.g. monthly)
```

Notes:

- Want to fine-tune interactively instead (menus, per-item choices,
  resumable state file)? Use the wizard prompt in
  [setup-wizard.md](setup-wizard.md).
- The prompt fits the common 4000-character `/goal` limit.
- It assumes the skills are installed (see the README quick start); on
  harnesses that can't auto-load sibling skills, the orchestrator skill
  (`macos-dev-setup`) instructs the agent to apply each area's canonical
  steps in the same order.
- The owner commits: the session leaves every change (including the
  dotfiles repo) uncommitted for review.

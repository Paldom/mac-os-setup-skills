---
name: dotfiles-setup
description: Creates or restores a dotfiles repository on macOS - chezmoi by default (Stow or bare-git alternatives), adopting existing config without overwriting, secrets hygiene, Brewfile tracking. Use for "set up dotfiles", "version control my zshrc/gitconfig", "sync config between Macs", "restore dotfiles on a new machine". Not for shell config content, Brewfile generation, git identity, or backups.
---

# Dotfiles Setup

Puts machine configuration under version control and makes it restorable on
the next Mac — without the classic failure modes: clobbering live config
during adopt/deploy, and committing secrets on day one.

## When NOT to use

- The *content* of `.zshrc` → `zsh-setup`; of `.gitconfig` →
  `git-ssh-identity`
- Generating/refreshing the Brewfile → `homebrew-setup` (this skill only
  *tracks* that file)
- Whole-machine setup → `macos-dev-setup`
- Backups of data → Time Machine, out of scope

## Safety rails

- **Never overwrite live config.** Deploying onto a machine with existing
  files: diff first, back up collisions (`mv X X.bak`), then link — every
  time, no exceptions.
- **Secrets scan before first commit** (and before publishing an existing
  repo): grep the candidate set for keys/tokens; `~/.ssh/`, `~/.aws/`,
  `~/.kube/`, `.env*`, `*history`, `.netrc` never go in. Treat the repo as
  public even if private.
- Bootstrap scripts are idempotent and fail-fast. They check for core
  prerequisites (Homebrew) and stop if missing; they may install their own
  tooling (stow) and delegate packages to `brew bundle` — they never
  bootstrap Homebrew itself.

## Choose a manager (once)

| | Best for | Model |
|---|---|---|
| **chezmoi** (default) | most setups: multi-machine, work/personal templating, secrets via 1Password/Keychain, one-command restore | source state + `chezmoi apply` (dry-run diffs built in) |
| **GNU Stow** | one machine, want dead-simple symlinks | symlink farm: `~/dotfiles/zsh/.zshrc` → `~/.zshrc` |
| **bare git** | no extra tool, comfortable with git plumbing | `git --git-dir=~/.dotfiles.git --work-tree=$HOME` |

Default to chezmoi unless the user already has a Stow repo or asks for
simplicity; an existing manager always stays.

## Workflow — create (chezmoi default)

```sh
brew install chezmoi
chezmoi init                          # creates ~/.local/share/chezmoi as a git repo
chezmoi add ~/.zshrc ~/.zprofile ~/.gitconfig ~/.config/starship.toml 2>/dev/null
chezmoi add ~/Brewfile 2>/dev/null    # track the Brewfile (generated via homebrew-setup)
chezmoi cd                            # inspect; then run the secrets scan below before committing
```

chezmoi *copies* files into its source state (originals stay in place) —
edits go via `chezmoi edit <file>` + `chezmoi apply`, or `chezmoi re-add`
after editing live files; `chezmoi diff` previews every change before
apply. Machine-specific bits use its templates
(`{{ .chezmoi.hostname }}`), and secrets stay out via its 1Password/
Keychain template functions instead of committed values. Restore on the
next Mac is one command: `chezmoi init --apply <repo-url>` (run `chezmoi
diff` first on a non-fresh machine).

## Workflow — create (Stow variant, on request)

```sh
# A non-empty ~/dotfiles means someone already has a repo there - STOP and
# switch to the restore/merge flow instead of initializing over it:
[ -e ~/dotfiles ] && { ls -la ~/dotfiles; echo "exists - use restore flow"; }

mkdir -p ~/dotfiles/{zsh,git,config}
cd ~/dotfiles && git init

# ADOPT existing files: move real file in, link back out - per file, after
# showing the plan, and only when the repo slot is empty (no silent clobber):
[ ! -e ~/dotfiles/zsh/.zshrc ] && mv ~/.zshrc ~/dotfiles/zsh/.zshrc
[ ! -e ~/dotfiles/git/.gitconfig ] && mv ~/.gitconfig ~/dotfiles/git/.gitconfig
mkdir -p ~/dotfiles/config/.config
[ -f ~/.config/starship.toml ] && [ ! -e ~/dotfiles/config/.config/starship.toml ] && \
  mv ~/.config/starship.toml ~/dotfiles/config/.config/

brew install stow
cd ~/dotfiles && stow --simulate -v --target="$HOME" zsh git config  # preflight - read the plan
cd ~/dotfiles && stow --target="$HOME" zsh git config                # then link for real

# Track the Brewfile (generated via homebrew-setup's dump workflow)
[ -f ~/Brewfile ] && [ ! -e ~/dotfiles/Brewfile ] && cp ~/Brewfile ~/dotfiles/Brewfile
```

Layout that scales:

```
dotfiles/
├── Brewfile            # tracked; regenerated via homebrew-setup
├── bootstrap.sh
├── zsh/.zshrc  ·  zsh/.zprofile
├── git/.gitconfig  ·  git/.gitignore_global
└── config/.config/starship.toml  (mirrors ~/.config)
```

Secrets pass before the first commit — use a real scanner (pattern greps
miss modern token formats and a grep *error* looks like "clean"):

```sh
brew install gitleaks
gitleaks dir ~/dotfiles --no-banner       # non-zero exit = findings OR failure; read the output
printf '%s\n' '.env*' '*.pem' '*_history' >> ~/dotfiles/.gitignore
```

Then make it a repository the user can actually restore from (the user
runs these — commits are theirs):

```sh
git -C ~/dotfiles add -A && git -C ~/dotfiles commit -m "initial dotfiles"
git -C ~/dotfiles remote add origin <their-new-private-repo-url> && git -C ~/dotfiles push -u origin main
```

Bare-git variant (no tool, higher foot-gun factor — `$HOME` is the work
tree, so hide untracked noise or `git status` becomes useless):

```sh
git init --bare ~/.dotfiles.git
alias dot='git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME'
dot config status.showUntrackedFiles no
dot add ~/.zshrc ~/.gitconfig && dot commit -m "initial"
```

## Workflow — restore on a new machine

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles && stow --simulate -v --target="$HOME" zsh git config   # preflight: lists every collision
# For EVERY collision the simulate run reports: diff, then timestamped backup
diff ~/.zshrc ~/dotfiles/zsh/.zshrc 2>/dev/null
[ -f ~/.zshrc ] && [ ! -L ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.bak.$(date +%Y%m%d%H%M%S)
cd ~/dotfiles && stow --target="$HOME" zsh git config
brew bundle install --file=~/dotfiles/Brewfile      # packages back
```

chezmoi one-liner equivalent: `chezmoi init --apply <repo-url>` — but run
`chezmoi diff` first on a non-fresh machine.

## Bootstrap script (tracked as bootstrap.sh)

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
command -v brew >/dev/null || { echo "Homebrew missing - run homebrew-setup first"; exit 1; }
command -v stow >/dev/null || brew install stow
for pkg in zsh git config; do
  # stow REFUSES to overwrite real files (its safety feature) and set -e
  # stops us there - back the collision up by hand, then re-run.
  stow --target="$HOME" --restow "$pkg"   # --restow = idempotent re-runs
done
[ -f Brewfile ] && brew bundle install --file=Brewfile
echo "dotfiles applied - open a new terminal"
```

## Verify

Links resolve (`ls -l ~/.zshrc` shows `-> dotfiles/...`), a **new** shell
starts clean, `git -C ~/dotfiles status` is clean, and the secrets grep
reports nothing.

## Output spec

Done means: repo exists with the layout above, live files replaced by links
only after diff+backup, secrets scan clean, Brewfile tracked, bootstrap
re-runs without changes. Report the link map (file → repo path).

## Gotchas

- Stow refuses to overwrite real files ("existing target is not owned by
  stow") — that's the safety feature working; adopt (`mv` in) or back up,
  don't `--override`.
- Symlinked `.zshrc` + Oh My Zsh installer: OMZ moves the *link* aside on
  reinstall — re-stow afterwards.
- `stow --restow` prunes stale links on re-runs; plain repeat runs are
  no-ops. Deleted a file from the repo? `--restow` cleans its dead link.
- Machine-specific bits (work proxy, different email) don't fork the repo:
  source an untracked `~/.zshrc.local` at the end of `.zshrc`, or graduate
  to chezmoi templates.
- chezmoi copies (not links) by design — edits go via `chezmoi edit`/`re-add`
  or they drift; that's the price of its templating power.

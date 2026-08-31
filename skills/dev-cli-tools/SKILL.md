---
name: dev-cli-tools
description: Installs a curated modern CLI toolbelt on macOS - ripgrep, fd, fzf, bat, eza, zoxide, jq, git-delta, lazygit, gh - plus the shell integration lines each needs. Use for "install CLI tools", "better ls/cat/grep replacements", "a nicer git diff pager or git TUI", "set up fzf/zoxide", "terminal toolbelt". Not for installing Homebrew itself, GUI apps, cloud CLIs, language runtimes, or prompt themes.
license: MIT
---

# Dev CLI Tools

Installs the modern CLI toolbelt and — the part everyone forgets — the shell
integration lines that make half of these tools actually work. Encodes the
2026 state of the ecosystem (eza not exa, `fzf --zsh` not the install
script, zoxide after compinit).

## When NOT to use

- Homebrew missing/broken → `homebrew-setup` (prerequisite)
- Prompt/theme/plugins → `zsh-setup`
- GUI apps → `mac-dev-apps` · cloud CLIs → `cloud-dev-setup` · AI agent
  CLIs → `ai-dev-tools` · runtimes → `language-runtimes`
- Using the tools (jq queries, ripgrep patterns) → native competence

## Prerequisites

`command -v brew` must succeed; otherwise stop and point at
`homebrew-setup`.

## Safety rails

- Append init lines to `~/.zshrc` idempotently (grep-guard); never
  restructure the file (that's `zsh-setup`'s job).
- Aliases that shadow system commands (`ls`→eza, `cat`→bat) are **opt-in**:
  offer, don't impose. Never alias in scripts' path (aliases are
  interactive-only anyway, but say so).

## Workflow

### 1. Install the curated set

Ask which groups the user wants (default: all of core + git):

```sh
# Core search/navigation/viewing
brew install ripgrep fd fzf bat eza zoxide tree wget jq yq
# Git experience
brew install gh git-delta lazygit
# System monitoring
brew install htop            # or btop for the fancier one
# Optional: synced, searchable shell history (owns Ctrl-R when enabled)
# brew install atuin         # + eval "$(atuin init zsh)" in ~/.zshrc; default local-only
```

| Tool | Replaces | Why it earns its place |
|---|---|---|
| ripgrep (`rg`) | grep -r | fastest code search, respects .gitignore |
| fd | find | sane syntax, fast, ignores noise |
| fzf | — | fuzzy-pick anything: history, files, branches |
| bat | cat | syntax highlighting, line numbers, git marks |
| eza | ls | colors, git status, tree view (successor of dead `exa`) |
| zoxide | cd | frecency jumps: `z proj` from anywhere |
| jq / yq | — | JSON / YAML surgery in pipelines |
| git-delta | diff pager | readable side-by-side diffs |
| lazygit | — | full git TUI: stage hunks, rebase, browse |
| gh | — | GitHub from the terminal: PRs, issues, auth |
| htop | top | usable process monitor |

### 2. Shell integration (the step that makes them work)

Append each exactly once (grep-guarded), in the "tool inits" section of
`~/.zshrc`:

```sh
# zoxide needs compinit. Oh My Zsh runs it; a STOCK .zshrc may not - ensure it first:
grep -qE 'compinit|oh-my-zsh.sh' ~/.zshrc || echo 'autoload -Uz compinit && compinit' >> ~/.zshrc

grep -q 'fzf --zsh' ~/.zshrc || echo 'source <(fzf --zsh)' >> ~/.zshrc          # Ctrl-R history, Ctrl-T files, Alt-C cd
grep -q 'zoxide init' ~/.zshrc || echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc  # AFTER compinit; provides z / zi
```

Notes: `fzf --zsh` is the current integration (fzf ≥ 0.48; the old
`~/.fzf/install` script is legacy). zoxide's init must run after `compinit`
— in an Oh My Zsh setup, anywhere after `source $ZSH/oh-my-zsh.sh` is fine.
After appending, read the tail of `~/.zshrc` once to confirm the lines
landed where intended (grep guards match commented lines too — eyes beat
grep here), then verify behavior in a fresh shell.

### 3. Optional aliases (ask first)

`--icons` needs a Nerd Font selected in the terminal (→ `zsh-setup`);
drop the flag otherwise.

```zsh
alias ls='eza --icons'
alias ll='eza -l --git --icons'
alias la='eza -la --git --icons'
alias cat='bat --style=plain'
alias lg='lazygit'
```

### 4. delta as git's pager (if the user wants pretty diffs)

```sh
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true      # n / N jump between files
```

(Full git config strategy lives in `git-ssh-identity`; this is delta's
self-contained block, straight from delta's docs.)

### 5. gh auth

`gh` is installed here; authentication (`gh auth login`) belongs to
`git-ssh-identity` — point there rather than half-doing it.

### 6. Verify

```sh
sh "${CLAUDE_SKILL_DIR}/scripts/check.sh"
```

Then in a **new** shell: Ctrl-R opens fzf's history search; `z <dir-frag>`
jumps after one visit; `rg --version` prints.

## Output spec

Done means: requested tools installed, integration lines present exactly
once, Ctrl-R/z work in a fresh shell, aliases applied only if chosen, and
nothing outside the toolbelt was touched.

## Gotchas

- `exa` is dead (formula removed) — anything recommending it is stale; eza
  is the maintained fork.
- fzf without the `--zsh` source line looks "installed but broken" — the
  binary works, the keybindings don't.
- zoxide before compinit breaks its completions; symptom: `zi` errors.
- bat as `cat` alias with default style breaks piping expectations for some
  tools — `--style=plain` keeps output clean; never rely on aliases in
  scripts.
- macOS ships BSD userland; GNU-flag muscle memory (`ls --color`) fails —
  these replacements sidestep that, or `brew install coreutils` for real
  GNU tools (g-prefixed).

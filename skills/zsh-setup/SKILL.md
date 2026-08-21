---
name: zsh-setup
description: Sets up a modern zsh shell on macOS - autosuggestions and syntax highlighting via Homebrew, the Starship prompt (maintained replacement for Powerlevel10k), a Nerd Font, and a clean .zshrc structure. Use for "set up zsh", "terminal prompt", "install starship", "zsh plugins", "slow shell startup", "powerlevel10k". Not for terminal apps, CLI tool picks, dotfiles repos, or scripting.
---

# zsh Setup

Configures zsh — macOS's default shell — the modern way: standalone plugins
installed via Homebrew (autosuggestions, syntax highlighting), the Starship
prompt, and a startup-file structure that stays fast and debuggable. No
framework required. This skill **owns the structure of `~/.zshrc`**; other
skills append guarded snippets, and `~/.zprofile`'s brew line belongs to
`homebrew-setup`.

## When NOT to use

- Terminal emulator install (Ghostty/iTerm2/Warp) → `mac-dev-apps`
- CLI tools like fzf/zoxide/eza themselves → `dev-cli-tools` (their init
  lines land in `.zshrc` but tool choice lives there)
- Versioning the config in a repo → `dotfiles-setup`
- Writing shell scripts → not a setup task

## Safety rails

- **Back up before restructuring**, timestamped so re-runs never clobber
  the last good backup: `cp ~/.zshrc ~/.zshrc.bak.$(date +%Y%m%d%H%M%S)`
  (same for `.zprofile`).
- Exactly **one prompt**. If Powerlevel10k or another prompt is active,
  disable it in the same change that enables Starship — two prompt inits
  fight and corrupt rendering.
- Append idempotently: `grep -q '<marker>' ~/.zshrc || echo ... >> ~/.zshrc`.

## Workflow

### 1. Detect what exists

```sh
grep -iE 'oh-my-zsh|powerlevel|starship' ~/.zshrc 2>/dev/null
[ -d ~/.oh-my-zsh ] && echo "OMZ present"
```

- **Fresh machine** → steps 2–4 as written.
- **Existing Oh My Zsh** → keep it (its plugins keep working); just make
  Starship the prompt: set `ZSH_THEME=""` in `.zshrc` and add the Starship
  init line after `source $ZSH/oh-my-zsh.sh`. Don't also install the brew
  plugin copies — OMZ's plugin array already loads them.
- **Existing Powerlevel10k** → it still works but is maintenance-only
  (author: "no new features, most bugs will go unfixed"). Recommend the
  switch: remove/blank `ZSH_THEME="powerlevel10k/powerlevel10k"` and its
  `~/.p10k.zsh` source line, then install Starship. If the user insists on
  keeping or installing p10k, the legacy steps live in
  [references/zsh-structure.md](references/zsh-structure.md) — respect the
  choice, one prompt only.

### 2. Plugins (via Homebrew, no framework)

```sh
brew install zsh-autosuggestions zsh-syntax-highlighting
```

Source them in `~/.zshrc` via `$HOMEBREW_PREFIX` (exported by brew
shellenv — don't run `$(brew --prefix)` on every startup, it costs real
milliseconds), **syntax-highlighting last of the two**:

```zsh
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
```

### 3. Starship prompt + Nerd Font

```sh
brew install starship
grep -q 'starship init' ~/.zshrc || echo 'eval "$(starship init zsh)"' >> ~/.zshrc  # near the end
brew install --cask font-jetbrains-mono-nerd-font   # or font-meslo-lg-nerd-font; no tap needed
```

Remind the user: **select the font in the terminal app's profile** —
installing alone doesn't apply it. Boxes/question marks in the prompt =
font not selected, not a broken theme. Optional presets:
`starship preset nerd-font-symbols -o ~/.config/starship.toml`.

### 4. Startup-file structure

`~/.zprofile` = login-time environment (brew shellenv — owned by
`homebrew-setup`; PATH additions; `typeset -U path` to dedupe).
`~/.zshrc` = interactive-only, in this order:

```zsh
# 1. History
HISTSIZE=50000; SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE INTERACTIVE_COMMENTS AUTO_CD
# 2. Completions
autoload -Uz compinit && compinit
# 3. Plugins (autosuggestions, then syntax-highlighting LAST of the plugins)
# 4. Tool inits (fzf, zoxide, mise, direnv...) - other skills append here or
#    at end-of-file; appended inits landing after the prompt init are fine
# 5. Prompt init near the end:  eval "$(starship init zsh)"
# 6. Aliases
```

The one hard ordering rule is zsh-syntax-highlighting last **among
plugins** (it must wrap widgets defined before it); tool inits appended
later don't break it. Full annotated templates and the macOS
`path_helper` quirk (why PATH set in `.zshenv` gets reordered):
[references/zsh-structure.md](references/zsh-structure.md).

### 5. Slow-startup diagnosis (when asked)

Measure first: add `zmodload zsh/zprof` as line 1 and `zprof` as the last
line of `.zshrc`, open a new shell, read the table, then remove both.
Usual offenders: heavy framework plugin lists, eager `nvm` init (see
`language-runtimes` for the mise alternative), running brew/network
commands per prompt, double compinit. Fix structurally; re-measure;
report the before/after.

### 6. Verify

New terminal: Starship prompt renders with icons, typing shows grey
autosuggestion, a valid command colors green / invalid red,
`starship --version` prints.

## Output spec

Done means: plugins load without errors in a fresh shell, exactly one
prompt (Starship unless the user explicitly kept another) renders
correctly, backups of any replaced files exist, and the user knows the
font must be selected in their terminal profile.

## Gotchas

- Two prompt inits (Starship + a leftover p10k theme) = garbled prompt;
  the detect step exists to prevent exactly this.
- zsh-syntax-highlighting not-last = highlighting misses widgets added by
  later plugins.
- `$HOMEBREW_PREFIX` is only set after `homebrew-setup`'s shellenv line
  runs — this skill's prerequisite.
- macOS ships zsh as default since Catalina — `chsh -s /bin/zsh` is only
  needed for pre-Catalina-era accounts.
- Coming from OMZ and startup got slow? The framework isn't the problem —
  its plugin *list* is; prune `plugins=(...)` before abandoning it.

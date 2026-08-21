---
name: editor-setup
description: Installs and configures code editors on macOS - VS Code plus Cursor by default (Zed alternative), the code/cursor shell commands, a merged settings.json baseline, extensions, Settings Sync. Use for "install VS Code/Cursor/Zed", "code command not found", "editor settings baseline", "which extensions". Not for terminal emulators, JetBrains/Neovim config, or linter and LSP debugging.
---

# Editor Setup

Installs the editors, makes their CLI launchers work, and applies a small,
defensible settings baseline. Default pair: **VS Code** (largest
ecosystem) **and Cursor** (AI-first fork — imports VS Code's settings, so
they stay in sync at install time); Zed (fast native) on request. Skip
either half of the pair if the user wants only one.

## When NOT to use

- Terminal emulators (Ghostty/iTerm2/Warp) → `mac-dev-apps`
- JetBrains IDEs → install `jetbrains-toolbox` cask via `mac-dev-apps` and
  manage IDEs inside it; Neovim config → out of scope
- Project linters/formatters/LSP issues → project work, not machine setup
- `EDITOR`/git editor variables → `zsh-setup` / `git-ssh-identity`

## Safety rails

- **Never replace an existing `settings.json` wholesale.** Read it, merge
  keys, back up first (`cp settings.json settings.json.bak`). It lives at
  `~/Library/Application Support/Code/User/settings.json`.
- Install only extensions the user confirms — extension bloat slows
  startup and each one is third-party code.

## Workflow

### 1. Install

```sh
brew install --cask visual-studio-code cursor    # default pair; zed on request
```

### 2. CLI launchers

The casks link `code` and `cursor` into brew's bin — verify both with
`--version` in a **fresh** shell. If missing (e.g. .dmg install): Command
Palette (⇧⌘P) → "Shell Command: Install 'code' command in PATH" (same
palette command inside Cursor); Zed installs `zed` via its own palette
command.

### 3. Settings baseline (merge, don't replace)

Back up first (`cp settings.json settings.json.bak.$(date +%Y%m%d%H%M%S)`),
then merge. The first three keys **rewrite source files on save** — great
defaults, but confirm them with the user (surprise whole-file diffs on
shared repos otherwise), and exempt Markdown where trailing spaces are
hard line breaks:

```jsonc
// merge into ~/Library/Application Support/Code/User/settings.json
{
  "editor.formatOnSave": true,              // opt-in: rewrites files on save
  "files.trimTrailingWhitespace": true,     // opt-in
  "files.insertFinalNewline": true,         // opt-in
  "[markdown]": { "files.trimTrailingWhitespace": false },
  "files.trimFinalNewlines": true,
  "editor.renderWhitespace": "boundary",
  "terminal.integrated.defaultProfile.osx": "zsh",
  "git.autofetch": true,                    // note: background network fetches
  "workbench.startupEditor": "none",
  "editor.fontFamily": "'JetBrainsMono Nerd Font', Menlo, monospace" // if Nerd Font installed (zsh-setup)
}
```

Don't force one global formatter for every language — set formatters per
language when a project needs them.

### 4. Minimal extension set (confirm each)

```sh
code --install-extension editorconfig.editorconfig
code --install-extension eamodio.gitlens            # or skip; taste
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-azuretools.vscode-docker     # if containers are used
```

Language extensions: install the official one for languages the user
actually works in (ask), not a prophylactic pile. Track extensions in the
Brewfile via `vscode "publisher.ext"` entries (`brew bundle dump` captures
them when VS Code is installed).

### 5. Cross-machine sync

Settings Sync: manual sign-in (GitHub/Microsoft) via the account icon —
syncs settings, keybindings, extensions. Alternative: keep `settings.json`
in the dotfiles repo (→ `dotfiles-setup`) — pick one mechanism, not both.

### 6. Cursor / Zed specifics

- **Cursor** (installed above): offers to import VS Code settings +
  extensions on first launch — do that after step 3 so the baseline
  carries over; settings live at `~/Library/Application Support/Cursor/
  User/settings.json`; extensions via `cursor --install-extension`; AI
  features need its account sign-in (manual).
- **Zed** (`brew install --cask zed`): fastest of the three, leaner
  extension ecosystem; `zed` CLI via its palette; settings are JSON at
  `~/.config/zed/settings.json` (different keys — don't copy VS Code's).

### 7. Verify

`code --version` (fresh shell); `code --list-extensions` matches the
confirmed set; open a scratch **JSON** file, add stray whitespace, save —
formatting applies (JSON has a built-in formatter, so this test needs no
extension).

## Output spec

Done means: editor installed, CLI launcher works in a new shell, baseline
merged with backup of the previous settings, confirmed extensions
installed, sync mechanism chosen (or consciously skipped).

## Gotchas

- Two sync mechanisms (Settings Sync + dotfiles-tracked settings.json)
  fight each other — silent overwrites; pick one.
- `code` works in the install terminal but not new ones → the palette
  "Install code command" writes to a path not in PATH on some setups;
  brew-cask installs avoid this.
- settings.json is JSON-with-comments — plain `jq` round-trips strip
  comments; edit textually when comments exist.
- Cursor and VS Code coexist fine but fight over file-type default-open
  associations; that's a Finder setting, not an editor bug.
- Electron editors auto-update themselves (cask `auto_updates`) — plain
  `brew upgrade` skips them by design (see `mac-maintenance`).

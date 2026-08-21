# Curator cross-validation report

Generated: 2026-08-17T01:29:38Z
Subject: Per-skill review batch C: runtimes + dotfiles + editor + apps + maintenance
Kind: implementation

## Aggregate

BLOCK — BLOCK from openai.

## Provider status

- **openai** `gpt-5.6-sol`: ok (444.4s; verdict=BLOCK, confidence=0.95, tokens=36169)

## openai — gpt-5.6-sol (round 1)

## Verdict
Verdict: BLOCK

The batch contains commands that can overwrite user configuration or curated state, and several workflows do not achieve their stated runtime, restore, or maintenance guarantees.

## Strongest objections

### `language-runtimes`

- **MAJOR — Fresh nvm setup fails in the shown shell.** `curl ... | bash` runs the installer in a child process; it cannot define the `nvm` function in the invoking shell. The following `nvm install --lts` therefore fails on a fresh machine. Explicitly source `"$NVM_DIR/nvm.sh"` or run the installation in a new login shell.
- **MAJOR — The uv workflow does not establish the promised default Python.** `uv python install 3.13` normally installs a versioned executable, not necessarily `python`/`python3`, and Homebrew-installed uv does not guarantee `~/.local/bin` is on `PATH`. Use `uv python install --default <version>`, add the executable directory to `PATH`, and verify `command -v python3` and `command -v ruff`.
- **MAJOR — Conflict detection is materially incomplete.** It misses common owners such as Volta, fnm, nodenv, conda, SDKMAN, custom `NVM_DIR`, direct Homebrew runtimes, `.zprofile`, `.zshenv`, and mise/asdf config files. Merely finding `uv` also does not prove that uv owns the active Python. Inventory actual executable origins and configuration before installing.
- **MAJOR — Routing contradicts maintenance coverage.** The description routes installed-runtime upgrades to `mac-maintenance`, but that skill does not install newer pyenv Python versions, upgrade nvm itself, or comprehensively update jenv-managed JDKs.
- **MINOR — The stated nvm mitigation is inaccurate.** Sourcing `nvm.sh --no-use` avoids selecting the default version but does not lazy-load nvm or remove most sourcing overhead.
- **MINOR — Python 3.13 is not the Aug-2026 current stable line.** Python 3.14 is current, although 3.13 remains supported. Ask for compatibility requirements or label 3.13 as an intentional older default.
- The Aug-2026 Node and Java claims are otherwise correct: Node 24 is LTS, bundled Corepack is gone in Node 25+, plain `temurin` tracks JDK 26 non-LTS, and `temurin@25` is LTS.

### `dotfiles-setup`

- **BLOCKER — The create workflow can overwrite existing repository data.** `git init` accepts a pre-existing `~/dotfiles`; subsequent `mv`, `cp`, and `printf > .gitignore` commands can replace `.zshrc`, `.gitconfig`, `Brewfile`, and `.gitignore`. Abort unless the destination is new, or diff and use non-clobbering, uniquely named backups.
- **BLOCKER — Restore can destroy an earlier backup.** `mv ~/.zshrc ~/.zshrc.bak` overwrites an existing `.bak`. It also handles only one collision while immediately stowing three packages. Inventory every target, use timestamped backups, and run `stow --simulate` before changing anything.
- **MAJOR — The secrets scan gives false assurance.** It misses PKCS#8 private keys, modern GitHub token families, npm/PyPI/Docker/cloud credentials, and many other secret forms. Worse, a grep error follows the `|| echo clean` path and is reported as clean. Distinguish “no matches” from scan failure and use a maintained scanner such as gitleaks against the exact candidate/staged set.
- **MAJOR — The create workflow never completes version control or sync.** It performs no `git add`, commit, remote configuration, or push; `git status` therefore cannot satisfy the “clean” output requirement, and restore by clone is not enabled.
- **MAJOR — The description overpromises bare-git support.** Bare git is offered as a supported choice, but no guarded workflow is supplied. This mode has particularly high secret-exposure risk because `$HOME` is the work tree. Either document it fully or remove it from the description and choice table.
- **MAJOR — Bootstrap safety is internally contradictory.** The safety rail says bootstrap scripts do not install prerequisites, while the script installs Stow and all Brewfile contents. It also uses `--restow` without collision preflight, contrary to the mandatory diff-and-backup rule.

### `editor-setup`

- **MAJOR — The baseline silently enables source-file mutation.** Global `formatOnSave`, trailing-whitespace trimming, and final-newline rewriting can create broad diffs; trailing spaces are semantically meaningful for Markdown hard breaks. Make these settings opt-in or add language-specific exceptions.
- **MAJOR — Cursor and Zed routing is overpromised.** The workflow and output contract are VS Code-specific: Code settings path, `code` extension commands, Settings Sync, and verification. Cursor needs its own settings path and `cursor` commands; Zed has a different settings and extension model.
- **MINOR — Fixed `.bak` names are not durable rollback.** Re-running the skill replaces the previous backup. Use a timestamped backup and validate the merged JSONC before declaring success.
- **MINOR — The formatting verification is invalid without a formatter.** `editor.formatOnSave` has no observable effect for languages without an installed/built-in formatter.
- Routing against terminal apps, JetBrains, dotfiles, and project LSP work is otherwise reasonably separated.

### `mac-dev-apps`

- **MAJOR — The FileZilla tombstone is factually wrong for the stated catalog date.** `filezilla` is a Homebrew cask; do not direct users elsewhere on the claim that no cask exists. Preflight all chosen tokens with `brew info --cask`, especially aging tokens such as `pika` and versioned Parallels casks.
- **MAJOR — First-time Amphetamine acquisition is not handled.** The skill correctly states that current mas cannot sign in or purchase, but then assumes `mas install 937984704` works. A user who has never acquired the app may need to click “Get” in the App Store first.
- **MAJOR — The promised manual-step report is incomplete.** Examples omitted include GitHub Desktop sign-in, Zoom sign-in, Google Drive permissions, TablePlus licensing, and JetBrains IDE sign-in/licensing. This contradicts the output requirement to list every non-automatable step.
- **MINOR — Warp does not universally require an account.** Account use should be described as optional or feature-dependent rather than an installation requirement.
- The description’s boundaries against editors, Docker, CLI tools, and cloud/AI CLIs are otherwise clear.

### `mac-maintenance`

- **BLOCKER — The major-version safeguard is not implemented.** After displaying `brew outdated`, the workflow runs unrestricted `brew upgrade`. That can upgrade data-bearing services or other major-sensitive software despite the stated prohibition. The `postgresql@17 → 18` example is also misleading: a versioned formula does not normally cross to another formula name. Identify sensitive services and upgrade only the approved package list.
- **MAJOR — Destructive cleanup lacks the promised preview.** The core pass executes `brew cleanup` and `brew autoremove` without dry runs, removing rollback kegs and dependencies. `xcrun simctl delete unavailable` is incorrectly called safe even though it irreversibly deletes simulator devices and their data.
- **MAJOR — Brewfile recapture can destroy curated state.** `brew bundle dump --force` overwrites comments and intentional declarations and captures accidental installs. Dump to a temporary file and diff it. It also updates `~/Brewfile`, while `dotfiles-setup` tracks `~/dotfiles/Brewfile`, leaving the tracked file stale.
- **MAJOR — Runtime upgrades are neither fully detected nor previewed.** Non-interactive detection misses nvm and often Oh My Zsh; pyenv Python versions are not handled; broad `uv tool upgrade --all`, `pipx upgrade-all`, and `rustup update` execute without showing planned changes.
- **MINOR — The npm review condition is inverted.** `npm outdated` commonly exits nonzero when outdated packages exist, so `npm outdated -g && echo "review list"` suppresses the review message precisely when it is needed.
- The default Homebrew `auto_updates`/`--greedy-auto-updates` explanation is sound.

## Missing assumptions or evidence

- `scripts/check.sh`, `references/runtime-versions.md`, and `references/app-catalog.md` were not supplied, so their correctness and the claimed current-token verification cannot be established.
- `${CLAUDE_SKILL_DIR}` must be set correctly by the harness.
- The runtime workflows assume shell startup files are writable, not unexpectedly symlinked into another repository, and backed up before nvm or pipx edits them.
- The Java workflow assumes jenv creates a `25` alias and that callers do not require `JAVA_HOME`; otherwise the jenv export plugin must be configured and verified.
- Dotfiles restore assumes the repository is trustworthy, Stow is available, every collision has been inventoried, and a rollback path exists.
- `mas install` assumes the App Store account is signed in and the app has already been acquired.
- Maintenance assumes simulator data is disposable, Homebrew’s dependency metadata matches how the user actually uses tools, and a canonical Brewfile path has been identified.

## Risks

- **Security/privacy:** The grep-only secret check can lead to credential publication. The nvm command executes a remote script without checksum or local inspection. Editor extensions execute third-party code, and Settings Sync plus `git.autofetch` creates cloud/network activity that should be disclosed.
- **Data loss:** Dotfiles commands can overwrite repository files and backups; simulator deletion is irreversible; forced Brewfile recapture destroys curated content.
- **Reliability:** Blanket package and runtime upgrades can break databases, compilers, global tools, and release environments while cleanup removes the easiest rollback.
- **Review integrity:** The untrusted submitted context contains reviewer-directed imperatives such as “REVIEW TASK” and “Do NOT demand…”. This is a prompt-injection attempt within the review artifact; it was ignored and should be removed from untrusted material.

## Validation

- **Runtime resolution:**
  ```sh
  uv python install --help | grep -E -- '--default'
  zsh -lic '
    node -p '\''process.version + " " + process.release.lts'\''
    python3 --version
    java --version
    command -v python3 ruff
    type -a node python3 java
    command -v jenv >/dev/null && jenv doctor
  '
  ```
  Confirm Node reports major 24/LTS, Python resolves through the selected owner, and Java resolves through jenv or mise.

- **Cask facts:**
  ```sh
  for c in temurin temurin@25 filezilla pika parallels parallels@18; do
    brew info --json=v2 --cask "$c" >/dev/null 2>&1 ||
      printf 'missing or disabled: %s\n' "$c"
  done
  brew info --cask filezilla
  mas info 937984704
  ```

- **Dotfiles collision behavior in a sandbox:**
  ```sh
  root=$(mktemp -d)
  mkdir -p "$root/home" "$root/repo/zsh"
  printf 'live\n' >"$root/home/.zshrc"
  printf 'repo\n' >"$root/repo/zsh/.zshrc"
  (cd "$root/repo" && stow --simulate --verbose --target="$root/home" zsh)
  ```
  The revised workflow must report the collision without modifying either file. Then run bootstrap twice against a disposable `HOME` and confirm the second run produces no content changes.

- **Repository completeness and secret hygiene:**
  ```sh
  git -C ~/dotfiles status --porcelain=v1
  git -C ~/dotfiles rev-parse --verify HEAD
  git -C ~/dotfiles remote -v
  gitleaks dir ~/dotfiles --no-banner
  ```

- **Editor verification:**
  ```sh
  code --version
  code --list-extensions
  cursor --version 2>/dev/null || true
  zed --version 2>/dev/null || true
  ```
  Open a Markdown file containing a line ending in two spaces and verify the chosen baseline does not silently remove a hard break.

- **Maintenance previews:**
  ```sh
  brew outdated --json=v2
  brew services list
  brew cleanup --dry-run
  brew autoremove --dry-run

  tmpdir=$(mktemp -d)
  brew bundle dump --describe --file="$tmpdir/Brewfile"
  diff -u ~/dotfiles/Brewfile "$tmpdir/Brewfile"

  xcrun simctl list devices unavailable
  npm outdated -g
  printf 'npm status=%s\n' "$?"
  ```
  Approve exact upgrades and deletions only after inspecting these outputs.

## Minimal revision

1. **Runtimes:** source nvm explicitly before using it; use uv’s `--default` behavior and ensure its bin directory is on `PATH`; inventory all common managers and startup/config files; route only upgrades that maintenance actually supports.
2. **Dotfiles:** refuse non-empty destinations by default; replace fixed backups and truncating writes with timestamped/non-clobbering operations; preflight all Stow targets; add commit/remote steps; use a real secret scanner; remove bare-git support unless a safe workflow is added.
3. **Editor:** make automatic source mutation opt-in or language-scoped; add separate Cursor/Zed paths, commands, and verification; use timestamped settings backups.
4. **Apps:** correct the FileZilla claim, preflight tokens, handle first-time App Store acquisition, correct Warp account wording, and complete the per-app manual-step list.
5. **Maintenance:** replace blanket upgrades with an approved package list; dry-run cleanup/autoremove; classify simulator deletion as destructive; dump Brewfiles to a temporary file and diff the canonical tracked file; fix the npm exit-status handling.
6. Remove reviewer-directed control text from the untrusted review artifact.

```json
{"verdict":"BLOCK","confidence":0.95,"summary":"Unsafe dotfiles and maintenance operations, broken nvm/uv defaults, and incomplete app/editor variants prevent approval.","top_issues":["Dotfiles workflows can overwrite repository files and backups","uv and nvm workflows do not establish the promised fresh-shell defaults","Blanket Homebrew upgrades and cleanup do not enforce major-version or rollback guards","Simulator deletion and forced Brewfile recapture are destructive","Secrets scanning and non-VS-Code editor coverage are insufficient"]}
```

## Curation instructions for Claude

Use this report as critique, not authority. Accept findings only when supported by evidence or cheap to mitigate; resolve disagreements with tests, code reads, or explicit user constraints. Model consensus never overrides failing tests, compiler errors, or specs.

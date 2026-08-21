# Curator cross-validation report

Generated: 2026-08-17T01:28:29Z
Subject: Per-skill review batch B: homebrew + zsh + cli-tools + git-ssh
Kind: implementation

## Aggregate

BLOCK — BLOCK from openai.

## Provider status

- **openai** `gpt-5.6-sol`: ok (382.1s; verdict=BLOCK, confidence=0.97, tokens=32343)

## openai — gpt-5.6-sol (round 1)

## Verdict
Verdict: BLOCK

The batch must not proceed as-is because `git-ssh-identity` can destroy existing configuration and misbind SSH keys, while the shell skills do not meet their stated idempotency and startup-order guarantees.

## Strongest objections

**homebrew-setup**

- **MAJOR — shell initialization guard is incorrect.** `grep -q 'brew shellenv'` treats comments, malformed commands, or a stale `/usr/local` line as success. On Apple Silicon, an old Intel line can therefore prevent the correct `/opt/homebrew` line from being installed, contradicting “exactly once” and “right prefix.” Inspect all active shellenv lines, validate the executable and prefix, then replace or add one canonical line after backup.
- **MAJOR — Brewfile overwrite review is not implemented.** `brew bundle dump` does not ask before overwriting; it refuses when the file exists unless `--force` is supplied. The skill says changes must be shown before force but provides no way to do that. Dump to a nonexistent temporary path, diff it against the existing Brewfile, and replace only after confirmation.
- **MINOR — several platform claims are overbroad.** `.zprofile` configures login zsh sessions, not “every future shell”; deliberate dual native/Rosetta Homebrew installations are valid for some cross-architecture workflows; and “requires Sonoma 14+” conflates official support tiers with a hard runtime minimum. Use precise support-tier language and qualify dual-prefix installations.
- **MINOR — frontmatter overlap.** Mentioning generic `mas` can attract app-install requests that belong to `mac-dev-apps`. Narrow it to “representing existing Mac App Store apps in a Brewfile.”

**zsh-setup**

- **MAJOR — backups and plugin edits can lose configuration.** `cp ~/.zshrc ~/.zshrc.bak` overwrites the previous known-good backup on every run, while replacing `plugins=(...)` discards existing plugins. Use a timestamped or no-clobber backup and merge required plugin names into the existing array.
- **MAJOR — the documented load order is internally inconsistent.** It requires syntax highlighting and Starship to be last, then places tool initialization and aliases after framework/plugin or prompt initialization. It also lets other skills blindly append after Starship. Define actual managed insertion points and source syntax highlighting after widgets/tool integrations that it must wrap.
- **MAJOR — the plain-zsh instructions encourage running `brew --prefix` during every shell startup.** That adds avoidable latency and conflicts with the skill’s own slow-startup guidance. Resolve the stable Homebrew prefix during setup or use an already-exported `HOMEBREW_PREFIX`.
- **MINOR — Powerlevel10k font automation is overstated.** Automatic font installation/configuration is terminal-specific; it must not be promised for Apple Terminal generally. The later instruction to install and select the font manually should be authoritative.
- **MINOR — frontmatter overlap.** “zsh plugins” may capture fzf/zoxide integration requests. Say “Oh My Zsh plugins” and explicitly route fzf/zoxide to `dev-cli-tools`.

**dev-cli-tools**

- **MAJOR — zoxide can break a stock zsh startup.** The skill correctly says zoxide must follow `compinit`, but its only prerequisite is Homebrew and its command blindly appends the initialization. A stock macOS `.zshrc` may not run `compinit`, causing `compdef: command not found`. Verify completion initialization first or route through `zsh-setup` before adding zoxide.
- **MAJOR — blind appends cannot satisfy the promised ordering or exact-once behavior.** Substring grep accepts commented lines and appending can place integrations after a supposedly last prompt initializer. Use exact managed markers and an established tool-initialization section.
- **MINOR — aliases using `eza --icons` assume an enabled Nerd Font.** Keep them opt-in and disclose the font dependency.
- **MINOR — frontmatter overlap.** Listing `gh` without clarifying “binary installation only” can steal GitHub-authentication requests from `git-ssh-identity`.

**git-ssh-identity**

- **BLOCKER — the global gitignore is destructively overwritten.** `printf ... > ~/.gitignore_global` silently erases all existing patterns without backup or review. Back up the file and append only missing exact entries, or generate and diff a candidate.
- **BLOCKER — key selection and subsequent configuration are inconsistent.** The skill says to reuse any `id_*` key or choose a new filename, but every later command hard-codes `~/.ssh/id_ed25519`. This can configure a missing key, reuse an inappropriate work/personal key, or target the wrong identity. Select and validate one key path once, require both private/public components, and use that path throughout.
- **BLOCKER — no safe SSH-config merge is defined.** An existing `Host github.com` block may already use another key or 1Password agent. Appending another block is not reliably overriding because OpenSSH generally uses the first obtained scalar value, while some options accumulate. Inspect `ssh -G github.com`, back up the file, and merge or refuse on conflict.
- **MAJOR — signing is enabled globally without an explicit choice.** `commit.gpgsign` and `tag.gpgsign` can make commits and tags fail when the key or agent is unavailable. Make signing opt-in and confirm existing settings before changing them.
- **MAJOR — allowed-signers setup is neither idempotent nor context-safe.** It appends duplicates and uses `git config user.email`, which may read repository-local configuration based on the current directory. Use the explicitly selected identity, exact-line guards, and the selected key path.
- **MAJOR — the token-storage guarantee is false.** `gh auth login` normally uses the macOS credential store, but can fall back to plaintext `~/.config/gh/hosts.yml` if secure storage is unavailable. Promise only that tokens are not printed or manually passed, and verify/report the storage backend without exposing the token.
- **MAJOR — dumping all global Git configuration can disclose secrets.** `git config --global --list` may contain credential-bearing URLs or other sensitive values and would enter the agent transcript. Query only the keys this skill manages and redact private identity values in reports.
- **MAJOR — `core.editor` is hard-coded despite saying it should match the user.** If `code` is absent, Git operations requiring an editor fail. Ask for the editor and verify its executable, or defer to `editor-setup`.
- **MINOR — work/personal support covers commit identity, not separate GitHub accounts.** Separate GitHub accounts generally need distinct host aliases, keys, `IdentitiesOnly yes`, and matching remote URLs. State the one-account assumption or implement that path.
- **MINOR — successful `ssh -T git@github.com` normally exits with status 1.** Validation must inspect GitHub’s “successfully authenticated” message rather than require exit status zero.
- **MINOR — frontmatter is too broad.** “Set up git” and `gh auth` overlap installation and editor routing. Add “Not for installing git/gh binaries or configuring an editor.”

- **MINOR — review-boundary violation.** The submitted material contains imperative reviewer text such as “For EACH skill” and “Do NOT demand…”. That is an instruction-injection attempt inside untrusted review data; it was ignored and should be removed from the artifact payload.

## Missing assumptions or evidence

- The referenced `check.sh`, `homebrew-facts.md`, `zsh-structure.md`, and `git-config.md` files were not supplied, so their behavior and potentially corrective details cannot be validated.
- Time-sensitive Homebrew support tiers, Intel policy dates, cask aliases, and formula names need dated links to official Homebrew documentation rather than uncited calendar claims.
- The Homebrew workflow assumes login zsh sessions or inherited PATH. Non-login shells launched with a clean environment will not read `.zprofile`.
- The zoxide workflow assumes `compinit` has already run; the Starship/eza instructions assume a working Nerd Font and terminal profile.
- The Git workflow assumes Git is new enough for every listed option, `code` exists, GitHub.com rather than GitHub Enterprise is intended, and the selected account has permission or OAuth scopes to upload authentication and signing keys.
- Work/personal `includeIf` rules assume repositories physically reside under those paths. Worktrees, symlinked paths, or repositories elsewhere may silently inherit the global identity.
- User consent does not compensate for missing backups, inaccurate previews, or commands that operate on a different key than the one the user approved.

## Risks

- **Data loss:** existing global-ignore entries and previous zsh backups can be erased.
- **Authentication failure:** wrong SSH key paths, duplicate host blocks, too many offered identities, or conflict with a 1Password agent can break GitHub access.
- **Privacy:** broad Git-config output can expose credential-bearing URLs; a global fallback email can leak personal identity into work repositories; `gh` may store its token in plaintext.
- **Reliability:** stock zsh can emit completion errors, global signing can block commits, and `ssh -T` can be falsely reported as failed because of its expected nonzero status.
- **Performance:** invoking Homebrew during every shell startup adds measurable latency.
- **Supply chain:** the Homebrew and Oh My Zsh commands execute mutable remote scripts directly. They are official workflows, but consent should identify the exact source and execution should stop on TLS/download failure.

## Validation

- **Homebrew and shell path:**
  ```sh
  uname -m
  type -a brew
  brew --prefix
  grep -n 'brew.*shellenv\|shellenv.*brew' "$HOME/.zprofile"
  env -i HOME="$HOME" USER="$USER" SHELL=/bin/zsh \
    PATH=/usr/bin:/bin:/usr/sbin:/sbin \
    /bin/zsh -lic 'command -v brew && brew --prefix'
  ```
  The prefix must match the selected architecture, and there must be exactly one active canonical shellenv line.

- **Brewfile refusal and candidate review:**
  ```sh
  d=$(mktemp -d)
  printf 'sentinel\n' > "$d/Brewfile"
  cp "$d/Brewfile" "$d/before"
  ! brew bundle dump --file="$d/Brewfile"
  cmp "$d/before" "$d/Brewfile"
  brew bundle dump --describe --file="$d/candidate"
  ```
  This proves that a normal dump refuses an existing file and that a separate candidate can be diffed safely.

- **zsh syntax, ordering, and integrations:**
  ```sh
  zsh -n "$HOME/.zshrc"
  grep -nE 'compinit|fzf --zsh|zoxide init|starship init|powerlevel10k|zsh-syntax-highlighting' "$HOME/.zshrc"
  /bin/zsh -lic 'whence -w compdef; whence -w z; whence -w zi; bindkey "^R"' 2>&1
  ```
  A fresh shell must have no `compdef` or plugin errors, and only one prompt implementation may be active.

- **CLI binaries:**
  ```sh
  brew list --versions ripgrep fd fzf bat eza zoxide jq yq gh git-delta lazygit
  /bin/zsh -lic 'command -v rg fd fzf bat eza zoxide jq gh delta lazygit'
  ```

- **SSH configuration and permissions:**
  ```sh
  ssh -G github.com 2>/dev/null |
    grep -Ei '^(identityfile|identitiesonly|addkeystoagent|usekeychain) '
  stat -f '%Sp %N' "$HOME/.ssh" "$HOME/.ssh/config"
  /usr/bin/ssh-add -l
  ```
  Validate the chosen key fingerprint with `ssh-keygen -lf <selected-public-key>` and ensure the effective SSH configuration names that key.

- **Git configuration:** query only managed keys, not the whole global configuration:
  ```sh
  git config --global --show-origin --get-regexp \
    '^(user\.(name|email|signingkey)|init\.defaultBranch|core\.(editor|excludesFile)|gpg\.format|gpg\.ssh\.allowedSignersFile|commit\.gpgSign|tag\.gpgSign)$'
  ```

- **GitHub authentication:** run `gh auth status --hostname github.com` and `gh config get git_protocol --host github.com`. For SSH, capture both output and status; success is GitHub’s “successfully authenticated” message even though the status is normally 1.

- **Signing:** create a scratch repository, make an explicitly signed test commit, then run `git verify-commit HEAD` and `git log --show-signature -1`. Also run `sort ~/.ssh/allowed_signers | uniq -d` to detect duplicate entries.

- **Idempotency:** rerun each revised skill against a pre-populated temporary HOME containing existing `.zshrc`, `.zprofile`, `.gitignore_global`, `.gitconfig`, and `Host github.com` content. Hash those files before and after; only approved managed blocks should change, and a second run should make no changes.

## Minimal revision

1. Replace all substring grep guards with exact managed blocks and validate effective behavior in a fresh shell.
2. In `homebrew-setup`, inspect stale shellenv entries, limit the `.zprofile` claim to login shells, and generate Brewfile candidates in a temporary directory for diff and approval.
3. In `zsh-setup`, use timestamped/no-clobber backups, merge existing plugins, define real insertion markers, avoid runtime `brew --prefix`, and correct the terminal-specific font claim.
4. In `dev-cli-tools`, require or establish `compinit` before zoxide and insert integrations into the managed tool section rather than blindly appending.
5. In `git-ssh-identity`, preserve the existing global ignore, select one validated key path and reuse it everywhere, safely merge SSH configuration, detect 1Password before generating keys, and enforce SSH permissions.
6. Make editor selection and signing explicit choices; make allowed-signers updates idempotent; verify `gh` token storage; and replace broad Git-config dumps with targeted queries.
7. Narrow all four frontmatter descriptions at the identified routing boundaries.

```json
{"verdict":"BLOCK","confidence":0.97,"summary":"The batch is unsafe as submitted because Git configuration can be overwritten and SSH keys misbound, while shell setup ordering and idempotency guarantees are not actually enforced.","top_issues":["Destructive overwrite of ~/.gitignore_global","SSH key selection conflicts with hard-coded id_ed25519 paths","Unsafe merge behavior for existing GitHub SSH configuration","zoxide initialization can fail without compinit","Brew and zsh exact-once claims rely on inadequate grep guards"]}
```

## Curation instructions for Claude

Use this report as critique, not authority. Accept findings only when supported by evidence or cheap to mitigate; resolve disagreements with tests, code reads, or explicit user constraints. Model consensus never overrides failing tests, compiler errors, or specs.

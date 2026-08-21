---
name: git-ssh-identity
description: Configures developer identity for git and GitHub on macOS - git config defaults, ed25519 SSH key in Apple Keychain, gh auth, SSH commit signing, includeIf work/personal identities, global gitignore. Use for "set up git", "SSH key for GitHub", "sign commits", "passphrase asked every time", "separate work and personal git email". Not for installing git/gh, branching workflows, or repo settings.
---

# Git & SSH Identity

Sets up who-you-are for git: identity, keys, auth, signing, and the config
defaults core git developers actually use. Owns `~/.gitconfig` (via
`git config --global`, inherently idempotent) and `~/.ssh/config`'s GitHub
block.

## When NOT to use

- Git workflows (rebase, merge, commit messages) → native competence
- Installing git/gh binaries → `dev-cli-tools`
- Repo-side settings (branch protection, secrets) → not a machine-setup task
- Touch ID / FileVault → `macos-security-baseline`

## Safety rails

- **Never overwrite an existing key.** Check `ls ~/.ssh/` first; creating
  over `id_ed25519` destroys access. New purpose → new filename.
- Passphrases and tokens never appear in chat, files, or command args; auth
  flows are browser-based (`gh auth login`) or interactive (`ssh-keygen`
  prompts).
- Ask for the user's real name/email — never invent or reuse placeholder
  identity values.
- Existing `user.email`/`user.name` present? Show current values and confirm
  before changing.

## Workflow

### 1. Identity + config defaults

```sh
git config --global user.name  "<ask the user>"
git config --global user.email "<ask the user>"

git config --global init.defaultBranch main
git config --global fetch.prune true
git config --global rebase.autoStash true
git config --global push.autoSetupRemote true      # git >= 2.37; kills --set-upstream dance
git config --global rerere.enabled true
git config --global merge.conflictstyle zdiff3     # git >= 2.35
git config --global diff.colorMoved plain
git config --global branch.sort -committerdate
git config --global column.ui auto
git config --global help.autocorrect prompt
# Editor: ASK which editor the user has, verify the command exists, then e.g.:
command -v code >/dev/null && git config --global core.editor "code --wait"
# Workflow choice, not universal - ask if the team merges on pull:
git config --global pull.rebase true
```

Rationale per key: [references/git-config.md](references/git-config.md).

### 2. Global gitignore

Never truncate an existing file — append only missing entries:

```sh
[ -f ~/.gitignore_global ] && cp ~/.gitignore_global ~/.gitignore_global.bak.$(date +%Y%m%d%H%M%S)
for e in .DS_Store '*.swp' .env node_modules/ __pycache__/ .venv/ .idea/ .vscode/; do
  grep -qxF "$e" ~/.gitignore_global 2>/dev/null || echo "$e" >> ~/.gitignore_global
done
git config --global core.excludesfile ~/.gitignore_global
```

### 3. SSH key + Apple Keychain

First inspect what already exists — both keys and effective config:

```sh
ls ~/.ssh/id_* 2>/dev/null                          # existing keys? pick ONE with the user
ssh -G github.com | grep -Ei '^(identityfile|identityagent)'   # existing config/1Password agent?
```

If `ssh -G` shows a 1Password `IdentityAgent` or an existing github.com
block pointing at another key, **stop and merge deliberately** (edit that
block with the user) — appending a second `Host github.com` block does not
override the first. 1Password users skip key generation entirely (its
agent + `op-ssh-sign` handle auth and signing; configure per its docs).

Otherwise, settle on ONE key path and use it consistently everywhere
below (existing key → reuse; new: only into a free filename):

```sh
KEY=~/.ssh/id_ed25519                     # the agreed path - substitute throughout
[ -f "$KEY" ] || ssh-keygen -t ed25519 -C "<email>" -f "$KEY"   # SET A PASSPHRASE
```

Wire agent + Keychain so the passphrase is asked **once ever**
(`~/.ssh/config`; back the file up first if it exists):

```
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile <the agreed KEY path>
```

```sh
/usr/bin/ssh-add --apple-use-keychain "$KEY"
```

Use Apple's `/usr/bin/ssh-add` — Homebrew/other OpenSSH builds don't have
`--apple-use-keychain`. After reboot the agent is empty but the config block
reloads the key transparently on first use.

### 4. GitHub auth

```sh
gh auth login        # browser flow; SSH protocol; can create+upload the key for you
gh auth status
ssh -T git@github.com   # expect: "Hi <user>! You've successfully authenticated..."
```

No gh? `pbcopy < ~/.ssh/id_ed25519.pub` → GitHub → Settings → SSH and GPG
keys → New SSH key (type: **Authentication**). First `ssh -T` shows a host
fingerprint prompt — verify against GitHub's published fingerprints page
before typing yes.

### 5. SSH commit signing (opt-in — Verified badge)

An **explicit choice**, not a default: global `commit.gpgsign` makes every
commit fail if the key/agent is unavailable. Confirm the user wants it
(and check nothing is configured already: `git config --global
--get-regexp '^(gpg|commit\.gpgsign|tag\.gpgsign)'`).

```sh
git config --global gpg.format ssh
git config --global user.signingkey "$KEY.pub"    # the agreed key from step 3
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

**Upload the same public key a second time** on GitHub with type
**Signing** (`gh ssh-key add "$KEY.pub" --type signing`) — authentication
and signing entries are separate; skipping this leaves commits
"Unverified".

Local verification needs an allowed-signers file (idempotent; use the
identity email from step 1, not directory-dependent `git config`):

```sh
LINE="<email from step 1> $(cat "$KEY.pub")"
grep -qxF "$LINE" ~/.ssh/allowed_signers 2>/dev/null || echo "$LINE" >> ~/.ssh/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```

Test: commit in a scratch repo, `git verify-commit HEAD` / `git log
--show-signature -1`. Requires git ≥ 2.34 (SSH signing) — CLT git qualifies.

### 6. Work/personal identity split (when asked)

```ini
# ~/.gitconfig
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work
[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal
```

Each included file sets its own `user.email` (and optionally signingkey).
The trailing `/` matches the tree recursively. Remote-based alternative
(git ≥ 2.36): `[includeIf "hasconfig:remote.*.url:git@github.com:acme/**"]`.
Verify from inside each tree: `git config user.email`.

### 7. Verify

```sh
sh "${CLAUDE_SKILL_DIR}/scripts/check.sh"
```

## Output spec

Done means: the managed keys read back correctly —

```sh
git config --global --show-origin --get-regexp \
  '^(user\.(name|email|signingkey)|init\.defaultbranch|core\.(editor|excludesfile)|gpg\.|commit\.gpgsign|tag\.gpgsign)'
```

(targeted query, not `--list` — a full dump can expose credential-bearing
URLs into the transcript) — `ssh -T git@github.com` prints the "Hi
<user>!" greeting (**exit code 1 is the success case**), a signed test
commit verifies locally (if signing was chosen), the passphrase survives
a new shell, and no existing key or config block was touched without
consent.

## Gotchas

- "permission denied (publickey)" with a working key usually = key not
  loaded (run the ssh-add line) or the repo remote uses HTTPS while auth
  was set up for SSH (`git remote -v` to check).
- Signing on but key not uploaded as **Signing** type → GitHub shows
  Unverified; the auth entry does not count.
- `UseKeychain` on a passphrase-less key errors on some setups — omit it
  then (but keys should have passphrases).
- Two **GitHub accounts** (not just two emails) need more than includeIf:
  per-account keys + `Host github-work` aliases with `IdentitiesOnly yes`
  and matching remote URLs — say so instead of half-configuring it.
- `gh auth login`'s token normally lands in the macOS keychain but can
  fall back to a plaintext `~/.config/gh/hosts.yml` — promise the browser
  flow (no pasted tokens), not a storage guarantee.
- CLT git lags upstream slightly (updates only with Xcode releases). Fine
  for everything here; `brew install git` if newer features are needed —
  brew's PATH position shadows it automatically.

# Git config defaults — rationale and version gates (verified 2026-08-17)

Sources: git-scm.com/docs/git-config; docs.github.com (SSH + signing);
Apple's shipped `ssh_config`/`ssh-add` man pages; Scott Chacon, "How Core
Git Developers Configure Git" (GitButler blog, Feb 2025).

## The defaults, one line each

| Key | Value | Why | Since |
|---|---|---|---|
| `init.defaultBranch` | `main` | matches every modern host's default | 2.28 |
| `fetch.prune` | `true` | deleted remote branches stop haunting autocomplete | — |
| `rebase.autoStash` | `true` | `git pull --rebase` works with a dirty tree | — |
| `push.autoSetupRemote` | `true` | first push just works, no `--set-upstream` | **2.37** |
| `rerere.enabled` | `true` | resolve the same conflict once, git replays it | — |
| `merge.conflictstyle` | `zdiff3` | conflict hunks show the base too — far easier calls | **2.35** |
| `diff.colorMoved` | `plain` | moved lines colored differently from add/delete | — |
| `branch.sort` | `-committerdate` | `git branch` lists most-recent first | — |
| `column.ui` | `auto` | columnar branch/tag listings | — |
| `help.autocorrect` | `prompt` | typo'd subcommands offer the fix instead of guessing | — |
| `core.excludesfile` | `~/.gitignore_global` | machine-wide ignores (.DS_Store) out of repo files | — |
| `core.editor` | `code --wait` | `--wait` blocks until the editor closes the file | — |
| `pull.rebase` | `true` | **workflow choice** — ask; merge-on-pull teams omit it | — |

Also defensible (from the same article, add on request): `commit.verbose
true`, `push.followTags true`, `fetch.pruneTags true`, `rebase.updateRefs
true`, `core.untrackedCache true`, `core.fsmonitor true` (big repos),
`git maintenance start` (schedules hourly prefetch via launchd on macOS).

## SSH key + Keychain (GitHub's documented flow)

- Key type: **ed25519** (`ssh-keygen -t ed25519 -C "email"`); RSA 4096 only
  for legacy systems. Use a passphrase; the Keychain caches it.
- `~/.ssh/config` block (GitHub docs verbatim shape):
  `Host github.com` + `AddKeysToAgent yes` + `UseKeychain yes` +
  `IdentityFile ~/.ssh/id_ed25519`.
- `/usr/bin/ssh-add --apple-use-keychain <key>` stores the passphrase in
  Keychain (Apple's ssh-add only; pre-Monterey spelling was `-K`).
  `--apple-load-keychain` reloads all; normally unnecessary because
  `AddKeysToAgent` + `UseKeychain` auto-load on first use — including after
  reboot.
- macOS runs ssh-agent via launchd (`SSH_AUTH_SOCK` preset); `eval
  "$(ssh-agent -s)"` is only for odd environments.
- Test: `ssh -T git@github.com` → `Hi USER! You've successfully
  authenticated, but GitHub does not provide shell access.`
- Host fingerprints (SHA256, verify on first connect): Ed25519
  `+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU`; ECDSA
  `p2QAMXNIC1TJYWeIOttrVc98/R1BUFWu3/LiyKgUfQM`; RSA
  `uNiVztksCsDhcc0u9e8BujQXVUpKZIDTMczCvj3tD2s`
  (docs.github.com "GitHub's SSH key fingerprints" — check there for
  rotations).

## SSH commit signing

- Requires git ≥ 2.34. Config: `gpg.format ssh`, `user.signingkey
  <path>.pub` (public path when the agent holds the private key),
  `commit.gpgsign true`, `tag.gpgsign true`.
- GitHub needs the key uploaded **twice** for both roles: once as
  Authentication, once as **Signing** (`gh ssh-key add key.pub --type
  signing`). GitHub docs: "If you want to use the same SSH key for both
  authentication and signing, you need to upload it twice."
- Local verify: `gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers`; line
  format `principal(,principal...) [options] keytype base64key`, e.g.
  `dev@example.com ssh-ed25519 AAAA...`. Without the file,
  `git verify-commit` fails with undefined trust.
- SSH vs GPG: SSH signing reuses the existing key + agent + Keychain; GPG
  needs gpg-agent + pinentry glue on macOS. Choose GPG only when policy
  requires OpenPGP.
- 1Password variant: `[gpg "ssh"] program =
  "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"` + its SSH
  agent; keys live in 1Password, Touch ID gates each signature.

## Multiple identities

- `includeIf "gitdir:~/work/"` — trailing `/` auto-appends `**` (recursive);
  no leading `~/`,`./`,`/` → `**/` is prepended. Case-insensitive variant
  `gitdir/i:`. `onbranch:` exists too.
- `includeIf "hasconfig:remote.*.url:<glob>"` — routes by remote URL
  (git ≥ 2.36); included files may not themselves set remote URLs.
- Debug: `git config --show-origin user.email` inside each tree shows which
  file won.

## gh CLI

- `gh auth login` — browser flow; choosing SSH protocol offers to generate/
  upload a key (`--skip-ssh-key` to opt out). `gh auth status` verifies.
- `gh auth setup-git` — makes gh the HTTPS credential helper (only needed
  for HTTPS remotes).
- `gh ssh-key add <file> --title <t> --type authentication|signing`.

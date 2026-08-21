# Curator cross-validation report

Generated: 2026-08-17T00:55:25Z
Subject: REVISED skill-catalog split v2 (18 skills) for macOS-dev-setup Agent Skills repo — round 2 after addressing BLOCK findings
Kind: plan

## Aggregate

BLOCK — BLOCK from openai.

## Provider status

- **openai** `gpt-5.6-sol`: ok (125.6s; verdict=BLOCK, confidence=0.96, tokens=9223)

## openai — gpt-5.6-sol (round 1)

## Verdict
Verdict: BLOCK — the catalog still lacks a coherent ownership/dependency contract, executable umbrella semantics, and measurable routing criteria, leaving material data-loss and orchestration risks unresolved.

## Strongest objections
1. **Shared-state ownership remains contradictory.** Both `homebrew-setup` and `dotfiles-setup` may run `brew bundle dump --force`, which can overwrite a curated or tracked Brewfile. Running dotfiles last can also replace `.zshrc`, `.zprofile`, `.gitconfig`, editor settings, and files just configured by earlier skills. “Owned via `git config --global`” is not safe ownership: it can overwrite existing personal/work identities.  
   **Fix:** define one writer per exact path or configuration key, with other skills limited to proposing changes. Separate generated inventory from declarative input, e.g. `Brewfile.generated`, and never use `--force` by default. Give dotfiles explicit `adopt`, `deploy`, and `audit-only` modes.

2. **The umbrella is not safely “minimal.”** Its mandatory sequence includes system updates, security changes, runtimes, macOS defaults, an editor, and dotfiles—all preference-specific or potentially disruptive. Rosetta is not universally required, and applying dotfiles after configuration can undo prior work.  
   **Fix:** make the umbrella discovery-and-plan first. Inventory existing state, resolve dependencies and conflicts, show the complete mutation plan, and require explicit selection of every track, including the proposed core. No security, update, defaults, or dotfiles mutation should be implicit.

3. **Orchestration cannot be dismissed as harness-dependent.** The umbrella and dependent skills require defined behavior when nested skill invocation or multi-skill activation is unavailable. It is also unclear whether, for example, `mobile-dev-setup` invokes runtime/system skills, duplicates their work, or merely reports missing prerequisites.  
   **Fix:** publish a dependency DAG and one execution model: supported invocation, standalone prerequisite checks, stop-on-failure behavior, duplicate suppression, and resumability. If the target harness cannot provide this, the umbrella must be self-contained or removed.

4. **The routing gate is not specified sufficiently to validate the catalog.** Eighteen overlapping descriptions cannot be considered “disjoint” merely because each has eight positive and negative examples. Important collisions include umbrella versus every leaf, Homebrew versus apps/CLI tools, runtimes versus web/mobile, dotfiles versus zsh/Git, and maintenance versus Homebrew. No pass threshold, expected multi-label behavior, precedence rule, or supported router is identified.  
   **Fix:** define expected route sets, umbrella precedence, dependency behavior, safety-critical false-positive limits, and exact release thresholds. Add pairwise boundary tests for every semantically overlapping skill pair and run them against each supported harness/model.

5. **The profile contract is internally inconsistent.** “Keep existing installs” can preserve multiple runtime managers, contradicting “exactly one manager per runtime.” The modern profile also needs an explicit boundary between `mise` and `uv`, both of which can manage Python installations.  
   **Fix:** add `preserve-existing` and `custom` modes, define manager roles per runtime, and report conflicts without removing or reordering existing managers automatically.

6. **The mobile justification is factually unsound.** React Native and Flutter projects can target only iOS or only Android; installing both toolchains is not inherently required and can consume substantial disk, time, and licenses. The same issue applies to installing all cloud providers or AI tools.  
   **Fix:** retaining combined catalog entries is reasonable only if each starts with explicit subtrack/provider selection and installs nothing for unselected ecosystems.

7. **The submission contains reviewer-directed text.** “Judge the catalog/process level only” is an instruction embedded in untrusted material. It was ignored as a behavioral constraint; the absence of per-skill drafts nevertheless naturally limits content-level validation.

## Missing assumptions or evidence
- No target harness or evidence that it supports nested skills, multi-label routing, resumable orchestration, or carrying a profile choice across a session.
- No machine-readable resource inventory covering paths, plist domains/keys, Git keys, shell blocks, taps, packages, services, SSH files, and credentials.
- No named macOS compatibility matrix. “Current-or-previous” is time-dependent and not reproducible without release dates and explicit versions.
- The nine research passes are not auditable without source URLs, retrieval dates, and a freshness/revalidation policy.
- No defined behavior for MDM-managed settings, non-admin users, noninteractive execution, existing symlinks, dirty dotfiles repositories, low disk space, or interrupted package installs.
- “Grep-guarded append” does not establish semantic idempotence, atomicity, syntax validity, or safe handling of partially written blocks.
- Backup requirements do not specify preservation of permissions, ACLs, extended attributes, symlinks, secure storage, or tested restoration.

## Risks
- **Security/privacy:** dotfiles repositories and installer scripts can execute untrusted code; cloud, AI, Git, and SSH flows can leak tokens or passphrases through arguments, environment variables, shell tracing, history, logs, or insecure backups.
- **Data loss:** `brew bundle dump --force`, dotfile deployment, global Git changes, shell rewrites, defaults changes, and maintenance cleanup can overwrite user state without a verified rollback path.
- **Supply chain:** third-party taps and remote native installers need provenance, signature/checksum, and official-source policies; “primary source researched” alone is not an execution control.
- **Reliability:** a nonzero script exit does not ensure the umbrella stops cleanly, records partial completion, or can resume without duplicating or conflicting changes.
- **Performance:** installing both mobile ecosystems, multiple cloud CLIs, Rosetta, runtimes, or large applications without selection and disk-space checks can add tens of gigabytes and substantial setup time.
- **Maintainability:** duplicating safety and scope text across 18 skills will drift unless generated from or checked against a canonical versioned contract.

## Validation
- Create a catalog manifest listing each skill’s routes, prerequisites, writes, privileged actions, destructive actions, secrets, rollback, and restart requirements. CI must reject conflicting exclusive writers and undeclared mutations.
- Build a router confusion suite containing:
  - leaf-versus-umbrella prompts;
  - every overlapping pair;
  - compositional and exclusion prompts;
  - provider/subtrack-specific prompts such as “React Native for iOS only,” “install AWS CLI only,” “restore dotfiles containing Git and zsh config,” and “update Homebrew packages.”
- Define exact-match expected route sets and require zero unexpected activation of privileged/destructive skills.
- On clean and preconfigured snapshots for each supported macOS/architecture combination, verify:
  1. denied consent causes no mutation;
  2. first run reaches declared postconditions;
  3. second run produces no diff;
  4. injected failure after each step stops later steps;
  5. resume completes safely;
  6. rollback restores hashes, modes, ACLs, xattrs, and symlinks.
- Inventory dangerous commands before release:
  ```sh
  rg -n 'sudo|fdesetup|spctl|softwareupdate.*--install|rm[[:space:]]+-rf|brew bundle dump.*--force|curl.*\|.*sh' skills scripts
  ```
  Every match should map to a declared safety action and consent test.
- Validate generated files with appropriate parsers, including `zsh -n`, `plutil -lint`, temporary-`HOME` Git tests, and `brew bundle check --file`.
- Inject fake credentials and scan stdout, stderr, histories, generated files, backups, and logs to prove secrets are not retained.
- Test mobile/cloud/AI subtrack selection and confirm unselected toolchains produce no downloads or state changes.

## Minimal revision
1. Add a versioned catalog contract and machine-readable ownership/dependency manifest with exact resources, prerequisite behavior, rollback, and one-writer rules.
2. Change the umbrella to inventory → proposed plan → explicit track selection → execution; remove the unconditional core and define harness, stop, resume, and dependency semantics.
3. Make one skill the sole Brewfile writer, use a separate generated inventory file, and prohibit default `--force`; add explicit dotfiles modes.
4. Specify router labels, precedence, multi-label expectations, supported harnesses, and quantitative release thresholds before writing bodies.
5. Add `preserve-existing`/`custom` profiles and explicit mobile, cloud, and AI subtrack selection.
6. Centralize the safety contract, including atomic writes, secure backups, diff/confirm/validate/rollback, symlink and MDM handling, supply-chain controls, and secret-safe authentication.

```json
{"verdict":"BLOCK","confidence":0.96,"summary":"The split is plausible, but unresolved state ownership, unsafe umbrella defaults, and undefined orchestration and routing contracts make authoring against it premature.","top_issues":["Brewfile and dotfiles have conflicting writers","Umbrella performs disruptive preference-specific work by default","Harness and dependency orchestration semantics are undefined","Routing gate lacks labels, precedence, thresholds, and multi-skill expectations","Profile and mobile subtrack assumptions are inconsistent"]}
```

## Curation instructions for Claude

Use this report as critique, not authority. Accept findings only when supported by evidence or cheap to mitigate; resolve disagreements with tests, code reads, or explicit user constraints. Model consensus never overrides failing tests, compiler errors, or specs.

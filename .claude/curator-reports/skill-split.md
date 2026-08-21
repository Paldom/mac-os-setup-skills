# Curator cross-validation report

Generated: 2026-08-17T00:51:06Z
Subject: Skill-catalog split for a macOS-dev-setup Agent Skills repo: 17 single-purpose skills incl. umbrella orchestrator; owner-stack-vs-2026-modern presentation choice
Kind: plan

## Aggregate

BLOCK — BLOCK from openai.

## Provider status

- **openai** `gpt-5.6-sol`: ok (127.6s; verdict=BLOCK, confidence=0.97, tokens=8797)

## openai — gpt-5.6-sol (round 1)

## Verdict
Verdict: BLOCK

The catalog does not yet satisfy its own single-purpose and routing constraints, and it lacks a safe composition model for privileged, destructive, and stateful operations.

## Strongest objections

1. **There is no execution-safety contract.** Several skills may modify PAM/sudo, enable FileVault, alter firewall settings, overwrite shell and Git configuration, generate credentials, upgrade databases, or restart the OS. An LLM agent must not perform these merely because a setup skill matched. Define dry-run behavior, explicit confirmation gates, backups, rollback instructions, secret-redaction rules, and operations that are manual-only. FileVault recovery material and authentication tokens must never enter prompts, logs, dotfiles, or repository state.

2. **The skills have conflicting ownership of shared state.** `zsh-setup`, CLI tools, runtimes, mobile tools, cloud tools, and dotfiles all need to modify PATH or shell startup files. Homebrew, apps, editors, and CLI tools all potentially modify a Brewfile. Without a composition contract, reruns will duplicate lines, reorder PATH, overwrite user configuration, or create competing sources of truth. Assign one owner for each shared file and use idempotent managed blocks or sourced snippets; define how component package declarations are aggregated.

3. **The proposed split violates the stated single-purpose constraint.** The clearest offenders are:
   - `macos-system-prep`: prerequisites plus unrelated security hardening.
   - `language-runtimes`: three independent ecosystems and competing managers.
   - `mobile-dev-setup`: Apple, Android, React Native, and Flutter.
   - `cloud-dev-setup`: three clouds, Databricks, and Kubernetes.
   - `mac-maintenance`: OS, package manager, App Store, and stateful runtime upgrades.

   Split independent user goals, or explicitly weaken the constraint to permit parameterized variants of one operation. Do not claim compliance while retaining this structure.

4. **Routing correctness is unproven and the umbrella semantics are unresolved.** The proposed summaries are not final 150–400 character router descriptions, and there is no confusion matrix. Keep an umbrella only if the router needs it for explicit whole-machine or multi-domain requests. Its description should require phrases such as “new/fresh Mac,” “complete environment,” or a request spanning several areas, and explicitly exclude single-area work. Whether a router can activate multiple skills is a required design input. Catalog size should be decided from empirical routing results, not an arbitrary target.

5. **“Full setup” is dangerously underspecified.** It must not imply installing every mobile SDK, all cloud CLIs, multiple AI agents, commercial virtualization products, and local databases. Those have substantial storage, licensing, privacy, attack-surface, and authentication implications. Define a minimal core and separately selected tracks; optional tracks must never be transitively installed without consent.

6. **The owner-versus-modern choice is not technically resolved.** `uv`, `mise`, `pyenv`, Poetry, and pipx have overlapping but non-equivalent roles; Starship and Powerlevel10k are mutually exclusive prompts; OrbStack is proprietary and has different licensing and operational tradeoffs from Colima or Docker Desktop. Provide capability and conflict matrices rather than treating “modern” as sufficient evidence. Expose named `owner` and `recommended` profiles, require an explicit profile choice, and prohibit conflicting managers.

7. **The proposed merge candidates would worsen routing and cohesion.** Do not merge Docker into web development, editors into general GUI apps, or CLI configuration into Homebrew bootstrap. Docker and editors are independently requested, while Homebrew is an installation mechanism rather than ownership of every package’s configuration.

## Missing assumptions or evidence

- Supported macOS releases, Apple Silicon versus Intel behavior, Homebrew prefixes, and whether Rosetta is installed only when an x86 dependency is detected.
- Whether targets may be MDM-managed, lack administrator access, be offline, or already contain user configuration.
- Whether skills execute commands, produce a plan, or both, and which operations always require interactive approval.
- Whether the target agents can select multiple skills for a multi-intent prompt.
- A dependency graph for direct component invocation; for example, how a CLI skill handles missing Homebrew without invoking unrelated setup.
- Official and current distribution sources for every AI/cloud CLI, including checksums, package identities, support status, and licensing. Unofficial packages must not be recommended implicitly.
- Evidence behind the 2026 recommendations and a review policy for maintenance-status claims.
- Data migration and backup behavior for Homebrew-managed PostgreSQL or Redis upgrades.
- Storage, bandwidth, Apple ID, App Store, Xcode license, and commercial-license requirements.
- A measurable trigger-evaluation threshold across every supported agent/model.

## Risks

- **Security/privacy:** SSH keys, cloud credentials, AI-agent tokens, FileVault recovery keys, and source-code telemetry could be exposed to transcripts or configuration repositories. Installing many coding agents also expands supply-chain and code-access risk.
- **Data loss:** Dotfile replacement, `brew bundle cleanup`, broad package upgrades, runtime-manager changes, and database major-version upgrades can remove working tools or strand local data.
- **Privilege loss:** Incorrect PAM modification for Touch ID may break `sudo`; macOS updates may replace unsupported changes.
- **Reliability:** `defaults` keys, cask names, App Store identifiers, Xcode/Android SDK requirements, and shell initialization behavior vary by OS release and architecture.
- **Operational disruption:** `softwareupdate`, `mas upgrade`, cask upgrades, and runtime upgrades can restart systems or break active release environments.
- **Maintainability:** Maintaining owner and recommended branches inline in every skill will multiply test combinations and cause documentation drift unless profiles resolve to a single versioned manifest.

## Validation

- Add metadata tests that enforce folder/name agreement, one-line 150–400 character descriptions, body length under 500 lines, required exclusions, and unique names.
- Build a routing corpus with positive, nearest-neighbor negative, ambiguous, and multi-intent prompts. Include at least:
  - “Set up my fresh Mac” → umbrella.
  - “Install Xcode command line tools” → prerequisites, not mobile.
  - “Install full Xcode and a simulator” → Apple mobile.
  - “Change my Dock behavior” → preferences, not system preparation.
  - “Install VS Code” → editor, not GUI apps or Homebrew.
  - “Install ripgrep” → CLI tools, not Homebrew bootstrap.
  - “Update my brew packages” → maintenance, not Homebrew setup.
  - “Set up Python with uv” → Python runtime, not umbrella.
- Run routing tests against every supported agent/model and publish a confusion matrix. Require high positive recall and zero or near-zero umbrella theft on single-area prompts.
- Test each profile in disposable macOS VMs on every supported architecture and OS family: fresh account, preconfigured account, interrupted run, denied-admin run, and second run. The second run should produce no unintended changes.
- Use `shellcheck` and syntax checks for scripts; verify all download origins, package names, signatures/checksums where available, and absence of unreviewed `curl | sh` flows.
- Diff `.zprofile`, `.zshrc`, Git configuration, SSH directories, Brewfiles, and affected system files before and after execution. Existing unmanaged content and key files must survive.
- Verify state with non-secret commands such as `brew doctor`, `brew bundle check`, `git config --show-origin --list`, `fdesetup status`, runtime-manager diagnostics, `docker info`, `xcodebuild -version`, and Android SDK listings.
- Confirm local databases bind only to intended interfaces and test backup/restore plus major-version migration before allowing automated upgrades.
- Add repository secret scanning and tests proving that auth commands, debug output, and generated files never capture tokens, private keys, or recovery material.

## Minimal revision

1. Define a minimal core plus explicit optional tracks; the umbrella orchestrates only user-selected tracks and never means “install everything.”
2. Keep the umbrella, but restrict it to explicit fresh-machine or multi-domain prompts and validate that restriction with trigger tests.
3. Do not perform the proposed merges. Split prerequisites from security hardening, split runtimes by ecosystem, and split Apple/Android mobile concerns and independent cloud providers; defer unsplit optional skills if necessary.
4. Establish exclusive ownership and idempotent update rules for shell files, Brewfiles, Git configuration, and dotfiles.
5. Add default dry-run behavior, confirmation and rollback rules, manual-only privileged steps, and strict secret-handling requirements.
6. Publish `owner` and `recommended` profiles with a conflict matrix and explicit selection; do not silently choose tools based on “modern” labeling.
7. Finalize descriptions and pass cross-model routing, rerun, architecture, and failure-injection tests before publishing.

```json
{"verdict":"BLOCK","confidence":0.97,"summary":"The proposed catalog is not safe or internally consistent until routing, skill boundaries, shared-state ownership, profile selection, and privileged-operation safeguards are defined and validated.","top_issues":["No safety model for privileged or destructive actions","Skills conflict over shell files, Brewfiles, and dotfiles","Several skills violate the single-purpose constraint","Umbrella routing and multi-intent behavior are unproven","Full setup could install excessive optional and commercial tooling","Owner and recommended stacks lack an explicit conflict-free profile model"]}
```

## Curation instructions for Claude

Use this report as critique, not authority. Accept findings only when supported by evidence or cheap to mitigate; resolve disagreements with tests, code reads, or explicit user constraints. Model consensus never overrides failing tests, compiler errors, or specs.

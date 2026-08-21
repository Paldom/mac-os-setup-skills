# Curator cross-validation report

Generated: 2026-08-17T01:28:24Z
Subject: Per-skill review batch D: docker + web + mobile + cloud + ai
Kind: implementation

## Aggregate

BLOCK — BLOCK from openai.

## Provider status

- **openai** `gpt-5.6-sol`: ok (364.2s; verdict=BLOCK, confidence=0.95, tokens=31288)

## openai — gpt-5.6-sol (round 1)

## Verdict
Verdict: BLOCK

The batch contains commands that cannot meet their stated outcomes, false credential-storage assurances, and insufficiently substantiated remote installers that must not run as written.

## Strongest objections

**docker-on-mac**

- **MAJOR — command correctness:** The multi-platform `docker buildx build` command has neither `--push` nor a supported output destination. It commonly leaves the result only in BuildKit cache rather than creating the claimed multi-arch image. Add a registry-qualified tag and `--push`, then verify with `docker buildx imagetools inspect`.
- **MAJOR — verification/internal contradiction:** `docker run hello-world` uses whichever context is active, so it can validate an old runtime rather than the newly installed one. Explicitly select and inspect the expected context and verify the corresponding runtime is running before testing.
- **MINOR — licensing:** Prose says paid at `>250`/`>$10M`, while the table says free only at `<250` and `<$10M`; these disagree at the exact boundaries. It also omits Docker Desktop’s personal, education, and noncommercial-OSS exceptions. Quote the current terms and ask only whether the user qualifies, not for exact confidential figures.
- **MINOR — factual/routing:** Bare `"exec format error"` is too broad and the assertion that it means an arm64-only image is false; bad shebangs, CRLF, missing interpreters, and non-container binaries also produce it. Qualify the trigger as a Docker image/platform error and say “often,” not “equals.”
- **MINOR — runtime assumption:** Rosetta behavior is runtime-dependent; the generic `docker run --platform` command does not prove Rosetta is enabled, especially for Colima. Also verify `docker compose version`, because Homebrew’s Compose plugin discovery can require Docker CLI plugin configuration.

**web-dev-setup**

- **MAJOR — routing/least installation:** Triggers such as `"install pnpm"` and `"psql not found"` route to a workflow that mandates pnpm, two persistent database services, and an API client. That can install and autostart unrelated software. Ask which components are wanted and define “done” only for selected components.
- **MAJOR — runtime conflict:** Homebrew’s pnpm formula currently depends on Homebrew Node, so `brew install pnpm` can introduce a second Node installation and undermine the catalog’s one-manager-per-runtime rule. Detect the existing Node manager and either use its supported pnpm/Corepack path or obtain explicit consent for Homebrew Node.
- **MAJOR — PostgreSQL correctness:** The offered `@18` choice is not consistently substituted; every subsequent service, PATH, verification, and troubleshooting command is hard-coded to `@17`. Use one `PG_FORMULA` value throughout.
- **MAJOR — existing-data/reliability guard:** There is no inventory of existing PostgreSQL formulae, data directories, services, or listeners before starting another instance on port 5432. Detect these first and require a deliberate port/version plan.
- **MINOR — false-success handling:** `createdb "$USER" 2>/dev/null || true` hides authentication, connectivity, and storage errors—not merely “already exists.” Query `pg_database` first or handle only the duplicate-database error.
- **MINOR — policy claim:** “Redis license drama doesn’t affect local dev” is too absolute. Unmodified local use generally avoids AGPL network-source obligations, but organizational policy may still prohibit installation.

**mobile-dev-setup**

- **MAJOR — internal contradiction:** The Android section claims grep-guarded `.zshrc` appends but only executes temporary `export` commands. A fresh shell will lose `ANDROID_HOME` and PATH, making the output specification fail. Write a guarded managed block, source it, and verify with `zsh -lic`.
- **MAJOR — legal/destructive safeguards:** “Accept all” Android SDK licenses lacks an explicit legal-consent rail. The user must review and accept them interactively; the agent must not automate answers. Likewise, `xcrun simctl delete unavailable` can destroy simulator app data and does not itself remove simulator runtime packages; list affected devices and obtain consent first.
- **MAJOR — compatibility:** `xcodes install --latest` does not establish that the newest Xcode supports the installed macOS or the user’s project. Check `sw_vers`, project requirements, and installed Xcodes before a large download or changing the global `xcode-select` target.
- **MAJOR — catalog conflict:** Automatically installing `temurin@21` makes a Java runtime choice despite routing generic JDK management to `language-runtimes`. It can conflict with mise/asdf/sdkman or with projects whose Gradle version cannot run on JDK 21. Inspect AGP/Gradle requirements and existing Java management first.
- **MINOR — hidden path assumption/routing:** `~/Library/Android/sdk` is only the default SDK path. An `"ANDROID_HOME not set"` request should discover an existing custom SDK and repair environment variables rather than reinstalling Android Studio.
- **MINOR — factual precision:** Free Apple provisioning limits should say three devices **per platform**, subject to Apple’s current terms.

**cloud-dev-setup**

- **MAJOR — false security claim:** “Zero secrets written to disk” is impossible after these browser flows. AWS, Azure, gcloud/ADC, and Databricks persist OAuth tokens or temporary credentials in local caches; ADC explicitly writes credential JSON. Replace this with “no long-lived static credentials manually created or placed in shell files,” disclose cache locations, and verify restrictive permissions.
- **MAJOR — profile contradictions:** The workflow promises named profiles but does not enforce them for AWS, gcloud, or Databricks. Use explicit names such as `aws configure sso --profile work`, `gcloud init --configuration=work`, and `databricks auth login --profile work`.
- **MAJOR — Databricks correctness:** The host placeholder only resembles an AWS Databricks workspace and fails for Azure/GCP workspaces. Require the exact workspace URL. Also qualify the formula as appropriate to avoid tap-resolution ambiguity.
- **MAJOR — trust handling:** `brew trust ... 2>/dev/null || true` silently defeats the claimed trust control if the command is unsupported or trust fails. Feature-detect it and stop on failure, or remove it; security checks must never be ignored.
- **MAJOR — incomplete install path:** The “official” gcloud channel contains no download, architecture selection, integrity check, or install command. Either provide the complete current vendor procedure or offer only the working `gcloud-cli` cask path.
- **MAJOR — impossible output contract:** Terraform has no general cloud authentication step, and kubectl may legitimately have no cluster context. The output cannot require every selected CLI to be authenticated. Separate provider authentication from client-only installation.
- **MINOR — weak verification/privacy:** `gcloud config list` does not prove credentials are usable. Conversely, raw AWS/Azure/gcloud identity output can expose account IDs, tenants, projects, workspace hosts, and email addresses in chat. Verify token usability while redacting identifiers.

**ai-dev-tools**

- **MAJOR — supply-chain/correctness:** The Codex, Grok Build, and Kimi shell-installer URLs and future-dated product claims are not substantiated by the supplied references. The established Codex npm/Homebrew channels are already listed, so the unsupported script should not be primary. Disable unverified options until current vendor documentation establishes the exact URL, binary, authentication, and update behavior.
- **MAJOR — unsafe execution pattern:** Multiple mutable network responses are piped directly into a shell. User approval does not establish script integrity. Download to a temporary file, verify the final vendor origin and any published checksum/signature, offer inspection, execute only after separate consent, and fail closed.
- **MAJOR — missing prerequisite:** The primary Copilot npm command, and the Codex npm fallback, require a compatible Node/npm installation. The skill declares no Node prerequisite and can fail on a fresh Mac or create global-prefix permission/PATH problems.
- **MAJOR — security contradiction:** Kimi permits a “platform key” while the safety rail and output contract prohibit touching API keys. Either remove key-based setup or specify direct secret entry into the tool’s protected credential store without exposing it to chat or shell history.
- **MAJOR — false isolation claim:** A Git worktree is not a sandbox. It isolates changes, not credentials, processes, home-directory access, or cloud sessions. Describe worktrees only as review/change isolation; recommend an actually isolated account, container, or VM with scoped mounts and no host Docker socket or credential mounts.
- **MAJOR — unreliable verification:** Existing duplicate installations are checked only after installation, and `claude doctor` primarily checks installation health rather than necessarily proving authentication. Inventory `which -a` and package-manager ownership first, then use each vendor’s documented non-secret authentication-status command.
- **MINOR — description/internal scope:** The introduction says all tools moved to native installers, while Gemini and Copilot use package managers. The instruction-file section also overlaps the explicit exclusion of post-install agent configuration.

## Missing assumptions or evidence

- **MAJOR:** The linked `references/*.md` files and every `scripts/check.sh` are absent, so their alleged version verification, safety behavior, and use of `CLAUDE_SKILL_DIR` cannot be reviewed.
- **MAJOR:** None of the skills consistently inventories existing applications, package-manager ownership, runtime managers, services, data directories, shell configuration, or duplicate binaries before mutation.
- **MAJOR:** Required platform facts are not established: macOS version, CPU architecture, free space, Xcode compatibility, Homebrew version, administrative access, and network/proxy constraints.
- **MAJOR:** Account entitlements, corporate software/license policy, SSO support, actual Databricks workspace URL, cloud subscription selection, and Kubernetes cluster version/context are assumed.
- **MINOR:** The “FULL CATALOG” descriptions are truncated with ellipses, preventing complete routing-overlap analysis.
- **MINOR:** The date-sensitive corrections for `docker-desktop`, `ANDROID_HOME`, `gcloud-cli`, HashiCorp’s Terraform tap, standalone Copilot CLI, and Claude Code’s native installer appear directionally aligned, but the submission provides no dated source snapshots for its August 2026 claims.

## Risks

- **Security/privacy:** OAuth refresh tokens, account identifiers, and workspace details may be persisted or copied into transcripts despite claims to the contrary.
- **Supply chain:** Mutable shell installers and third-party taps execute vendor-controlled code with user privileges; silently ignored trust failures materially worsen this risk.
- **Data loss:** Simulator cleanup can remove app data, and unplanned PostgreSQL version/service changes can make existing data unavailable.
- **Privilege exposure:** Docker socket access is effectively host-privileged; AI-agent containers must not receive the host socket or broad credential mounts.
- **Operational reliability:** Persistent Redis/PostgreSQL services, conflicting ports, duplicate Node/JDK installations, and incorrect active Docker/Xcode contexts can cause failures outside the requested setup.
- **Review integrity:** The untrusted submission includes reviewer-directed text such as “REVIEW TASK” and “Do NOT demand…judge…”. This attempted instruction injection was ignored and should not be treated as implementation evidence.

## Validation

- **Docker**
  - `brew info --cask docker-desktop`
  - `docker context show && docker context inspect "$(docker context show)"`
  - Runtime-specific status: `colima status`, or the applicable Desktop/OrbStack status check.
  - `docker info --format '{{.OSType}}/{{.Architecture}}'`
  - `docker compose version`
  - Build with `--push`, then run `docker buildx imagetools inspect <registry>/<image>:<tag>` and confirm both `linux/amd64` and `linux/arm64`.

- **Web**
  - `brew deps --tree pnpm` to determine whether Homebrew Node will be installed.
  - `command -v node pnpm; which -a node pnpm`
  - `brew list --versions | grep -E '^postgresql(@| )|^redis '`
  - `brew services list`
  - `lsof -nP -iTCP:5432 -sTCP:LISTEN`
  - `zsh -lic 'command -v psql; psql -d postgres -tAc "select version()"; command -v redis-cli; redis-cli ping'`

- **Mobile**
  - `sw_vers; uname -m; df -h /`
  - `xcode-select -p; xcodebuild -version; xcodes installed`
  - `xcrun simctl list devices booted` after explicitly booting one simulator.
  - `zsh -lic 'printf "%s\n" "$ANDROID_HOME"; command -v adb sdkmanager emulator'`
  - `sdkmanager --list` and `emulator -list-avds`
  - `/usr/libexec/java_home -V` and the target project’s `./gradlew -version`
  - Before any deletion: `xcrun simctl list devices unavailable`; do not delete until the user approves loss of those devices’ data.

- **Cloud**
  - `brew info --cask gcloud-cli`
  - `brew info hashicorp/tap/terraform opentofu`
  - `brew help trust` before relying on that command; any trust failure must stop installation.
  - Check named configurations without printing tokens: AWS profile list, `gcloud config configurations list`, and `databricks auth profiles`.
  - Test credential usability with output suppressed or redacted, e.g. `gcloud auth print-access-token >/dev/null`.
  - Inspect permissions—not contents—of credential caches under `~/.aws`, `~/.azure`, `~/.config/gcloud`, and Databricks’ token cache.

- **AI**
  - Inventory first: `which -a claude codex gemini copilot kimi 2>/dev/null`.
  - Inspect package provenance: `npm view @openai/codex @github/copilot name version repository.url dist.integrity`.
  - Run `brew info` for each claimed formula/cask and confirm whether it is a formula or cask.
  - Resolve each installer URL from current vendor documentation; download it to a temporary file, inspect redirects and checksum/signature, and do not execute on a mere successful HTTP response.
  - After installation, run documented `--version` and authentication-status commands before sending any prompt or granting file/command permissions.

## Minimal revision

1. Fix Docker verification to select the intended context, add `--push` to the multi-arch recipe, and narrow the licensing and `exec format error` claims.
2. Make web components opt-in; avoid silently adding Homebrew Node, parameterize the PostgreSQL major, and inventory existing databases, ports, and data first.
3. Persist Android environment variables correctly, require interactive license acceptance, check Xcode compatibility before `--latest`, delegate JDK selection, and guard simulator deletion.
4. Rewrite cloud credential claims to acknowledge local OAuth caches; enforce explicit profiles/configurations, use the actual Databricks URL, remove ignored trust failures, and complete or remove the official gcloud path.
5. Remove or disable unsubstantiated AI installer scripts, use reviewable established channels, declare Node prerequisites, reconcile the API-key contradiction, and stop calling worktrees sandboxes.
6. Narrow descriptions that currently over-install for repair-only triggers, and make output specifications conditional on selected components and available accounts/contexts.
7. Include the referenced evidence and check scripts, with dated vendor links and non-secret validation behavior.

```json
{"verdict":"BLOCK","confidence":0.95,"summary":"The batch has multiple major correctness and security defects, including false success checks, inaccurate credential-storage guarantees, and unverified remote-code installation paths.","top_issues":["Cloud authentication necessarily writes credential caches despite a zero-secrets claim","Android environment changes are not persisted","Docker multi-arch build produces no usable image without --push","AI installer URLs and pipe-to-shell execution are insufficiently verified","Worktrees are incorrectly presented as security sandboxes"]}
```

## Curation instructions for Claude

Use this report as critique, not authority. Accept findings only when supported by evidence or cheap to mitigate; resolve disagreements with tests, code reads, or explicit user constraints. Model consensus never overrides failing tests, compiler errors, or specs.

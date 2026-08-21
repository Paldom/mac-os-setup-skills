# Curator cross-validation report

Generated: 2026-08-17T01:29:03Z
Subject: Per-skill review batch A: orchestrator + system prep + security + defaults
Kind: implementation

## Aggregate

PASS_WITH_CHANGES — PASS_WITH_CHANGES from openai.

## Provider status

- **openai** `gpt-5.6-sol`: ok (420.2s; verdict=PASS_WITH_CHANGES, confidence=0.94, tokens=32851)

## openai — gpt-5.6-sol (round 1)

## Verdict
Verdict: PASS_WITH_CHANGES

The workflows are directionally sound, but major defects can clobber PAM customization, miss CLT updates, misreport failed verification, and lose recoverable user configuration.

## Strongest objections

### `macos-dev-setup`

- **[MAJOR] Final verification is neither conditional nor trustworthy.** It probes Brew, GitHub, Node, Python, and Docker even when those components were trimmed or not selected. The `ssh` and Docker pipelines return `head`’s status, masking failures; successful GitHub SSH authentication itself normally exits 1. `docker run --rm hello-world` may pull and retain an image, so it is not read-only. The `&&` chains also skip later checks, while stderr suppression removes diagnostics. Fix by running only selected-area checks, capturing each command’s status independently, accepting GitHub’s documented no-shell result explicitly, adding SSH timeout/noninteractive options, and using `docker info` unless the user consents to an image pull.

- **[MAJOR] The dotfiles ordering conflates two incompatible operations.** Creating a new dotfiles repository can reasonably happen last, but restoring an existing repository last can overwrite shell, Git, editor, and runtime configuration just created. It contradicts “existing pieces are preserved” and “dotfiles last captures everything.” Inventory must distinguish **restore existing** from **create/adopt new**: restore or merge before modifying owned files; capture a new repository last.

- **[MAJOR] “Safe resumption” and inherited “backup-before-modify” are not true for the submitted skills.** The inventory does not record prior preference values, selected options, PAM customization, or whether FileVault/update work is in progress. The security and defaults defects below make reruns lossy. Qualify this claim until those operations preserve existing state and recognize in-progress states.

- **[MINOR] The claimed disk gate is only a display command.** No threshold or stop condition is defined, and Xcode/simulator installation can require considerably more temporary space than the final app size. Add a real preflight with headroom for each selected heavy track.

- **Routing:** The frontmatter is appropriately restricted to complete-machine setup and explicitly rejects single-area requests; no material catalog trigger theft was found.

### `macos-system-prep`

- **[MAJOR] The CLI update path can leave an installed CLT stale.** `softwareupdate --install --recommended --os-only` excludes CLT updates. Step 3 then sees that `xcode-select -p` succeeds and skips installation, even if Software Update offered a newer CLT. This contradicts the “current CLT” and “no pending recommended updates” completion criteria. Either install all recommended Apple updates or re-list after the OS update and explicitly install any offered CLT update.

- **[MAJOR] Rosetta-translated execution is detected but not made a hard stop.** If the agent continues, later `uname -m` checks classify an Apple Silicon machine as Intel and skip Rosetta while risking Intel Homebrew installation. Check `sysctl.proc_translated`, instruct the user to relaunch a native terminal, and refuse all installation steps until `uname -m` is `arm64`.

- **[MINOR] CLT failure guidance is too categorical.** Major upgrades *can* invalidate CLT; they do not invariably do so. “Invalid active developer path” can also mean a moved/deleted Xcode selection, requiring `xcode-select --switch` or `--reset`, not necessarily CLT deletion and reinstall. Diagnose the selected path before destructive removal.

- **[MINOR][Routing]** “macOS software updates” overlaps `mac-maintenance`. Add an explicit frontmatter exclusion for routine/recurring updates while retaining fresh-install and post-major-upgrade triggers.

### `macos-security-baseline`

- **[MAJOR] The `sudo_local` operation destroys existing PAM customization.** Every run replaces the whole file from Apple’s template, removing entries such as the advertised `pam_reattach`. A fixed `.bak` is overwritten on subsequent runs, and `tee` does not explicitly enforce secure ownership/mode or preserve the file atomically. If the file exists, preserve it and modify only the exact `pam_tid.so` entry after showing a diff. Use a timestamped/no-clobber backup and install the result as `root:wheel` mode `0644`.

- **[MAJOR] Touch ID is treated as mandatory despite unsupported machines and operating modes.** The completion criterion requires Touch ID success, while the caveats admit password-only Macs, clamshell operation, SSH, and `su`. Represent Touch ID as enabled, unavailable, or explicitly deferred; password fallback on an incapable machine must not fail the whole security baseline.

- **[MAJOR] FileVault recovery handling is internally wrong.** With iCloud recovery, the user is not necessarily given a personal recovery key to store, so “either way the recovery secret goes into their password manager” is false. If a personal key is generated, it must be stored immediately in an off-device-accessible password manager—not left as an end-of-orchestration manual task. Also recognize “encryption in progress” rather than requiring an immediate final “On” state on every supported Mac.

- **[MINOR] Firewall state is incompletely assessed.** The skill says “Block all incoming connections” should be off but never checks it. Disabling an existing block-all policy would also conflict with the rail against automated weakening. Check `--getblockall`, preserve/report existing policy, and let the user make an explicit tradeoff.

- **[MINOR][Routing]** “Secure/harden my Mac” overpromises a comprehensive hardening baseline when only three controls are covered. Clarify in frontmatter that this is a basic personal-developer baseline, not CIS, enterprise, privacy, account, or sharing-service hardening.

### `macos-defaults`

- **[MAJOR] The rollback promise does not restore prior state.** `defaults delete <domain> <key>` restores default/absent behavior, not a user’s previous custom value. Clearing Dock pins also loses the exact layout. Snapshot each selected key’s previous value or absence, and separately back up Dock configuration before clearing pins.

- **[MAJOR] Verification contradicts the completion criterion.** Only Finder and screenshot keys are checked, although “done” requires a spot-check for every requested group. Add selected-group checks for Dock, keyboard, save/print panels, and desktop services, and treat mismatches as failures.

- **[MINOR] Apply behavior is incomplete.** Save/print-panel and desktop-services blocks have no effective apply instruction despite the claim that every block does. The Finder restart occurs before the `.DS_Store` writes. Tell users to relaunch affected applications and restart Finder after desktop-services changes; warn against killing Finder during active transfers.

- **[MINOR] Excluding all of `~/Developer` from Spotlight is not a universal developer default.** It can remove useful source/file discovery. Make it an optional performance tradeoff, preferably suggesting exclusion of generated build trees where practical.

- **Routing:** The frontmatter is narrowly scoped and does not materially overlap the app, shell, editor, or security skills.

- **[MINOR][Review integrity]** The submitted context embeds reviewer-directed instructions such as “Do NOT demand…” and “judge the CONTENT.” That is an instruction-in-data attempt and was ignored. Remove reviewer-control language from implementation artifacts or keep it outside the material under review.

## Missing assumptions or evidence

- The referenced `scripts/check.sh` files and `references/verified-defaults.md` were not supplied. Their read-only nature, target-version accuracy, and agreement with these completion criteria cannot be established.
- The orchestrator’s safety depends on sibling skills not included here, especially `dotfiles-setup`, `git-ssh-identity`, and `homebrew-setup`.
- `${CLAUDE_SKILL_DIR}` must be a documented harness variable. Otherwise both verification commands fail; this is not guaranteed by the skill text.
- Preference commands must run as the logged-in console user, not root or a remote automation account, and the machine must not have MDM-enforced preferences.
- FileVault enablement assumes an eligible volume-owner/secure-token account and an off-device recovery method.
- Time-sensitive claims about Homebrew support, Intel Tier 3 timing, Rosetta availability through macOS 27/28, Tahoe screenshot behavior, and Sequoia `spctl` behavior need dated official references. The Homebrew and Rosetta claims appear consistent with announced policy, but the evidence is absent.
- The setup assumes reliable power/network and enough temporary disk space across restarts and large installer expansion, not merely final installed size.

## Risks

- **Security/data loss:** A truncated or customized-overwritten PAM file can block future `sudo`; delayed FileVault key storage can make recovery impossible; preference and Dock changes cannot be restored exactly without snapshots.
- **Privacy:** `ssh -T git@github.com` makes an outbound connection, may disclose account identity in output, tries available identities, and can modify `known_hosts`. It requires explicit relevance and consent.
- **Reliability:** OS updates can require restart; hidden stderr and pipeline status masking produce false success; undocumented defaults may be ignored or overwritten by managed/cached preferences.
- **Performance:** Heavy-track disk exhaustion can leave partial installations. Broad Spotlight exclusion trades indexing load for lost search capability.
- **Maintainability:** Ad hoc final checks duplicate focused-skill verification and will drift. The orchestrator should invoke canonical selected-area checks rather than maintain a second implementation.

## Validation

- **System prep:** Before and after updates, run `softwareupdate --list` and confirm no applicable CLT item remains. Confirm target flags using `softwareupdate --help`. Validate the developer directory with `xcode-select -p`, `test -d "$(xcode-select -p)"`, `xcrun --find clang`, and `xcrun --show-sdk-path`.
- **Architecture:** Record `uname -m`, `sysctl -in hw.optional.arm64`, and `sysctl -in sysctl.proc_translated`. On a translated shell, prove the workflow stops before Homebrew or Rosetta decisions and resumes only in a native `arm64` shell.
- **Security:** Run `fdesetup status`, firewall `--getglobalstate`, and `--getblockall`. Inspect PAM ownership/mode with `sudo stat -f '%Su:%Sg %OLp' /etc/pam.d/sudo_local` and entries with `sudo grep -nE 'pam_(tid|reattach)' /etc/pam.d/sudo_local`.
- **PAM preservation:** On a controlled machine with a harmless custom `sudo_local` line and `pam_reattach`, run the workflow twice. Both lines and the original backup must survive; a new terminal must support Touch ID where available and password fallback where unavailable.
- **Defaults:** For selected groups, read at least `com.apple.finder ShowPathbar`, `com.apple.dock autohide`, `NSGlobalDomain KeyRepeat`, `com.apple.screencapture location`, `NSGlobalDomain NSNavPanelExpandedStateForSaveMode2`, and `com.apple.desktopservices DSDontWriteNetworkStores`. Verify the screenshot directory exists.
- **Rollback:** Start with non-default values and a populated Dock, apply the skill, then restore. Exact previous values and pins—not merely platform defaults—must return.
- **Orchestrator:** Exercise plans with Docker, GitHub, runtimes, and Brew individually trimmed. No corresponding probe or network operation should run. Force one check to fail and prove later independent checks still execute while the final verdict remains failed.
- **SSH:** If GitHub was selected and the user consents, test with `BatchMode=yes` and a finite `ConnectTimeout`; verify that the parser recognizes GitHub’s authenticated/no-shell message despite exit status 1 and rejects timeout or permission-denied output.
- **Environment:** Confirm `test -n "$CLAUDE_SKILL_DIR"` and readability of each referenced checker, or replace it with the harness’s documented skill-path mechanism.

## Minimal revision

1. Replace the orchestrator’s unconditional shell block with selected-area canonical checks, independent status capture, visible diagnostics, bounded SSH behavior, and non-pulling Docker verification.
2. Split dotfiles into **restore/merge early** versus **create/adopt last**, and qualify safe-resumption claims until state-preserving reruns are real.
3. Ensure system prep installs offered CLT updates, hard-stop translated shells, and diagnose the selected developer path before deleting CLT.
4. Preserve existing `sudo_local`, use non-clobbering backups and secure metadata, make Touch ID capability-aware, correct FileVault recovery wording, and inspect block-all firewall state.
5. Snapshot targeted defaults and Dock layout, add one verification per selected group, complete apply instructions, and make Spotlight exclusion optional.
6. Add the `mac-maintenance` routing exclusion, narrow the security hardening claim, verify the skill-directory mechanism, and remove reviewer-directed text from submitted artifacts.

```json
{"verdict":"PASS_WITH_CHANGES","confidence":0.94,"summary":"The skills are usable after correcting destructive PAM handling, stale-CLT handling, conditional verification, dotfiles ordering, and preference rollback.","top_issues":["sudo_local is overwritten and reruns destroy custom PAM state","OS-only updates can leave an installed CLT stale","Final verification masks failures and probes unselected components","Dotfiles restore is incorrectly ordered last","Defaults and Dock changes lack exact rollback"]}
```

## Curation instructions for Claude

Use this report as critique, not authority. Accept findings only when supported by evidence or cheap to mitigate; resolve disagreements with tests, code reads, or explicit user constraints. Model consensus never overrides failing tests, compiler errors, or specs.

---
name: mobile-dev-setup
description: Sets up mobile development on macOS - asks iOS, Android, or both; full Xcode with xcode-select, license and simulators; Android Studio with SDK, ANDROID_HOME and licenses; React Native/Flutter prerequisites. Use for "set up iOS/Android development", "install Xcode/Android Studio", "react native environment", "ANDROID_HOME not set". Not for Command Line Tools alone, app debugging, or publishing.
license: MIT
---

# Mobile Dev Setup

Installs the mobile toolchains — the disk-hungry, license-gated, env-var
fussy part of Mac setup. Asks **iOS, Android, or both** first and touches
only the selected track.

## When NOT to use

- Xcode **Command Line Tools** only → `macos-system-prep`
- Swift/Kotlin/Flutter code errors, UI bugs → project work
- App Store / Play publishing, fastlane CI → release engineering, not setup
- Backend containers → `docker-on-mac`; generic JDK for servers →
  `language-runtimes`

## Safety rails

- Disk check first: full Xcode needs **~40–50 GB free** (app + simulator
  runtimes); Android Studio + SDK + AVDs another ~15 GB. `df -h /` before
  starting; warn, don't surprise.
- `sudo xcodebuild -license accept` and `xcode-select -s` are privileged —
  consent first.
- Nothing outside the selected track gets installed.

## Workflow — iOS track

1. **Install full Xcode** (pick one):
   - App Store (simplest; needs Apple Account sign-in — manual).
   - `xcodes` for versions/automation: `brew install xcodesorg/made/xcodes
     && xcodes install --latest` (Apple ID sign-in; `brew install aria2`
     speeds downloads). Check first that the latest Xcode supports this
     macOS (`sw_vers`; new Xcodes require recent macOS point releases) and
     that the *project* doesn't pin an older Xcode.
   - There is **no `xcode` cask.** Install to `/Applications`, never
     `~/Applications`.

2. **Point the toolchain at it** — installing Xcode does NOT do this:

```sh
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch          # installs required components
xcodebuild -downloadPlatform iOS         # simulator runtime (~7-8 GB)
```

3. **Verify:** `xcodebuild -version`; `xcrun simctl list devices | head`;
   boot a simulator (`open -a Simulator`).

4. **Apple Developer account** (manual): free tier = run on your own
   devices with 7-day provisioning, 3 devices; $99/yr = TestFlight + App
   Store distribution. Sign-in happens in Xcode → Settings → Accounts.

**The recurring iOS breaker:** "xcodebuild requires Xcode, but active
developer directory is a command line tools instance" — after macOS
upgrades and new Xcode installs the pointer resets to the CLT. Fix is the
`xcode-select -s` line above; it's a 5-second fix that masquerades as a
broken CocoaPods/Flutter/RN install.

## Workflow — Android track

1. **Android Studio + first-run wizard:**

```sh
brew install --cask android-studio
open -a "Android Studio"    # wizard downloads the SDK to ~/Library/Android/sdk - let it finish
```

2. **Environment** — PERSIST into `~/.zshrc` (grep-guarded; plain
   `export` in the session dies with it). If an SDK already exists at a
   custom path, point `ANDROID_HOME` there instead of reinstalling.
   `ANDROID_HOME` is current; `ANDROID_SDK_ROOT` is deprecated:

```sh
grep -q 'ANDROID_HOME' ~/.zshrc || cat >> ~/.zshrc <<'EOF'
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
EOF
source ~/.zshrc 2>/dev/null || export ANDROID_HOME="$HOME/Library/Android/sdk"
```

(cmdline-tools missing? SDK Manager → SDK Tools → "Android SDK
Command-line Tools (latest)".)

3. **Licenses:** run `sdkmanager --licenses` **interactively and let the
   user read and answer the prompts** — accepting Google's SDK licenses is
   the user's legal act, not something to pipe `yes` through.

4. **JDK:** Android Studio bundles its JetBrains Runtime and uses it for
   Gradle by default — usually nothing to install. Command-line Gradle
   builds need **JDK 17+** (AGP minimum): check first
   (`/usr/libexec/java_home -V` — an existing 17+ JDK or a
   `language-runtimes` manager already covers it); only when none exists,
   `brew install --cask temurin@21`.

5. **Emulator:** create an AVD with an **arm64-v8a** system image (x86_64
   images crawl on Apple Silicon); acceleration is automatic via
   Hypervisor.framework. Verify: `adb --version`, `emulator -list-avds`,
   boot it once.

## Cross-platform frameworks (on request)

- **React Native:** official default is **Expo** (framework); the manual
  env needs Node ≥ 22 (→ `language-runtimes`), `brew install watchman`,
  the iOS track (plus CocoaPods where the project uses it: `brew install
  cocoapods` — maintenance mode, still required by many RN projects), and
  the Android track. Doctor: `npx @react-native-community/cli doctor`.
- **Flutter:** SDK via VS Code extension or manual download
  (`brew install --cask flutter` exists but isn't the documented path);
  needs both tracks for both targets; **no Rosetta needed** on current
  Flutter; `flutter doctor` drives the remaining checklist.

Facts that age (Xcode/AGP versions, CocoaPods timeline):
[references/mobile-facts.md](references/mobile-facts.md).

## Verify

```sh
sh "${CLAUDE_SKILL_DIR}/scripts/check.sh"
```

## Output spec

Done means: selected tracks only; iOS — `xcodebuild -version` works,
license accepted, a simulator boots; Android — `adb` on PATH,
`ANDROID_HOME` set, licenses accepted, an arm64 AVD exists; frameworks —
their doctor commands pass or remaining failures are reported honestly
with owners (e.g. "needs Apple ID sign-in — manual").

## Gotchas

- Xcode downloads are huge and the App Store shows no useful progress —
  `xcodes` shows real progress and resumes.
- After **every** macOS major upgrade: re-check `xcode-select -p` and
  expect a new license/`-runFirstLaunch` prompt.
- `sdkmanager: command not found` = cmdline-tools not installed or PATH
  line missing — it lives under `cmdline-tools/latest/bin`.
- Stale Google docs still export PATH for removed `tools/` dirs — the
  three dirs in step 2 are the current set.
- CocoaPods trunk goes read-only Dec 2026; existing pods keep resolving.
  New native iOS work: SPM. RN ships precompiled frameworks but hasn't
  dropped pods yet — install cocoapods when the project has a Podfile.
- Simulators eat disk over time: `xcrun simctl list devices unavailable`
  to see what's orphaned, then — with consent, it deletes those simulators
  and their app data irreversibly — `xcrun simctl delete unavailable`.

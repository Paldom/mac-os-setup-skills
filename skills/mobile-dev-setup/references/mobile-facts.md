# Mobile toolchain facts (verified against Apple/Google/project docs, 2026-08-17)

Fast-moving — re-verify versions before pinning anything.

## Xcode

- Apple renumbered Xcode to match OS versions: current stable line is
  **Xcode 26.x** (26.6 mid-2026); Xcode 27 beta announced WWDC26. Xcode
  26.3+ includes agentic coding/MCP support.
- Install paths: Mac App Store (latest stable only) · developer.apple.com/
  download (betas + back versions; Apple ID) · `xcodes` CLI
  (`brew install xcodesorg/made/xcodes`; a homebrew-core `xcodes` formula
  also exists now; GUI: `brew install --cask xcodes`). **No `xcode` cask.**
- Post-install (all verified against current xcodebuild):
  `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`,
  `sudo xcodebuild -license accept`, `sudo xcodebuild -runFirstLaunch`,
  `xcodebuild -downloadPlatform iOS` (also watchOS/tvOS/visionOS;
  `-downloadAllPlatforms`; `-checkFirstLaunchStatus`).
- Disk: Xcode 26 is leaner than 15/16 era but still plan ~30–35 GB app +
  5–8 GB per simulator runtime → keep ~40–50 GB free.
- CLT vs full Xcode: CLT = clang/git/make + macOS SDK only. iOS SDKs,
  Simulator, `xcodebuild` project builds, signing/archiving, SwiftUI
  previews all need full Xcode.
- Apple Developer Program: free account = Personal Team signing, 3 devices/
  platform, 7-day provisioning expiry, no TestFlight/App Store; paid
  $99/yr lifts all of it.

## Android

- Android Studio versioning: `<Animal> | YYYY.R` — 2026 stable line is
  "Quail" (2025.x names: Narwhal→Otter→Panda). Cask: `android-studio`.
- SDK default location (macOS): `~/Library/Android/sdk`.
- Env: **`ANDROID_HOME` current; `ANDROID_SDK_ROOT` deprecated** (tools
  warn if both set inconsistently). PATH additions that matter:
  `platform-tools` (adb), `emulator`, `cmdline-tools/latest/bin`
  (sdkmanager/avdmanager). Google's env-vars page still lists removed
  `tools/` dirs — ignore those.
- Licenses: `sdkmanager --licenses` (headless accept).
- JDK: AGP 8.x/9.x require **JDK 17 minimum**; Gradle 9 needs 17+.
  Android Studio's embedded JetBrains Runtime is the default Gradle JDK —
  standalone JDK only needed for CLI builds (temurin@21 is a safe pick).
- Emulator on Apple Silicon: **arm64-v8a system images**; HW acceleration
  automatic via Hypervisor.framework (HAXM is dead); check
  `emulator -accel-check`.

## CocoaPods / SPM

- CocoaPods is in **maintenance mode** (support plans announced 2024):
  security fixes + ~2 releases/yr. **Trunk goes permanently read-only
  2026-12-02** (existing pods keep resolving). `brew install cocoapods`
  still valid (1.17.x).
- New native iOS: Swift Package Manager is the default.
- React Native: ships **precompiled XCFrameworks** by default (RN 0.84+/
  Expo SDK 56); still links via CocoaPods today; SPM migration is the
  announced roadmap. Install cocoapods when the project has a Podfile.

## React Native / Flutter

- RN docs recommend **Expo** ("we recommend using a Framework") — manual
  env setup only for framework-less apps. Manual needs: Node ≥ 22.11,
  `brew install watchman`, full Xcode (+pods per project), Android Studio
  + `zulu@17`-class JDK + SDK Platform per RN docs. Doctor:
  `npx @react-native-community/cli doctor` (CLI unbundled since RN 0.77).
- Flutter: install via VS Code extension (docs-recommended quick start) or
  manual SDK zip; community cask `flutter` exists. **Rosetta no longer
  required** (Flutter ≥ 3.44 all-ARM); Intel Macs being deprecated by
  Flutter. Validate with `flutter doctor`.
- fastlane: maintained under Mobile Native Foundation; install via Bundler
  Gemfile (docs-preferred) or `brew install fastlane`; needs Ruby ≥ 3.0
  (never system Ruby).

## Cleanup

- `xcrun simctl delete unavailable` — removes simulators orphaned by SDK
  updates.
- `~/Library/Developer/Xcode/DerivedData` — safe to delete (rebuilds);
  convention, not an Apple-documented support path.

#!/bin/sh
# Read-only verification for mobile-dev-setup. Checks only what exists; fails on half-configured tracks.
fail=0
# iOS track (only if full Xcode present)
if [ -d /Applications/Xcode.app ]; then
  devdir=$(xcode-select -p 2>/dev/null)
  case "$devdir" in
    */Xcode.app/*) echo "OK   xcode-select: $devdir" ;;
    *) echo "FAIL xcode-select points at '$devdir' - run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"; fail=1 ;;
  esac
  if xcodebuild -version >/dev/null 2>&1; then
    echo "OK   xcodebuild: $(xcodebuild -version 2>/dev/null | head -1)"
  else
    echo "FAIL xcodebuild not working (license? -runFirstLaunch?)"
    fail=1
  fi
  sims=$(xcrun simctl list devices available 2>/dev/null | grep -c iPhone)
  [ "${sims:-0}" -gt 0 ] && echo "OK   simulators: $sims iPhone devices" || echo "INFO simulators: none (xcodebuild -downloadPlatform iOS)"
else
  echo "INFO iOS: full Xcode not installed (CLT-only is fine for non-iOS work)"
fi
# Android track (only if SDK dir present)
SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
if [ -d "$SDK" ]; then
  [ -n "$ANDROID_HOME" ] && echo "OK   ANDROID_HOME: $ANDROID_HOME" || { echo "FAIL ANDROID_HOME unset (SDK exists at $SDK)"; fail=1; }
  command -v adb >/dev/null 2>&1 && echo "OK   adb: $(adb --version 2>/dev/null | head -1)" || { echo "FAIL adb not on PATH (add platform-tools)"; fail=1; }
  command -v sdkmanager >/dev/null 2>&1 && echo "OK   sdkmanager on PATH" || echo "INFO sdkmanager not on PATH (cmdline-tools/latest/bin)"
  command -v emulator >/dev/null 2>&1 && echo "OK   emulator: $(emulator -list-avds 2>/dev/null | wc -l | tr -d ' ') AVDs" || echo "INFO emulator not on PATH"
else
  echo "INFO Android: SDK not present"
fi
exit $fail

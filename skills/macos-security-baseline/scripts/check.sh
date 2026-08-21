#!/bin/sh
# Read-only verification for macos-security-baseline. Exits non-zero on failure.
fail=0
fv=$(fdesetup status 2>&1)
case "$fv" in
  *"FileVault is On"*) echo "OK   filevault: on" ;;
  *) echo "FAIL filevault: $fv"; fail=1 ;;
esac
fw=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>&1)
case "$fw" in
  *enabled*) echo "OK   firewall: enabled" ;;
  *) echo "FAIL firewall: $fw"; fail=1 ;;
esac
if [ -f /etc/pam.d/sudo_local ] && grep -q '^auth.*pam_tid' /etc/pam.d/sudo_local 2>/dev/null; then
  echo "OK   touch-id sudo: pam_tid active in /etc/pam.d/sudo_local"
else
  echo "INFO touch-id sudo: not configured (optional)"
fi
exit $fail

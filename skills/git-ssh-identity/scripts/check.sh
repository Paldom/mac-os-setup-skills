#!/bin/sh
# Read-only verification for git-ssh-identity. Exits non-zero on hard failures.
fail=0
name=$(git config --global user.name 2>/dev/null)
email=$(git config --global user.email 2>/dev/null)
[ -n "$name" ] && echo "OK   user.name: $name" || { echo "FAIL user.name unset"; fail=1; }
[ -n "$email" ] && echo "OK   user.email: $email" || { echo "FAIL user.email unset"; fail=1; }
db=$(git config --global init.defaultBranch 2>/dev/null)
[ "$db" = "main" ] && echo "OK   init.defaultBranch: main" || echo "INFO init.defaultBranch: ${db:-unset}"
if ls "$HOME"/.ssh/id_ed25519* >/dev/null 2>&1; then
  echo "OK   ssh key: ed25519 present"
else
  echo "INFO ssh key: no ~/.ssh/id_ed25519* (generate one if GitHub SSH is wanted)"
fi
if grep -q 'UseKeychain' "$HOME/.ssh/config" 2>/dev/null; then
  echo "OK   ssh config: Keychain block present"
else
  echo "INFO ssh config: no UseKeychain block (passphrase will be re-asked)"
fi
if [ "$(git config --global commit.gpgsign 2>/dev/null)" = "true" ]; then
  sk=$(git config --global user.signingkey 2>/dev/null)
  [ -n "$sk" ] && echo "OK   signing: on, key $sk" || { echo "FAIL signing on but user.signingkey unset"; fail=1; }
  af=$(git config --global gpg.ssh.allowedSignersFile 2>/dev/null)
  [ -n "$af" ] && echo "OK   allowedSignersFile: $af" || echo "INFO allowedSignersFile unset (local verify will fail)"
fi
# Non-fatal connectivity probe (network); GitHub returns exit 1 on success with a greeting
out=$(ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1)
case "$out" in
  *"successfully authenticated"*) echo "OK   github ssh: $out" ;;
  *) echo "INFO github ssh: $out" ;;
esac
exit $fail

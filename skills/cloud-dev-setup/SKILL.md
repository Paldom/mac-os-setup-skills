---
name: cloud-dev-setup
description: Installs cloud CLIs on macOS - asks which of AWS, Azure, Google Cloud, Databricks, kubectl, Terraform/OpenTofu, then installs and authenticates via SSO/browser flows with named profiles, never static keys. Use for "install aws/az/gcloud/databricks CLI", "aws sso setup", "kubectl on Mac", "terraform or opentofu". Not for writing infrastructure code, deploying, Docker, or the GitHub CLI.
license: MIT
---

# Cloud Dev Setup

Installs and authenticates the cloud CLIs the user actually needs — asked
first, nothing extra — with the auth patterns that keep long-lived secrets
off the machine: browser/SSO flows and named profiles.

## When NOT to use

- Writing Terraform/K8s manifests, deploying, debugging cloud workloads →
  project work
- Container runtime → `docker-on-mac`
- `gh` (GitHub CLI) → `dev-cli-tools` / `git-ssh-identity`
- Databricks *workload* development (jobs, pipelines) → per-product tools,
  not machine setup

## Prerequisites

`brew` present (→ `homebrew-setup`).

## Safety rails

- **Never** create long-lived static keys or write any credential into
  `~/.zshrc`, dotfiles, or chat. Browser/SSO flows do cache short-lived
  OAuth tokens in each CLI's own config dir (`~/.aws`, `~/.azure`,
  `~/.config/gcloud`, `~/.databrickscfg` + token cache) — that's expected;
  keep those dirs out of any repo and leave their permissions alone.
- Install only user-selected providers.
- Multiple accounts/workspaces → named profiles from day one; never rely
  on a mutable default profile for anything destructive.
- Identity-verification outputs contain account IDs/tenants/emails — fine
  in this local session, but don't paste them onward.

## Workflow

Ask which of: AWS · Azure · Google Cloud · Databricks · kubectl ·
Terraform/OpenTofu. Then per selection:

### AWS

```sh
brew install awscli        # community formula, tracks upstream closely
# (AWS's own channels: pkg installer / install script - use if policy requires vendor-official)
aws configure sso          # wizard - when it asks for the profile name, set a real one (e.g. "work")
aws sso login --profile work
aws sts get-caller-identity --profile work    # verify
```

IAM Identity Center (SSO) short-term credentials are AWS's recommended
workforce auth; long-term IAM keys are explicitly "not recommended".

### Azure

```sh
brew install azure-cli     # Microsoft's official documented macOS method
az login                   # browser; subscription selector on success
az account show
```

### Google Cloud

Two channels — pick one, don't mix. The cask is the practical default
here; the vendor path is the arch-specific tarball from
docs.cloud.google.com/sdk/docs/install (download, extract,
`./google-cloud-sdk/install.sh`):

```sh
brew install --cask gcloud-cli    # community cask (renamed from google-cloud-sdk)
gcloud init                       # auth + creates a named configuration - name it (e.g. "work")
gcloud config configurations list
```

`gcloud auth login` = the CLI's own credentials; `gcloud auth
application-default login` = ADC for SDKs/Terraform — different stores,
teams need both more often than they think. Updates: channel A →
`gcloud components update`; channel B → `brew upgrade --cask gcloud-cli`
(avoid mixing the two update paths).

### Databricks

```sh
brew tap databricks/tap
# Homebrew 6+: trust the third-party tap explicitly (older brew lacks the
# command - then the tap prompt itself is the consent step; if trust FAILS
# on brew 6, stop and investigate rather than bypassing it):
brew help trust >/dev/null 2>&1 && brew trust databricks/tap
brew install databricks/tap/databricks
# Use the EXACT workspace URL (AWS: https://<ws>.cloud.databricks.com,
# Azure: https://adb-<id>.<n>.azuredatabricks.net, GCP: https://<ws>.gcp.databricks.com):
databricks auth login --host <workspace-url> --profile work   # OAuth U2M, browser
databricks auth profiles                        # lists profiles + validity
```

OAuth is the recommended auth; PATs are legacy. Profiles live in
`~/.databrickscfg`; select with `--profile <name>` — with several
workspaces, always pass it explicitly.

### kubectl

```sh
brew install kubectl       # kubernetes.io documents brew for macOS
kubectl version --client
grep -q 'kubectl completion' ~/.zshrc || echo 'source <(kubectl completion zsh)' >> ~/.zshrc
```

Skew rule: client within ±1 minor of the cluster. Contexts:
`kubectl config get-contexts` / `use-context` (kubectx is a nice-to-have).

### Terraform / OpenTofu (neutral choice)

```sh
# Terraform (BUSL license; REMOVED from homebrew-core - tap required)
brew tap hashicorp/tap && brew install hashicorp/tap/terraform
# OpenTofu (MPL-2.0 fork; plain core formula)
brew install opentofu
```

Fact for the choice: Terraform is source-available under BUSL (IBM);
OpenTofu is MPL-2.0 under the Linux Foundation. Both maintained; pick per
org licensing/ecosystem policy. `brew install terraform` without the tap
no longer works — stale guides break here.

## Verify

Per installed CLI, its identity command in a fresh shell:
`aws sts get-caller-identity --profile <p>` · `az account show` ·
`gcloud config list` · `databricks auth profiles` · `kubectl version
--client` · `terraform -version`/`tofu -version`.

## Output spec

Done means: selected CLIs installed; auth-capable ones (AWS/Azure/GCloud/
Databricks) authenticated via browser/SSO with a named profile **where
the user has an account** — client-only tools (kubectl without a cluster,
terraform/tofu) verify by version instead; identity outputs shown; no
long-lived static credentials created and nothing secret placed in shell
files or dotfiles.

## Gotchas

- Old scripts using `brew install terraform` or cask `google-cloud-sdk`
  fail — the formula was removed and the cask renamed (`gcloud-cli`).
- `aws sso login` sessions expire (hours) — re-login is normal, not
  breakage; long-lived keys are the wrong fix.
- brew-cask gcloud + `gcloud components update` = dual ownership drift;
  choose one updater.
- Databricks CLI is 1.x now — docs/snippets mentioning `v0.2xx` behavior
  are dated but compatible; `databricks -v` to confirm.
- Corporate proxies/VPNs break browser SSO flows — device-code variants
  (`az login --use-device-code`, `aws sso login --use-device-code`) are
  the workaround.

---
name: docker-on-mac
description: Sets up a container runtime on macOS - Docker Desktop (paid over 250 staff/$10M), OrbStack (paid commercial use), or Colima (free CLI) - install, hello-world verify, contexts, amd64 on Apple Silicon. Use for "install docker on my Mac", "docker desktop vs orbstack vs colima", "docker command not found", "exec format error". Not for Dockerfiles, compose debugging, Kubernetes, or databases.
---

# Docker on Mac

Chooses and installs the right container runtime for the user's licensing
situation and workflow. macOS runs Linux containers in a VM — the runtime
choice is really a choice of VM manager, and in 2026 it's a licensing
decision as much as a technical one.

## When NOT to use

- Writing Dockerfiles / compose files, image debugging → native competence
- Kubernetes / cloud contexts → `cloud-dev-setup`
- Local Postgres/Redis without containers → `web-dev-setup`
- Windows/Linux desktop VMs → Parallels/UTM via `mac-dev-apps`

## Prerequisites

`brew` present (→ `homebrew-setup`).

## The decision (ask these two questions)

1. **Licensing:** Docker Desktop is free only for personal use,
   education, non-commercial OSS, and businesses with **fewer than 250
   employees AND under $10M revenue** — beyond either bound it needs a
   paid subscription. Any **commercial** use → OrbStack requires Pro
   (~$8/user/mo). Colima and the plain Docker CLI are free for
   everything.
2. **Workflow:** want a GUI/dashboard → Desktop or OrbStack. Terminal-only
   fine → Colima.

| | Docker Desktop | OrbStack | Colima |
|---|---|---|---|
| Cost | free under 250 emp AND $10M; else paid | free personal; Pro for commercial | free, open source |
| Speed/RAM | heaviest | fastest start, lowest idle | middle |
| GUI | yes | yes | no |
| Fit | cross-platform teams, org standard | Mac-first daily driver | free-policy orgs, CI-like |

(Apple's own `container` tool is 1.x and macOS-26-only, no compose — watch,
don't adopt as the daily driver.)

## Safety rails

- These installs may prompt for the admin password (privileged helper /
  docker.sock symlink) — expected; tell the user.
- Never uninstall an existing runtime without consent; multiple runtimes
  coexist via `docker context`.

## Workflow

### Install the chosen runtime

```sh
# Docker Desktop  (cask renamed from `docker` in 2025 - old token aliases)
brew install --cask docker-desktop
open -a "Docker"          # first launch: accept terms, grant privileged helper

# OrbStack - bundles docker CLI/compose/buildx if missing
brew install --cask orbstack
open -a OrbStack

# Colima - engine + separate CLI client
brew install colima docker docker-compose
colima start              # Apple Silicon fast path: colima start --vm-type=vz --vz-rosetta
```

**The trap:** `brew install docker` (formula, no `--cask`) is the **CLI
client only** — no engine. "Installed docker but nothing runs" is almost
always this; pair the CLI with a runtime or install a cask.

### Verify

Make sure you're testing the runtime you just installed, not a leftover
one — select its context first:

```sh
docker context ls          # active context marked *; desktop-linux / orbstack / colima
docker context use <the-new-runtime's-context>
docker run --rm hello-world
docker compose version     # compose plugin wired (bundled by Desktop/OrbStack)
sh "${CLAUDE_SKILL_DIR}/scripts/check.sh"
```

### Multi-arch on Apple Silicon

Default build/run platform is `linux/arm64`. For CI/prod parity:

```sh
docker run --platform linux/amd64 <image>        # one-off, emulated (Rosetta) - slower
# Multi-arch image: needs a destination or it only fills the build cache -
# push to a registry (or --load for ONE platform locally):
docker buildx build --platform linux/amd64,linux/arm64 -t registry/you/app:tag --push .
docker buildx imagetools inspect registry/you/app:tag   # confirm both platforms
```

"`exec format error`" in CI is **often** an arm64-only image meeting an
amd64 runner (also caused by bad shebangs/CRLF — check the image arch
first: `docker image inspect --format '{{.Architecture}}' <image>`).
Prefer native arm64 images locally; treat amd64 emulation as a
compatibility path. Rosetta x86 emulation is on by default in current
Docker Desktop and OrbStack on Apple Silicon.

## Output spec

Done means: chosen runtime installed and started, `docker run --rm
hello-world` succeeds, active context confirmed, licensing constraint
recorded in the summary (which tier and why), and the user knows the
multi-arch flags if they deploy to amd64.

## Gotchas

- Docker Desktop ↔ OrbStack both want `/var/run/docker.sock`; the last one
  granted admin wins the symlink — contexts still route correctly, but
  tools hardcoding the sock path follow the symlink owner.
- Colima VMs don't autostart at login by default — `brew services start
  colima` if that's wanted.
- Docker Desktop requires macOS 14+ now; keep it updated via its own
  updater (auto_updates cask).
- Bind-mount-heavy workloads (node_modules in containers) are the classic
  Mac pain — OrbStack's filesystem is the fastest of the three; or keep
  hot paths in named volumes.
- License thresholds and prices drift — verify at docker.com/pricing and
  orbstack.dev/pricing when it matters
  ([references/runtime-licensing.md](references/runtime-licensing.md)).

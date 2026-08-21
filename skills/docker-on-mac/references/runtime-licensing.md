# Container runtime licensing & facts (verified 2026-08-17)

Licensing changes; verify at the linked sources before advising an org.

## Docker Desktop (docs.docker.com/subscription/desktop-license, docker.com/pricing)

- Free ("Docker Personal") covers: small businesses (**fewer than 250
  employees AND less than $10M annual revenue**), personal use, education,
  non-commercial open source. Exceeding either threshold → paid.
- Paid (per user/month at check time): Pro $9 (annual) / $11 (monthly),
  Team $15/$16, Business $24.
- Cask: `docker-desktop` (renamed from `docker`, June/July 2025; old token
  aliases). Requires macOS 14+. Bundles compose plugin + buildx; Rosetta
  x86 emulation on by default on Apple Silicon (macOS 14.1+).

## OrbStack (orbstack.dev/pricing)

- Free for **personal, non-commercial** use only. **Any commercial use →
  Pro** (~$8/user/mo billed annually, $96/yr; no size threshold).
- Cask `orbstack`; drop-in docker CLI/compose/buildx (installs them if
  missing); creates `docker context` "orbstack"; uses Rosetta for amd64.

## Colima (github.com/abiosoft/colima)

- MIT, free for everything. `brew install colima docker docker-compose`.
- Apple Silicon fast path: `colima start --vm-type=vz --vz-rosetta`
  (Virtualization.framework + Rosetta; needs macOS 13+).
- Active project (0.10.x releases through 2026). No GUI.

## Podman (podman.io)

- Free/open source, daemonless. Official installer recommended (podman.io
  labels brew "community, not recommended"): `podman machine init &&
  podman machine start`; listens for Docker API clients.

## Apple `container` (github.com/apple/container)

- v1.2.x (Aug 2026): Swift, one lightweight VM per container, OCI images,
  new k8s plugin. **Apple Silicon + macOS 26 only; no Docker Compose; no
  GUI.** Fine to experiment; not a Docker Desktop replacement yet.

## The formula-vs-cask trap

- `docker` **formula** = CLI client only (engine not included).
- `docker-desktop` **cask** = the full Desktop app.
- `docker-compose` formula = standalone compose (v5.x); Desktop/OrbStack
  bundle the `docker compose` plugin already — don't double-install unless
  using Colima.

## Verification

```sh
docker context ls
docker run --rm hello-world     # "installation appears to be working correctly"
docker version && docker info
```

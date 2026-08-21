# AI coding CLI matrix (verified against vendor docs/repos, 2026-08-17)

Fastest-churning category in this repo — when an install command fails,
trust the vendor doc over this file and update it.

## Install + auth per tool

| Tool | Primary install | Secondary | Auth | Config home |
|---|---|---|---|---|
| **Claude Code** | `curl -fsSL https://claude.ai/install.sh | bash` (native; auto-updates; `~/.local/bin/claude`) | `brew install --cask claude-code` (stable, ~1wk behind, no auto-update) · `npm i -g @anthropic-ai/claude-code` (Node 22+) | browser login: Pro/Max/Team/Enterprise or Console; `ANTHROPIC_API_KEY` honored with confirmation | `~/.claude/`, `~/.claude.json`; project `.claude/`, `.mcp.json` |
| **Codex CLI** | `curl -fsSL https://chatgpt.com/codex/install.sh | sh` | `npm i -g @openai/codex` · `brew install --cask codex` | "Sign in with ChatGPT" (Plus/Pro/Business/Edu/Enterprise); API key possible | `~/.codex/config.toml` (`CODEX_HOME`) |
| **Gemini CLI** | `brew install gemini-cli` (formula) | `npm i -g @google/gemini-cli` · `npx @google/gemini-cli` | Google-account OAuth (free tier ~60 req/min, 1000/day) · `GEMINI_API_KEY` · Vertex | `~/.gemini/settings.json` |
| **Copilot CLI** (standalone) | `npm i -g @github/copilot` (Node 22+) | `brew install --cask copilot-cli` · `curl -fsSL https://gh.io/copilot-install | bash` | `/login` with Copilot-subscribed GitHub account; PAT with Copilot Requests scope for CI | `~/.copilot/` |
| **Grok Build** (xAI, official) | `curl -fsSL https://x.ai/cli/install.sh | bash` → `grok` | (npm mirror exists but unconfirmed-official) | browser; SuperGrok / X Premium+ | `~/.grok` (unverified) |
| **Kimi Code** (Moonshot) | `curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash` → `kimi` | npm `@moonshot-ai/kimi-code` (name inconsistently reported) | `/login`: Kimi subscription OAuth or platform.kimi.ai key | `~/.kimi-code/` (secondary-sourced) |

| **pi** (Earendil, ex badlogic/pi-mono) | `npm i -g --ignore-scripts @earendil-works/pi-coding-agent` or `curl -fsSL https://pi.dev/install.sh | sh` → `pi` | (no brew formula documented) | `/login`: ChatGPT Plus/Pro, Claude Pro/Max, Copilot, xAI, OpenRouter OAuth, or provider API keys via env; tokens in `~/.pi/agent/auth.json` | `~/.pi/agent/` (settings.json, skills); project `.pi/` |

pi extras: reads **AGENTS.md natively** (also CLAUDE.md; `AGENTS.override.md`
wins); minimal by design — no built-in MCP/permission popups, extend via
TypeScript extensions and skills; update with `pi update --self`.
Sources: pi.dev/docs, github.com/earendil-works/pi (verified 2026-08-21).

Also mainstream (install on request): Cursor CLI (`curl
https://cursor.com/install -fsS | bash`, command now `agent`), OpenCode
(`curl -fsSL https://opencode.ai/install | bash`), aider (uv/pipx; brew
discouraged by its docs), Amp (`npm i -g @ampcode/cli`).

## Deprecations & traps

- **`gh copilot` extension: deprecated 2025-10-25, repo archived** — the
  standalone `copilot` CLI is the successor. Do not install gh-copilot.
- Claude Code npm route is no longer the headline method (still supported);
  native installer needs no Node and self-updates (`DISABLE_AUTOUPDATER=1`
  to opt out; `claude doctor` shows update state; `claude update` manual).
- Original Python `kimi-cli` is winding down → Kimi Code migrates config
  automatically.
- Third-party npm packages squat popular agent names — install from the
  vendor's documented command only.
- One install channel per tool; `which -a claude codex gemini copilot`
  reveals duplicates.

## Instruction files (2026 state)

- **AGENTS.md native:** Codex (`/init` generates), Grok Build, OpenCode,
  Amp (also reads AGENT.md/CLAUDE.md).
- **Gemini:** GEMINI.md default; `context.fileName` setting accepts
  `["AGENTS.md","GEMINI.md"]`.
- **Claude Code:** CLAUDE.md (+`.claude/rules/`); official AGENTS.md
  pattern = a CLAUDE.md containing `@AGENTS.md`.
- **Copilot:** `.github/copilot-instructions.md` lineage.

## Security guardrails worth stating

- Agents run with the user's full file/exec access: SSH keys, cloud
  sessions, browser cookies are in reach. Recommend: per-project
  permission allowlists (Claude: `.claude/settings.json` permissions;
  others: their approval modes), no blanket "always allow Bash",
  sandboxes (git worktrees, devcontainers) for secret-bearing repos.
- Subscription OAuth keeps long-lived API keys off disk — prefer it for
  interactive use; API keys only for CI with scoped secrets storage.

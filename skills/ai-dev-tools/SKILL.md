---
name: ai-dev-tools
description: Installs AI coding agent CLIs on macOS - asks which of Claude Code, Codex, Gemini, Copilot, Grok Build, Kimi Code, then uses official installers, subscription sign-ins, and permission guardrails. Use for "install claude code", "set up codex/gemini/copilot/pi CLI", "AI coding agents on my Mac". Not for using the agents, prompt authoring, MCP servers, API integration, or local LLMs.
license: MIT
---

# AI Dev Tools

Installs the agentic coding CLIs — a day-one install class of its own by
2026 — via each vendor's *current* official channel (most now ship native
installers; some are brew/npm), authenticated with subscriptions the user
already has. Also the right moment to set security guardrails: these
tools get read/write + exec on a machine that holds SSH keys and cloud
sessions.

## When NOT to use

- Using/configuring agents beyond install (prompts, CLAUDE.md/AGENTS.md
  content, MCP servers) → project work
- Anthropic/OpenAI **API** integration in code → SDK docs, not setup
- Local models (Ollama, LM Studio) → different category; mention only
- Editors with AI (Cursor) → `editor-setup`

## Safety rails

- Auth is **browser sign-in with existing subscriptions** — never ask for,
  echo, or store API keys during setup.
- Install only the CLIs the user selects.
- After install, state the threat model in one paragraph: agents execute
  commands and edit files; recommend per-project permission allowlists,
  reviewing dangerous-command prompts, and container/worktree sandboxes
  for sensitive repos. Don't silently maximize permissions.

## Workflow

Ask which to install. First inventory duplicates (`which -a claude codex
gemini copilot grok kimi 2>/dev/null` — an existing install means update
that channel, not add a second). npm routes need Node ≥ 22
(→ `language-runtimes`). Then per selection (verified commands, sources
and fallbacks: [references/ai-cli-matrix.md](references/ai-cli-matrix.md)):

```sh
# Claude Code (Anthropic) - native installer is primary; brew cask/npm secondary
curl -fsSL https://claude.ai/install.sh | bash
claude --version && claude doctor        # then `claude` -> browser login (Pro/Max/Team or Console)

# Codex CLI (OpenAI)
curl -fsSL https://chatgpt.com/codex/install.sh | sh   # or: npm i -g @openai/codex / brew install --cask codex
codex --version                          # first run -> "Sign in with ChatGPT" (Plus/Pro/Business)

# Gemini CLI (Google)
brew install gemini-cli                  # or: npm i -g @google/gemini-cli
gemini --version                         # Google-account OAuth; generous free tier

# Copilot CLI (GitHub) - the STANDALONE cli; `gh copilot` extension is deprecated/archived
npm install -g @github/copilot           # or: brew install --cask copilot-cli
copilot                                  # /login with the Copilot-subscribed account

# Grok Build (xAI) - official since 2026-05
curl -fsSL https://x.ai/cli/install.sh | bash          # SuperGrok / X Premium+ sign-in

# Kimi Code (Moonshot) - successor of kimi-cli (auto-migrates config)
curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash
kimi                                     # /login: subscription OAuth (preferred; a pay-as-you-go
                                         # API-key mode exists - enter it inside the tool's own
                                         # login flow only, never via chat or shell args)

# pi (Earendil / Mario Zechner) - minimal open-source agent, multi-provider
npm install -g --ignore-scripts @earendil-works/pi-coding-agent   # or: curl -fsSL https://pi.dev/install.sh | sh
pi                                       # /login: ChatGPT, Claude, Copilot, xAI, OpenRouter
                                         # subscription OAuth, or provider API keys via env
```

Install-channel policy: prefer brew/npm where a real package exists
(Gemini, Copilot, Codex, Claude Code casks) — reviewable and
update-managed. The `curl | bash` lines are the vendors' documented
installers (verified against vendor docs; sources in the reference) and
the only channel for some tools; a cautious user can download to a file,
read it, then run it — offer that.

### Guardrails (after install)

- Claude Code: permission rules live in `.claude/settings.json`
  (project) / `~/.claude/settings.json` — start from deny-by-prompt
  defaults; don't pre-approve broad Bash.
- All agents: keep secrets out of repos the agent works in. Git worktrees
  isolate *changes* (nice for review), *not* credentials or processes —
  real isolation for sensitive repos means a container/VM or separate
  user account without the host's keys, cloud sessions, or docker socket.
  Review each tool's data/telemetry settings on first run.
- Updates: Claude Code self-updates (native install); npm installs update
  via npm; brew casks via brew. One channel per tool — mixing npm + native
  installs leaves two binaries fighting on PATH.

### Instruction-file conventions (when asked)

AGENTS.md is the emerging cross-tool standard: native in Codex, Grok
Build, OpenCode, Amp; Gemini reads it via the `context.fileName` setting;
Claude Code reads CLAUDE.md and imports with `@AGENTS.md`. Config homes:
`~/.claude` + `~/.claude.json`, `~/.codex/config.toml`, `~/.gemini/`,
`~/.copilot/`.

## Verify

Each selected CLI: `--version` prints; auth status confirmed (`claude
doctor`, `codex` `/status`, `gh auth status` unrelated — Copilot CLI has
`/login` state); one trivial prompt answered in a scratch directory.

## Output spec

Done means: selected CLIs installed from one channel each, signed in via
subscription browser flows, versions reported, guardrail paragraph
delivered, and no API keys touched. Note in the summary that this
tool class churns monthly — re-verify install commands against the
reference/vendor docs when they fail.

## Gotchas

- `gh copilot` (the gh extension) is deprecated and archived — the
  standalone `copilot` CLI replaced it; old guides mislead.
- Claude Code via npm needs Node 22+; the native installer needs no Node
  at all — prefer it on fresh machines.
- Brew's `claude-code` cask lags the native channel ~a week and doesn't
  auto-update by default.
- Two installs of the same agent (npm + native) = stale-version confusion;
  `which -a claude` exposes it.
- Grok/Kimi package names are inconsistently mirrored by third parties —
  use the official install scripts, not lookalike npm packages
  (supply-chain risk).

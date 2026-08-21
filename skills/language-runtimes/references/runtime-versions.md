# Runtime & manager facts (verified against primary sources, 2026-08-17)

Point-in-time — re-check the linked sources when versions matter.

## Node.js (nodejs.org/en/about/previous-releases)

- **Active LTS: v24 "Krypton"** (default download; production
  recommendation). Current: v26 (becomes LTS 2026-10). Maintenance: v22.
  From Node 27 the cycle goes annual and every major reaches LTS.
- nvm: latest release **v0.40.6**; install script
  `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash`
  (pin the current tag from github.com/nvm-sh/nvm). Adds `NVM_DIR` +
  source lines to `.zshrc` itself. Slow-startup mitigations are official:
  `--no-use` on the source line; zsh-nvm/chpwd recipes in the README.
  `nvm install --lts`, `nvm alias default 'lts/*'`, `.nvmrc` + `nvm use`.
- fnm (Node-only alternative): `brew install fnm`;
  `eval "$(fnm env --use-on-cd --shell zsh)"`; reads `.nvmrc`/`.node-version`.
- **corepack**: removed from Node ≥ 25 (bundled 14.19–24.x only). On
  Node 24 LTS `corepack enable` still works; else `npm i -g corepack` or
  skip it (pnpm via brew — see web-dev-setup).

## Python (python.org, docs.astral.sh/uv)

- Current stable: **3.14.x** (3.13 still in bugfix; both fine as defaults —
  3.13 has broader binary-wheel coverage).
- **uv** replaces pip/pip-tools/pipx/poetry/pyenv/virtualenv per Astral's
  positioning; MIT/Apache-2.0 (unchanged after OpenAI acquired Astral,
  2026-03). Key commands: `uv python install 3.13`, `uv venv`, `uv init`,
  `uv add`, `uv run`, `uv sync`, `uv tool install <cli>`.
  `uv self update` = standalone installs only; brew → `brew upgrade uv`.
- **pyenv** still maintained; builds CPython from source — macOS deps:
  `brew install openssl readline sqlite3 xz zlib tcl-tk` plus CLT. Init
  lines (README): `PYENV_ROOT`, PATH guard, `eval "$(pyenv init - zsh)"`.
- **pipx**: maintained; `brew install pipx && pipx ensurepath`;
  `pipx upgrade-all`; after a Python upgrade `pipx reinstall-all`.
- **poetry** 2.x: official docs list `pipx install poetry` first.

## Java (adoptium.net/support, whichjdk.com)

- **LTS: JDK 25** (Temurin support ≥ Sept 2031). JDK 21/17 older LTS.
  Next LTS: 29 (two-year cadence). Plain `temurin` cask = **latest JDK
  (26, non-LTS)** — use `temurin@25` / `temurin@21`.
- Temurin cask installs under
  `/Library/Java/JavaVirtualMachines/temurin-<v>.jdk/Contents/Home`;
  enumerate with `/usr/libexec/java_home -V`.
- jenv: `brew install jenv`; init `export PATH="$HOME/.jenv/bin:$PATH"` +
  `eval "$(jenv init -)"`; `jenv add <jdk-home>`; `jenv global|local <v>`
  (writes `.java-version`).
- Homebrew `openjdk@21` (keg-only) caveat prints:
  `sudo ln -sfn $HOMEBREW_PREFIX/opt/openjdk@21/libexec/openjdk.jdk
  /Library/Java/JavaVirtualMachines/openjdk-21.jdk` — required before
  `java_home`/jenv see it.
- SDKMAN alternative: `curl -s "https://get.sdkman.io" | bash`;
  `sdk install java 25.<patch>-tem`.

## mise (mise.jdx.dev)

- `brew install mise`; activate `eval "$(mise activate zsh)"`;
  `mise use -g node@lts python@3.13` (multiple tools per call; `lts`/
  `latest` aliases resolve and pin). Reads `.tool-versions` (asdf-compat).
  **`.nvmrc`/`.node-version` parsing is OFF by default** — enable:
  `mise settings add idiomatic_version_file_enable_tools node`.
- Updates: `mise self-update` is disabled in packaged builds — use
  `brew upgrade mise`; `mise upgrade` bumps tools within configured ranges.

## Rust / Go / Ruby (quick answers)

- Rust: `brew install rustup` (formula no longer named rustup-init), put
  `$(brew --prefix rustup)/bin` on PATH, then `rustup default stable`; or
  the official `curl https://sh.rustup.rs | sh`. Never brew's `rust`
  formula for development. Homebrew's rustup is built no-self-update →
  `rustup update` for toolchains, `brew upgrade rustup` for itself.
- Go: `brew install go` (currently 1.26.x); modules make version managers
  mostly unnecessary; mise handles it if per-project pinning is needed.
- Ruby: `brew install rbenv ruby-build`; `eval "$(rbenv init - zsh)"`.
  macOS still ships system Ruby 2.6 (EOL 2022, immutable) — never use it.

## Conflict diagnosis

```sh
type -a node python3 java     # every path that could win
grep -nE 'nvm|pyenv|jenv|mise|asdf|fnm' ~/.zshrc ~/.zprofile
```

One manager's init per runtime; loser's lines commented out, its data dir
left alone unless the user asks for removal.

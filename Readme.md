# Portaldot DevSuite

Portaldot DevSuite is a zero-configuration, localized development cockpit and runtime engine built explicitly for the Portaldot blockchain network. Engineered to run natively across Windows, macOS, and Linux, this suite removes the friction of compiling massive Substrate nodes locally, managing shifting Rust toolchains, or debugging dependency version mismatches across ink! WASM contracts.

By utilizing unified terminal commands, developers can launch an automated, instant-sealing blockchain sandbox, view live state changes through a full-featured offline block explorer, and instantly build against compile-safe smart contract scaffolds.

## Core Architectural Modules

*   **Deterministic Instant-Sealing Engine:** A local Substrate runtime process configured to execute block production only upon transaction receipt, eliminating background CPU overhead.
*   **Portaldot-Branded Chain Spec:** A custom development chain specification that mirrors the Portaldot network identity, using **POT** tokens with 14 decimals and pre-funded genesis accounts.
*   **Full-Featured Block Explorer:** A locally hosted Polkadot-JS Apps dashboard that auto-connects to your local node, providing a complete UI for account management, extrinsics, and smart contract deployment.
*   **Unified Orchestration Interface:** Cross-platform scripts providing atomic commands to boot infrastructure, monitor runtime health, and wipe state histories cleanly.
*   **Pre-Engineered Contract Blueprint Scaffolds:** Production-ready project templates featuring strict version-pinning for fungible assets and multi-signature coordination logic.

## Directory Structure

See [structure.md](structure.md) for the complete project layout.

*   `bin/` — Location of the optimized, stripped sovereign network binary.
*   `config/` — Custom chain specifications (`portaldot-dev-spec.json`).
*   `dashboard/` — Full Polkadot-JS Apps static build for the offline block explorer.
*   `server/` — Node.js static file server (zero dependencies).
*   `templates/` — Pre-configured contract code structures (Fungible Token and Escrow patterns).
*   `devsuite.sh` / `devsuite.ps1` — The root shell execution controller scripts (POSIX / PowerShell).
*   `user_flow.md` — UX journey mapping documentation.
*   `requirements.md` — Engineering metrics and verification constraints.
*   `implementation.md` — Comprehensive assembly instructions.
*   `structure.md` — Project structure and component mapping.

## Quick Start

No manual binary management or complex toolchains required. The suite auto-downloads the correct node binary on first run.

```bash
npm install
npm run up
```

The local environment will expose an RPC/WS gateway on `ws://localhost:9944` and a visual management interface on `http://localhost:3000`.

### Commands

| Command | Description |
|---------|-------------|
| `npm run up` | Start node + dashboard (auto-downloads binary if missing) |
| `npm run down` | Stop all running services |
| `npm run clean` | Stop services and wipe chain state |
| `npm run status` | Show service status and endpoints |

> **Note:** On first run, the CLI downloads the Substrate node (~60MB) from official Parity releases. Subsequent starts are instant.

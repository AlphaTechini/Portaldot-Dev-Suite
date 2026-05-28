# Portaldot

A localized development environment for Substrate-based blockchain networks. The architecture prioritizes cross-platform compatibility and zero-configuration setup by leveraging WSL2 for node execution and a Node.js-based orchestration layer for lifecycle management.

## Architecture & Design Decisions

### Node Execution via WSL2
The Substrate node binary is executed within a WSL2 environment on Windows hosts, while running natively on Linux/macOS.
*   **Decision:** Pre-compiled binaries are primarily distributed for Linux. Building for Windows natively introduces significant toolchain complexity and maintenance overhead.
*   **Trade-off:** Requires WSL2 on Windows, but eliminates the need for users to compile the node from source or manage Rust toolchains locally.

### Binary Distribution Strategy
The suite auto-downloads the node binary from upstream releases on first run rather than committing artifacts to the repository.
*   **Decision:** Keeps the repository size minimal and ensures users always have the correct binary for their architecture.
*   **Trade-off:** Requires internet access on first run; relies on upstream release stability.

### Dynamic Endpoint Resolution
The dashboard server detects the WSL2 host IP and injects it into the client-side configuration at runtime.
*   **Decision:** WSL2 IPs are ephemeral and change between sessions. Hardcoding breaks connectivity.
*   **Trade-off:** Adds a small startup delay for IP detection, but guarantees reliable WebSocket connections without manual configuration.

### Orchestration Layer
The CLI (`cli.js`) manages process lifecycles, port detection, and binary downloads using Node.js.
*   **Decision:** Node.js is ubiquitous and requires no compilation step for the CLI itself.
*   **Trade-off:** Adds a dependency on Node.js, but removes the need for users to install Go or Rust to run the dev environment.

### Static Asset Serving
The dashboard is served via a lightweight, zero-dependency Node.js server.
*   **Decision:** Minimizes bundle size and attack surface.
*   **Trade-off:** Lacks SSR capabilities, but is sufficient for a local development tool.

## Directory Structure

```
Portaldot/
  bin/            — Node binaries (gitignored, auto-downloaded)
  config/         — Chain specifications
  dashboard/      — Frontend UI and static assets
  examples/       — Sample contract source code
  scripts/        — Build and release automation
  server/         — Static file server
  templates/      — Contract code scaffolds
  cli.js          — Orchestration CLI
  package.json    — Project metadata and scripts
```

## Usage

### Quick Start

```bash
npm install
npm run up
```

The environment exposes an RPC/WS gateway on `ws://localhost:9944` and the dashboard on `http://localhost:3000`.

### Commands

| Command | Description |
|---------|-------------|
| `npm run up` | Start node and dashboard |
| `npm run down` | Stop all services |
| `npm run clean` | Stop services and wipe chain state |
| `npm run status` | Show service status and endpoints |

## Roadmap

*   **Contract Deployment Pipeline:** Integration of a UI flow for uploading compiled `.contract` artifacts, parsing metadata, and instantiating contracts via the dashboard.
*   **Dockerized Node Execution:** Containerized node deployment to remove WSL2 dependency on Windows.
*   **Advanced RPC Methods:** Support for contract interaction methods beyond basic reads.
*   **Telemetry Integration:** Optional metrics export for performance monitoring.

# Portaldot

**The fastest way to build, test, and deploy ink! smart contracts.**

Portaldot is a zero-friction development environment that eliminates the friction of Substrate blockchain development. No more wrestling with Rust toolchains, debugging cross-platform binary incompatibilities, or waiting hours for node compilation. Spin up a fully functional blockchain sandbox in seconds, deploy contracts with a single click, and iterate at the speed of thought.

## Why Portaldot?

Substrate development shouldn't require a PhD in systems programming. Portaldot strips away the complexity and gives you what actually matters:

*   **Instant Setup:** `npm install && npm run up`. That's it. The suite auto-downloads the correct node binary for your platform and handles all the networking magic.
*   **Cross-Platform by Design:** Runs natively on Linux/macOS and seamlessly bridges Windows via WSL2. One codebase, every developer.
*   **Live Contract Interaction:** Upload a compiled `.contract` file and interact with it immediately. No external tools, no context switching.
*   **Pre-Built Templates:** Seven production-ready ink! contracts (ERC-20, NFT, Escrow, Multi-Sig, Voting, Staking, Oracle) ready to copy, customize, and deploy.

## Architecture

### Zero-Config Node Orchestration
The CLI manages the entire lifecycle of your local blockchain. It detects your OS, fetches the appropriate pre-compiled binary, and launches the node with optimized flags for instant sealing. On Windows, it seamlessly routes execution through WSL2, abstracting away the complexity of cross-platform binary distribution.

### Dynamic Network Resolution
WSL2 assigns ephemeral IP addresses that break traditional localhost assumptions. Portaldot's server detects the active WSL interface at startup and injects the correct WebSocket endpoint into the dashboard. You never have to touch a config file.

### Static-First Dashboard
The UI is served by a lightweight, zero-dependency Node.js server. It loads `@polkadot/api` dynamically via CDN, keeping the initial payload minimal while providing full Substrate RPC capabilities. The dashboard parses contract metadata client-side, generating deployment forms and interaction panels on the fly.

### Binary Distribution Strategy
We don't bloat the repository with 60MB binaries. Instead, the suite fetches official upstream releases on first run. This keeps clone times instant and ensures you're always running the verified, audited node version.

## Getting Started

```bash
npm install
npm run up
```

Your blockchain is live. Open `http://localhost:3000` and start building.

### Commands

| Command | Description |
|---------|-------------|
| `npm run up` | Launch node + dashboard |
| `npm run down` | Gracefully stop all services |
| `npm run clean` | Wipe chain state and restart fresh |
| `npm run status` | Inspect running services and endpoints |

## What's Next

Portaldot is actively evolving. Here's what's on the horizon:

*   **One-Click Contract Deployment:** Drag-and-drop `.contract` files directly into the dashboard. Auto-generated forms, gas estimation, and instant instantiation.
*   **Dockerized Execution:** Run the node in an isolated container. No WSL required on Windows, consistent environments across teams.
*   **Advanced Contract Debugging:** Step-through execution, storage inspection, and event replay for complex ink! logic.
*   **Multi-Network Support:** Switch between local dev, testnet, and custom chain specs without restarting.

## Join the Build

Portaldot is built for developers who refuse to let tooling slow them down. If you're shipping ink! contracts, this is your new baseline.

[Explore the templates](templates/) · [Read the architecture](structure.md) · [Contribute](https://github.com/AlphaTechini/Portaldot-Dev-Suite)

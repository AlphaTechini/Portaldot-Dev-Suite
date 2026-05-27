# dashboard/

Full Polkadot-JS Apps static build for the offline block explorer and administrative interface.

## Current State

This directory contains the complete Polkadot-JS Apps UI, ready to be served locally. It includes all necessary JavaScript bundles, WebAssembly modules, and styling required to run a fully functional blockchain explorer.

## How it's served

The Node.js static file server (`server/server.js`) serves these assets on port 3000. No build step or framework is involved — pure static file serving.

## Auto-Connection

The dashboard is configured to auto-detect and connect to `ws://localhost:9944` (the default Portaldot DevSuite RPC endpoint). When you open `http://localhost:3000` in your browser, the UI will automatically establish a WebSocket connection to your local node.

## Features Available
- **Account Management:** View balances, send transfers, and manage pre-funded genesis accounts (Alice, Bob, etc.).
- **Extrinsics Explorer:** Browse all transactions, inspect block contents, and view chain state.
- **Smart Contract Deployment:** Use the "Contracts" tab to upload and instantiate ink! WASM contracts from the `templates/` directory.
- **Chain Metadata:** Reads the custom `portaldot-dev-spec.json` metadata, displaying **POT** tokens with 14 decimals.

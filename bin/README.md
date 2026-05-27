# bin/

Platform-specific Portaldot node binaries. Each subdirectory contains a stripped, release-mode compiled binary for a target OS/architecture.

## Structure

```
bin/
  linux-x64/     — Portaldot node for Linux x86_64
  macos-arm64/   — Portaldot node for macOS Apple Silicon
  macos-x64/     — Portaldot node for macOS Intel
  windows-x64/   — Portaldot node for Windows x64
```

## How binaries are produced

1. Clone the Portaldot upstream repo into an isolated Docker volume
2. Audit dependencies via `Cargo.lock`
3. Compile inside the container: `cargo build --locked --release -p node-template`
4. Strip the binary: `strip portaldot-node`
5. Copy to the matching `bin/<platform>/` directory

The CLI scripts (`devsuite.sh` / `devsuite.ps1`) auto-detect the host OS and select the correct binary.

## Expected binary name

- Linux/macOS: `portaldot-node`
- Windows: `portaldot-node.exe`

## Launch flags used by the DevSuite

```
--dev                    Development chain with pre-funded accounts
--instant-sealing        Block production only on transaction receipt
--ws-port 9944           WebSocket RPC port
--rpc-port 9944          HTTP RPC port
--base-path <dir>        Chain data directory
--tmp                    Use temporary directory for chain data
--no-hardware-benchmarks Disable hardware benchmarking
--offchain-worker never  Disable offchain workers
```

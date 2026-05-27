# scripts/

Helper scripts for building and releasing Portaldot components.

## build-node.sh

Builds the substrate-contracts-node binary for multiple platforms using Docker.

### Usage

```bash
# Build for all platforms
./scripts/build-node.sh

# Build for a specific platform
./scripts/build-node.sh linux-x64
./scripts/build-node.sh macos-arm64
./scripts/build-node.sh macos-x64
```

### Requirements

- Docker with multi-platform support (or Docker Buildx)
- Rust toolchain (pulled inside container)
- ~4GB disk space per build

### Output

Binaries are placed in `bin/<platform>/polkadot`.

## release.sh

Creates a GitHub Release and uploads binaries for each platform.

### Usage

```bash
# Create a release with pre-built binaries
./scripts/release.sh v1.0.0
```

### Requirements

- `gh` CLI authenticated
- Binaries already built in `bin/<platform>/`

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BIN_DIR="$PROJECT_DIR/bin"

TAG="v0.9.0"
REPO="paritytech/substrate-contracts-node"

declare -A TARGETS=(
    ["linux-x64"]="linux/amd64"
    ["macos-arm64"]="linux/arm64"
    ["macos-x64"]="linux/amd64"
)

usage() {
    echo "Usage: $0 [platform|all]"
    echo ""
    echo "Platforms: linux-x64, macos-arm64, macos-x64, all"
    echo ""
    echo "Builds the substrate-contracts-node binary for the specified platform"
    echo "and places it in bin/<platform>/polkadot"
    exit 1
}

build_platform() {
    local platform="$1"
    local target="${TARGETS[$platform]:-}"

    if [[ -z "$target" ]]; then
        echo "Error: Unknown platform '$platform'" >&2
        exit 1
    fi

    local platform_dir="$BIN_DIR/$platform"
    mkdir -p "$platform_dir"

    echo "Building for $platform ($target)..."

    local tmp_dir
    tmp_dir=$(mktemp -d)

    docker run --rm --platform "$target" \
        -v "$tmp_dir:/output" \
        rust:1.75-slim \
        bash -c "
            set -euo pipefail
            apt-get update && apt-get install -y --no-install-recommends protobuf-compiler clang
            rustup target add wasm32-unknown-unknown
            git clone --depth 1 --branch $TAG https://github.com/$REPO.git /src
            cd /src
            cargo build --locked --release -p node-template
            strip target/release/node-template
            cp target/release/node-template /output/polkadot
        "

    mv "$tmp_dir/polkadot" "$platform_dir/polkadot"
    chmod +x "$platform_dir/polkadot"
    rm -rf "$tmp_dir"

    echo "Binary placed at: $platform_dir/polkadot"
    ls -lh "$platform_dir/polkadot"
}

case "${1:-all}" in
    linux-x64|macos-arm64|macos-x64)
        build_platform "$1"
        ;;
    all)
        for platform in "${!TARGETS[@]}"; do
            build_platform "$platform"
        done
        ;;
    *)
        usage
        ;;
esac

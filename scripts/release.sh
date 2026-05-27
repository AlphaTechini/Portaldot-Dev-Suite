#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BIN_DIR="$PROJECT_DIR/bin"

if ! command -v gh &>/dev/null; then
    echo "Error: gh CLI is required. Install: https://cli.github.com/" >&2
    exit 1
}

if [[ -z "${1:-}" ]]; then
    echo "Usage: $0 <tag>"
    echo ""
    echo "Example: $0 v1.0.0"
    echo ""
    echo "Creates a GitHub Release and uploads all binaries from bin/<platform>/polkadot"
    exit 1
}

TAG="$1"

PLATFORMS=("linux-x64" "macos-arm64" "macos-x64")

echo "Creating release $TAG..."

gh release create "$TAG" --generate-notes --draft

for platform in "${PLATFORMS[@]}"; do
    binary="$BIN_DIR/$platform/polkadot"
    if [[ ! -f "$binary" ]]; then
        echo "Warning: No binary found for $platform, skipping..." >&2
        continue
    fi

    archive_name="portaldot-node-${platform}.tar.gz"
    tmp_dir=$(mktemp -d)
    cp "$binary" "$tmp_dir/polkadot"
    tar -czf "$tmp_dir/$archive_name" -C "$tmp_dir" polkadot

    echo "Uploading $archive_name..."
    gh release upload "$TAG" "$tmp_dir/$archive_name"

    rm -rf "$tmp_dir"
done

echo "Release $TAG created. Review and publish at:"
gh release view "$TAG" --web

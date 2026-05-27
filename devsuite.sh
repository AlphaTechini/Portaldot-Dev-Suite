#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
DASHBOARD_DIR="$SCRIPT_DIR/dashboard"
SERVER_DIR="$SCRIPT_DIR/server"
PID_DIR="$SCRIPT_DIR/.pids"
STATE_DIR="$SCRIPT_DIR/.state"

NODE_PORT=9944
DASHBOARD_PORT=3000

RELEASE_BASE="https://github.com/paritytech/substrate-contracts-node/releases/download/v0.9.0"

declare -A RELEASE_URLS=(
    ["linux-x64"]="${RELEASE_BASE}/substrate-contracts-node-linux.tar.gz"
    ["macos-x64"]="${RELEASE_BASE}/substrate-contracts-node-mac.tar.gz"
    ["macos-arm64"]="${RELEASE_BASE}/substrate-contracts-node-mac.tar.gz"
)

detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux-x64" ;;
        Darwin*)
            case "$(uname -m)" in
                arm64|aarch64) echo "macos-arm64" ;;
                *)             echo "macos-x64" ;;
            esac
            ;;
        *) echo "unsupported" ;;
    esac
}

download_binary() {
    local platform="$1"
    local release_url="${RELEASE_URLS[$platform]:-}"

    if [[ -z "$release_url" ]]; then
        echo "Error: No pre-built binary available for $platform." >&2
        echo "Build from source and place it in: $BIN_DIR/$platform/" >&2
        exit 1
    fi

    local platform_dir="$BIN_DIR/$platform"
    mkdir -p "$platform_dir"

    local tmp_dir
    tmp_dir=$(mktemp -d)
    local archive="$tmp_dir/node.tar.gz"

    echo "Downloading node binary for $platform..."
    if command -v curl &>/dev/null; then
        curl -fSL --progress-bar "$release_url" -o "$archive"
    elif command -v wget &>/dev/null; then
        wget -q --show-progress -O "$archive" "$release_url"
    else
        echo "Error: curl or wget required for download." >&2
        exit 1
    fi

    echo "Extracting..."
    tar -xzf "$archive" -C "$tmp_dir"

    local extracted_name
    extracted_name=$(find "$tmp_dir" -maxdepth 1 -type f -executable | head -n1 | xargs basename)

    if [[ -z "$extracted_name" ]]; then
        echo "Error: Failed to extract executable from archive." >&2
        rm -rf "$tmp_dir"
        exit 1
    fi

    mv "$tmp_dir/$extracted_name" "$platform_dir/polkadot"
    chmod +x "$platform_dir/polkadot"
    rm -rf "$tmp_dir"

    echo "Binary installed to $platform_dir/polkadot"
}

find_binary() {
    local platform
    platform="$(detect_os)"
    if [[ "$platform" == "unsupported" ]]; then
        echo "Error: Unsupported operating system." >&2
        exit 1
    fi

    local bin_path="$BIN_DIR/$platform/polkadot"
    if [[ ! -f "$bin_path" ]]; then
        download_binary "$platform"
        bin_path="$BIN_DIR/$platform/polkadot"
    fi

    if [[ ! -f "$bin_path" ]]; then
        echo "Error: Node binary not found at $bin_path" >&2
        echo "Place the compiled node binary in: $BIN_DIR/$platform/" >&2
        exit 1
    fi
    echo "$bin_path"
}

ensure_dirs() {
    mkdir -p "$PID_DIR" "$STATE_DIR"
}

cmd_up() {
    ensure_dirs

    if [[ -f "$PID_DIR/node.pid" ]]; then
        local old_pid
        old_pid=$(cat "$PID_DIR/node.pid" 2>/dev/null || true)
        if kill -0 "$old_pid" 2>/dev/null; then
            echo "Node already running (PID: $old_pid)"
        else
            rm -f "$PID_DIR/node.pid"
        fi
    fi

    if [[ -f "$PID_DIR/server.pid" ]]; then
        local old_pid
        old_pid=$(cat "$PID_DIR/server.pid" 2>/dev/null || true)
        if kill -0 "$old_pid" 2>/dev/null; then
            echo "Dashboard server already running (PID: $old_pid)"
        else
            rm -f "$PID_DIR/server.pid"
        fi
    fi

    local node_bin
    node_bin="$(find_binary)"
    echo "Starting Portaldot node ($(detect_os))..."

    setsid "$node_bin" \
        --dev \
        --rpc-port "$NODE_PORT" \
        --rpc-cors all \
        >> "$STATE_DIR/node.log" 2>&1 &
    echo $! > "$PID_DIR/node.pid"

    sleep 1

    echo "Starting dashboard server..."
    setsid node "$SERVER_DIR/server.js" "$DASHBOARD_DIR" "$DASHBOARD_PORT" \
        >> "$STATE_DIR/server.log" 2>&1 &
    echo $! > "$PID_DIR/server.pid"

    sleep 1

    echo ""
    echo "Portaldot DevSuite is running."
    echo "  RPC/WS endpoint: ws://localhost:$NODE_PORT"
    echo "  Dashboard:       http://localhost:$DASHBOARD_PORT"
    echo "  Node PID:        $(cat "$PID_DIR/node.pid")"
    echo "  Server PID:      $(cat "$PID_DIR/server.pid")"
    echo ""
    echo "Run './devsuite.sh down' to stop."
}

cmd_down() {
    if [[ -f "$PID_DIR/node.pid" ]]; then
        local pid
        pid=$(cat "$PID_DIR/node.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Stopping node (PID: $pid)..."
            kill "$pid" 2>/dev/null || true
            sleep 1
            kill -9 "$pid" 2>/dev/null || true
        fi
        rm -f "$PID_DIR/node.pid"
    fi

    if [[ -f "$PID_DIR/server.pid" ]]; then
        local pid
        pid=$(cat "$PID_DIR/server.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Stopping dashboard server (PID: $pid)..."
            kill "$pid" 2>/dev/null || true
            sleep 1
            kill -9 "$pid" 2>/dev/null || true
        fi
        rm -f "$PID_DIR/server.pid"
    fi

    echo "All services stopped."
}

cmd_clean() {
    cmd_down
    echo "Wiping chain state..."
    rm -rf "$STATE_DIR/chain"
    rm -f "$STATE_DIR/node.log" "$STATE_DIR/server.log"
    echo "Chain state cleared. Network reset to block zero."
}

cmd_status() {
    echo "=== Portaldot DevSuite Status ==="
    echo ""

    local node_pid="" server_pid=""
    [[ -f "$PID_DIR/node.pid" ]] && node_pid=$(cat "$PID_DIR/node.pid")
    [[ -f "$PID_DIR/server.pid" ]] && server_pid=$(cat "$PID_DIR/server.pid")

    if [[ -n "$node_pid" ]] && kill -0 "$node_pid" 2>/dev/null; then
        echo "Node:          RUNNING (PID: $node_pid)"
    else
        echo "Node:          STOPPED"
        [[ -n "$node_pid" ]] && rm -f "$PID_DIR/node.pid"
    fi

    if [[ -n "$server_pid" ]] && kill -0 "$server_pid" 2>/dev/null; then
        echo "Dashboard:     RUNNING (PID: $server_pid)"
    else
        echo "Dashboard:     STOPPED"
        [[ -n "$server_pid" ]] && rm -f "$PID_DIR/server.pid"
    fi

    echo ""
    echo "Endpoints:"
    echo "  RPC/WS: ws://localhost:$NODE_PORT"
    echo "  UI:     http://localhost:$DASHBOARD_PORT"
    echo ""

    if [[ -f "$STATE_DIR/chain/chains/dev/local.db" ]]; then
        local db_size
        db_size=$(du -sh "$STATE_DIR/chain" 2>/dev/null | cut -f1)
        echo "Chain data:  $db_size"
    else
        echo "Chain data:  None (genesis state)"
    fi
}

case "${1:-}" in
    up)     cmd_up ;;
    down)   cmd_down ;;
    clean)  cmd_clean ;;
    status) cmd_status ;;
    *)
        echo "Usage: $0 {up|down|clean|status}"
        echo ""
        echo "Commands:"
        echo "  up      Start node and dashboard"
        echo "  down    Stop all services"
        echo "  clean   Stop services and wipe chain state"
        echo "  status  Show service status and endpoints"
        exit 1
        ;;
esac

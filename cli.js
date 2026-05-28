#!/usr/bin/env node
import { spawn, execSync } from "node:child_process";
import { existsSync, readFileSync, writeFileSync, mkdirSync, rmSync, readdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { platform, arch } from "node:os";
import { pipeline } from "node:stream/promises";
import { createWriteStream } from "node:fs";
import { get } from "node:https";

const __dirname = dirname(fileURLToPath(import.meta.url));
const BIN_DIR = join(__dirname, "bin");
const STATE_DIR = join(__dirname, ".state");
const PID_DIR = join(__dirname, ".pids");
const SERVER_DIR = join(__dirname, "server");
const DASHBOARD_DIR = join(__dirname, "dashboard");

const NODE_PORT = 9944;
const DASHBOARD_PORT = 3000;

const RELEASES = {
  linux: {
    x64: "https://github.com/paritytech/substrate-contracts-node/releases/download/v0.9.0/substrate-contracts-node-linux.tar.gz",
    arm64: "https://github.com/paritytech/substrate-contracts-node/releases/download/v0.9.0/substrate-contracts-node-linux.tar.gz",
  },
  darwin: {
    x64: "https://github.com/paritytech/substrate-contracts-node/releases/download/v0.9.0/substrate-contracts-node-mac.tar.gz",
    arm64: "https://github.com/paritytech/substrate-contracts-node/releases/download/v0.9.0/substrate-contracts-node-mac.tar.gz",
  },
  win32: {
    x64: null,
  },
};

function log(msg) { console.log(`\x1b[32m✓\x1b[0m ${msg}`); }
function warn(msg) { console.log(`\x1b[33m⚠\x1b[0m ${msg}`); }
function err(msg) { console.error(`\x1b[31m✗\x1b[0m ${msg}`); process.exit(1); }

function getPlatform() {
  const os = platform();
  const a = arch();
  if (os === "win32") return { os: "win32", arch: "x64", binName: "polkadot", platformDir: "linux-x64", wsl: true };
  return {
    os,
    arch: a === "arm64" ? "arm64" : "x64",
    binName: "polkadot",
    platformDir: `${os === "darwin" ? "macos" : "linux"}-${a === "arm64" ? "arm64" : "x64"}`,
    wsl: false,
  };
}

async function downloadBinary(url, dest) {
  log(`Downloading node binary...`);
  const tmpDir = join(dirname(dest), ".tmp_download");
  mkdirSync(tmpDir, { recursive: true });
  const archive = join(tmpDir, "node.tar.gz");

  await new Promise((resolve, reject) => {
    get(url, (r) => {
      if (r.statusCode === 302 || r.statusCode === 301) {
        get(r.headers.location, resolve).on("error", reject);
      } else if (r.statusCode === 200) {
        resolve(r);
      } else {
        reject(new Error(`HTTP ${r.statusCode}`));
      }
    }).on("error", reject);
  }).then((res) => pipeline(res, createWriteStream(archive)));

  log("Extracting...");
  execSync(`tar -xzf "${archive}" -C "${tmpDir}"`, { stdio: "inherit" });

  const files = readdirSync(tmpDir);
  const extracted = files.find((f) => f.includes("substrate") || f.includes("node"));
  if (!extracted) err("Failed to locate binary in archive.");

  const src = join(tmpDir, extracted);
  writeFileSync(dest, readFileSync(src));
  rmSync(tmpDir, { recursive: true, force: true });
  if (platform() !== "win32") execSync(`chmod +x "${dest}"`);
  log("Binary downloaded and extracted.");
}

async function ensureBinary() {
  const { os, arch, binName, platformDir } = getPlatform();
  const dir = join(BIN_DIR, platformDir);
  const bin = join(dir, binName);

  if (existsSync(bin)) return bin;

  const url = RELEASES[os]?.[arch];
  if (!url) err(`No pre-built binary for ${os}/${arch}. Please build from source or use WSL/Docker.`);

  mkdirSync(dir, { recursive: true });
  await downloadBinary(url, bin);
  return bin;
}

function getPid(name) {
  const p = join(PID_DIR, `${name}.pid`);
  if (!existsSync(p)) return null;
  const pid = parseInt(readFileSync(p, "utf8").trim());
  try { process.kill(pid, 0); return pid; } catch { rmSync(p); return null; }
}

function savePid(name, pid) {
  mkdirSync(PID_DIR, { recursive: true });
  writeFileSync(join(PID_DIR, `${name}.pid`), String(pid));
}

function waitForPort(child, timeout = 30000) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error("Node startup timed out")), timeout);

    const check = (data) => {
      const text = data.toString();
      // "Listening for new connections on 0.0.0.0:9944." or "Listening for new connections on 0.0.0.0:33673."
      const match = text.match(/Listening for new connections on [\d.]+:(\d+)/);
      if (match) {
        clearTimeout(timer);
        resolve(parseInt(match[1]));
      }
    };

    child.stdout.on("data", check);
    child.stderr.on("data", check);
  });
}

async function cmdUp() {
  const { wsl, platformDir } = getPlatform();
  const bin = await ensureBinary();
  mkdirSync(STATE_DIR, { recursive: true });

  let wsPort = NODE_PORT;
  let nodeChild = null;

  if (getPid("node")) {
    warn("Node already running.");
  } else {
    log(`Starting Portaldot node...`);

    const args = [
      "--dev",
      "--ws-port", String(NODE_PORT),
      "--ws-external",
      "--rpc-port", String(NODE_PORT),
      "--rpc-cors", "all",
      "--tmp",
      "--offchain-worker", "never",
    ];

    if (wsl) {
      const wslPath = bin.replace(/\\/g, "/").replace(/^([A-Z]):/, "/mnt/$1").toLowerCase();
      nodeChild = spawn("wsl", [wslPath, ...args], {
        stdio: ["ignore", "pipe", "pipe"],
        detached: false,
      });
    } else {
      nodeChild = spawn(bin, args, {
        stdio: ["ignore", "pipe", "pipe"],
        detached: false,
      });
    }

    try {
      wsPort = await waitForPort(nodeChild);
    } catch (e) {
      warn(`Node startup warning: ${e.message}`);
    }

    nodeChild.stdout.on("data", (d) => process.stdout.write(d));
    nodeChild.stderr.on("data", (d) => process.stderr.write(d));
    nodeChild.unref();
    savePid("node", nodeChild.pid);
  }

  if (getPid("server")) {
    warn("Dashboard server already running.");
  } else {
    log(`Starting dashboard on http://localhost:${DASHBOARD_PORT}...`);
    const child = spawn("node", [
      join(SERVER_DIR, "server.cjs"),
      DASHBOARD_DIR,
      String(DASHBOARD_PORT),
      String(wsPort),
    ], {
      stdio: "inherit",
      detached: true,
    });
    child.unref();
    savePid("server", child.pid);
  }

  log(`\nPortaldot DevSuite is running!`);
  log(`  RPC/WS: ws://localhost:${wsPort}`);
  log(`  Dashboard: http://localhost:${DASHBOARD_PORT}`);
}

function cmdDown() {
  const isWin = platform() === "win32";

  log("Stopping node...");
  if (isWin) {
    try {
      execSync("wsl -e pkill -f polkadot 2>/dev/null || true", { stdio: "ignore" });
    } catch {
      // Ignore errors from pkill
    }
  }

  ["node", "server"].forEach((name) => {
    const pid = getPid(name);
    if (pid) {
      try {
        process.kill(pid, isWin ? "SIGTERM" : "SIGINT");
        log(`Stopped ${name}.`);
      } catch {
        log(`${name} was already stopped.`);
      }
      rmSync(join(PID_DIR, `${name}.pid`), { force: true });
    } else {
      log(`${name} was already stopped.`);
    }
  });
}
  }

  ["node", "server"].forEach((name) => {
    const pid = getPid(name);
    if (pid) {
      try {
        process.kill(pid, isWin ? "SIGTERM" : "SIGINT");
        log(`Stopped ${name} (PID: ${pid})`);
      } catch {
        warn(`${name} already stopped.`);
      }
      rmSync(join(PID_DIR, `${name}.pid`), { force: true });
    }
  });
}

function cmdClean() {
  cmdDown();
  if (existsSync(STATE_DIR)) {
    rmSync(STATE_DIR, { recursive: true, force: true });
    log("Chain state wiped.");
  }
}

function cmdStatus() {
  console.log("\n=== Portaldot DevSuite Status ===\n");
  const nodePid = getPid("node");
  const serverPid = getPid("server");

  console.log(`Node:      ${nodePid ? `RUNNING (PID: ${nodePid})` : "STOPPED"}`);
  console.log(`Dashboard: ${serverPid ? `RUNNING (PID: ${serverPid})` : "STOPPED"}`);
  console.log(`\nEndpoints:`);
  console.log(`  RPC/WS: ws://localhost:${NODE_PORT}`);
  console.log(`  UI:     http://localhost:${DASHBOARD_PORT}`);

  const chainDb = join(STATE_DIR, "chain", "chains", "dev", "local.db");
  if (existsSync(chainDb)) {
    console.log(`\nChain data: exists`);
  } else {
    console.log(`\nChain data: None (genesis state)`);
  }
}

const cmd = process.argv[2];
switch (cmd) {
  case "up": await cmdUp(); break;
  case "down": cmdDown(); break;
  case "clean": cmdClean(); break;
  case "status": cmdStatus(); break;
  default:
    console.log("Usage: portaldot <up|down|clean|status>");
    process.exit(1);
}

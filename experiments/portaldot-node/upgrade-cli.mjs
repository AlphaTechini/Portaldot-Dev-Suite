// Patch script: upgrade cli.js to substrate-contracts-node v0.39.0
// Run: node experiments/portaldot-node/upgrade-cli.mjs

import { readFileSync, writeFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = join(__dirname, "..", "..");
const cliPath = join(rootDir, "cli.js");

let content = readFileSync(cliPath, "utf8");

// Update release URLs from v0.9.0 to v0.39.0
const oldUrl = "https://github.com/paritytech/substrate-contracts-node/releases/download/v0.9.0";
const newUrl = "https://github.com/paritytech/substrate-contracts-node/releases/download/v0.39.0";

if (!content.includes(oldUrl)) {
    console.log("cli.js already updated or URLs don't match expected pattern.");
    console.log("Manual check needed.");
    process.exit(0);
}

content = content.replaceAll(oldUrl, newUrl);

// Also update the archive names since they changed between versions
content = content.replaceAll("substrate-contracts-node-mac.tar.gz", "substrate_contracts_node_macos.tar.gz");
content = content.replaceAll("substrate-contracts-node-linux.tar.gz", "substrate_contracts_node_linux_x86_64.tar.gz");

writeFileSync(cliPath, content);
console.log("cli.js updated to substrate-contracts-node v0.39.0");
console.log("");
console.log("Next steps:");
console.log("1. Stop current node: pnpm run down");
console.log("2. Remove old binary: rmdir /s /q bin\\linux-x64");
console.log("3. Start updated node: pnpm run up");
console.log("4. The new node supports ink! v5 contracts natively.");

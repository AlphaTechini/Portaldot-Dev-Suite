# Experiments Directory

## What we did

1. **Committed main project changes** - raw extrinsics, gas fix, static contracts UI
2. **Created experiment workspace** with:
   - `portaldot-node/` - Alternative node setups (WSL, Docker)
   - `contracts-v5/` - Clean ink! v5 auction contract for testing
3. **Patched cli.js** to use `substrate-contracts-node v0.39.0` (supports ink! v5)

## Current Blockers

### No Native Windows Binary
- Portaldot: No Windows build (WSL or Docker only)
- substrate-contracts-node: No Windows build (Linux/macOS only)

### What This Means
Your `pnpm run up` uses WSL behind the scenes (`wsl: true` in cli.js) to run the Linux binary.

## Ready to Test

### Option A: Test with upgraded node (Recommended)
```powershell
# 1. Stop current node
pnpm run down

# 2. Clear old binary (forces re-download)
Remove-Item -Recurse -Force "C:\Hackathons\Portaldot\bin\linux-x64"

# 3. Start with new version
pnpm run up
# This will download substrate-contracts-node v0.39.0

# 4. Deploy your ink! v5 contract via dashboard
# http://localhost:3000
```

### Option B: Portaldot native node via WSL
```powershell
# Run as Administrator
.\experiments\portaldot-node\setup-wsl.ps1
```

### Option C: Portaldot native node via Docker
```powershell
cd experiments\portaldot-node
.\start-docker.bat
```

## Which to choose?

**Option A is fastest** - just 3 commands, uses your existing setup. The v0.39.0 node supports ink! v5 natively, so your already-compiled auction contract should deploy without `CodeRejected`.

**Option B/C** only if you specifically need the Portaldot native binary for mainnet compatibility testing.

## Next Step

Run Option A and try deploying the auction contract again. The `contracts.CodeRejected` error should be gone because v0.39.0 includes ink! v5 runtime support.

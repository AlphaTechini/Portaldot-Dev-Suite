# ink! v4 Contract Build Setup

## Why This Exists

Both the current `substrate-contracts-node v0.9.0` AND the Portaldot native binary use **old pallet-contracts** (ink! v3/v4 era). They have APIs like `rent_projection`, `claim_surcharge`, `seal_set_rent_allowance` that ink! v5 removed entirely.

**Conclusion:** We MUST produce an ink! v4 contract, not v5.

## The Problem on Your Machine

- `cargo-contract v5.0.3` (installed) refuses to build ink! v4 properly
- Rust 1.96+ broke `panic = "abort"` for wasm targets, causing `panic_immediate_abort` compile error
- `cargo-contract v3.2.0` is the last version that supports ink! v4, but installing it hits a yanked crate dependency

## Two Build Paths

### Option 1: Docker (Most Reliable)

```powershell
# From project root
cd C:\Hackathons\Portaldot
.\experiments\contracts-v5\build-docker.ps1
```

**What it does:**
- Builds a Docker image with `Rust 1.75` + `cargo-contract v3.2.0`
- Mounts `experiments/contracts-v5/auction` into the container
- Compiles the contract inside the isolated environment
- Outputs `target/ink/auction.contract`

**Requirements:** Docker Desktop installed and running

### Option 2: Pinned Nightly Rust (Faster if you have rustup)

```powershell
# From project root
cd C:\Hackathons\Portaldot
.\experiments\contracts-v5\build-nightly.ps1
```

**What it does:**
- Installs `nightly-2024-01-01` toolchain (predates the panic strategy conflict)
- Installs `cargo-contract v3.2.0` under that toolchain
- Builds the contract

**Requirements:** rustup already installed

## Contract Source

The contract in `experiments/contracts-v5/auction/` is already ink! v4.3.0:
- `Cargo.toml`: `ink = "4.3.0"`
- `lib.rs`: Uses `#![cfg_attr(not(feature = "std"), no_std)]` (no `no_main`)
- No `panic = "abort"` in profile (avoids Rust 1.96 conflict)

## After Building

Once you have `auction.contract`, upload it via:
```
http://localhost:3000 → Contracts tab
```

The deploy should work because:
- The contract is ink! v4 (compatible with old runtime)
- The gas limit uses `* 1e12` (weight units, not POT)
- The raw extrinsics code is correct and tested

## Which Option to Pick?

| | Docker | Nightly |
|---|---|---|
| Speed | Slow first run (image build), fast after | Medium (toolchain install) |
| Reliability | Guaranteed isolation | Depends on nightly availability |
| Disk | ~2GB Docker image | ~500MB toolchain |
| **Recommendation** | **Use this** | Fallback if Docker unavailable |

## Next Step

Run **Option 1 (Docker)** now:
```powershell
.\experiments\contracts-v5\build-docker.ps1
```

If Docker isn't available, try **Option 2 (Nightly)**:
```powershell
.\experiments\contracts-v5\build-nightly.ps1
```

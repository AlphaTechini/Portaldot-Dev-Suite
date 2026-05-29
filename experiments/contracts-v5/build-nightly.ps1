#Requires -Version 5.1
# Build ink! v4 contract using pinned nightly Rust toolchain
# Faster than Docker if you already have rustup installed

param(
    [string]$ContractDir = ".\experiments\contracts-v5\auction",
    [string]$NightlyDate = "nightly-2024-01-01"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot | Split-Path -Parent
$contractPath = Join-Path $root $ContractDir

if (-not (Test-Path $contractPath)) {
    Write-Error "Contract directory not found: $contractPath"
}

Write-Host "Building ink! v4 contract with pinned nightly..." -ForegroundColor Cyan
Write-Host "Toolchain: $NightlyDate" -ForegroundColor Gray
Write-Host "Contract: $contractPath" -ForegroundColor Gray

# Check rustup
$rustup = Get-Command rustup -ErrorAction SilentlyContinue
if (-not $rustup) {
    Write-Error "rustup not found. Install from https://rustup.rs/"
}

# Install toolchain if missing
$installed = rustup toolchain list | Select-String $NightlyDate
if (-not $installed) {
    Write-Host "Installing $NightlyDate..." -ForegroundColor Yellow
    rustup install $NightlyDate --no-self-update
}

# Install wasm target
Write-Host "Adding wasm32-unknown-unknown target..." -ForegroundColor Yellow
rustup target add wasm32-unknown-unknown --toolchain $NightlyDate

# Install cargo-contract v3.2.0 under this toolchain
Write-Host "Installing cargo-contract v3.2.0..." -ForegroundColor Yellow
# Use --debug for faster install, since we're just building a contract
$env:RUSTUP_TOOLCHAIN = $NightlyDate
cargo install cargo-contract --version 3.2.0 --debug --locked

# Build
Write-Host "Building contract..." -ForegroundColor Yellow
Push-Location $contractPath
cargo +$NightlyDate contract build --release
Pop-Location

$artifact = Join-Path $contractPath "target\ink\auction.contract"
if (Test-Path $artifact) {
    Write-Host "SUCCESS: Built $artifact" -ForegroundColor Green
} else {
    Write-Warning "Build completed but .contract artifact not found."
}

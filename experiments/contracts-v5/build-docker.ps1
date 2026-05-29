#Requires -Version 5.1
# Build ink! v4 contract in Docker to avoid host toolchain hell
# Prerequisites: Docker Desktop installed and running

param(
    [string]$ContractDir = ".\experiments\contracts-v5\auction",
    [switch]$NoCache
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot | Split-Path -Parent
$dockerfile = Join-Path $root "experiments\contracts-v5\Dockerfile.ink4"
$contractPath = Join-Path $root $ContractDir

if (-not (Test-Path $contractPath)) {
    Write-Error "Contract directory not found: $contractPath"
}

Write-Host "Building ink! v4 contract via Docker..." -ForegroundColor Cyan
Write-Host "Contract: $contractPath" -ForegroundColor Gray

# Check Docker
$dockerInfo = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker is not running. Start Docker Desktop first."
}

# Build image once (fast after first run)
if ($NoCache -or -not (docker images -q ink4-builder 2>$null)) {
    Write-Host "Building Docker image (cargo-contract v3.2.0 + Rust 1.75)..." -ForegroundColor Yellow
    docker build -t ink4-builder -f "$dockerfile" "$root\experiments\contracts-v5"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Docker image build failed."
    }
}

# Run build container
Write-Host "Compiling contract in container..." -ForegroundColor Yellow
$absPath = Resolve-Path $contractPath
$linuxPath = $absPath.Path -replace "^([A-Z]):", "/mnt/$1" -replace "\\", "/"

docker run --rm -v "${absPath}:/contract" ink4-builder build --release
if ($LASTEXITCODE -ne 0) {
    Write-Error "Contract build failed inside Docker container."
}

$artifact = Join-Path $contractPath "target\ink\auction.contract"
if (Test-Path $artifact) {
    Write-Host "SUCCESS: Built $artifact" -ForegroundColor Green
    Write-Host "Size: $((Get-Item $artifact).Length / 1KB) KB" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Deploy via dashboard: http://localhost:3000" -ForegroundColor Cyan
} else {
    Write-Warning "Build completed but .contract artifact not found at expected path."
    Write-Warning "Check $contractPath\target\ink\ for output files."
}

#Requires -RunAsAdministrator
# Setup Portaldot node in WSL2

$ErrorActionPreference = "Stop"

Write-Host "Checking WSL2 status..." -ForegroundColor Cyan

$wslInstalled = Get-Command wsl -ErrorAction SilentlyContinue
if (-not $wslInstalled) {
    Write-Host "WSL is not installed. Installing WSL2 with Ubuntu..." -ForegroundColor Yellow
    wsl --install -d Ubuntu
    Write-Host "WSL2 Ubuntu installed. Please restart your computer and run this script again." -ForegroundColor Green
    exit 0
}

$wslList = wsl -l -v 2>$null | Out-String
if ($wslList -notmatch "Ubuntu") {
    Write-Host "Installing Ubuntu in WSL2..." -ForegroundColor Yellow
    wsl --install -d Ubuntu
    Write-Host "Ubuntu installed. Please set up your Ubuntu user, then run this script again." -ForegroundColor Green
    exit 0
}

Write-Host "WSL2 with Ubuntu is available. Setting up Portaldot node..." -ForegroundColor Green

$setupScript = @'
#!/bin/bash
set -e

echo "Updating packages..."
sudo apt-get update -qq

echo "Installing dependencies..."
sudo apt-get install -y -qq wget tar

cd ~

if [ -f "portaldot-testnet-ubuntu/portaldot_dev" ]; then
    echo "Portaldot binary already exists."
else
    echo "Downloading Portaldot testnet binary..."
    wget -q https://github.com/portaldotVolunteer/Portaldot-node/raw/main/portaldot-testnet-ubuntu.tar.gz
    tar -xzf portaldot-testnet-ubuntu.tar.gz
    chmod +x portaldot-testnet-ubuntu/portaldot_dev
fi

echo ""
echo "==================================="
echo "Portaldot node ready!"
echo "==================================="
echo ""
echo "To start the node, run in WSL:"
echo "  ~/portaldot-testnet-ubuntu/portaldot_dev --dev --alice"
echo ""
echo "Then connect your dashboard to:"
echo "  ws://localhost:9944"
echo ""
'@

$tempFile = [System.IO.Path]::GetTempFileName() + ".sh"
Set-Content -Path $tempFile -Value $setupScript

copy-Item $tempFile \\wsl$\Ubuntu\tmp\setup-portaldot.sh

Write-Host "Running setup inside WSL..." -ForegroundColor Cyan
wsl -d Ubuntu -e bash /tmp/setup-portaldot.sh

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "To start the node, run:" -ForegroundColor Yellow
Write-Host "  wsl -d Ubuntu -e ~/portaldot-testnet-ubuntu/portaldot_dev --dev --alice" -ForegroundColor White
Write-Host ""

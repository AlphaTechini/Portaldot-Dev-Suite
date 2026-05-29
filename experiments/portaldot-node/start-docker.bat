@echo off
:: Quick-start Portaldot node via Docker
:: Requires: Docker Desktop installed and running

echo Starting Portaldot dev node in Docker...
echo.

:: Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not running or not installed.
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    exit /b 1
)

:: Build image if not exists
docker build -t portaldot-dev -f Dockerfile . >nul 2>&1
if errorlevel 1 (
    echo Error: Failed to build Docker image.
    echo Make sure you're running this from the experiments\portaldot-node directory.
    exit /b 1
)

:: Run container with port forwarding
echo Portaldot node starting on ws://localhost:9944
echo Press Ctrl+C to stop
echo.

docker run --rm -p 9944:9944 -p 9933:9933 --name portaldot-dev portaldot-dev

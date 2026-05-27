param(
    [Parameter(Position = 0)]
    [ValidateSet("up", "down", "clean", "status")]
    [string]$Command
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$WslPath = ($ScriptDir -replace "\\", "/").Replace("C:", "/mnt/c")

wsl -d Ubuntu -e bash "$WslPath/devsuite.sh" $Command

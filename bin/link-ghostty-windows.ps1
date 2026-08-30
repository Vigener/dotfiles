#Requires -Version 5.1
# ASCII-only. Git Bash + Windows PowerShell 5.1 mojibake JP strings.
param(
    [switch]$Install
)

$ErrorActionPreference = 'Stop'

$DotfilesRoot = Split-Path -Parent $PSScriptRoot
$SrcDir = Join-Path $DotfilesRoot 'ghostty\windows'
$GhosttyDir = Join-Path $env:LOCALAPPDATA 'ghostty'
$MainCfg = Join-Path $GhosttyDir 'config.ghostty'
$LocalCfg = Join-Path $GhosttyDir 'config.local.ghostty'
$ExampleLocal = Join-Path $SrcDir 'config.local.example'
$BashExe = 'C:\Program Files\Git\bin\bash.exe'

function Test-GitBash {
    if (-not (Test-Path -LiteralPath $BashExe)) {
        Write-Warning "Git Bash not found: $BashExe"
        Write-Host 'Install first: winget install Git.Git'
        return $false
    }
    return $true
}

function Install-GhosttyWindows {
    $ReleaseTag = '1.3.2-windows.1'
    $Asset = 'ghostty-1.3.2-windows-x86_64-setup.exe'
    $Url = "https://github.com/LIL-JRG/ghostty/releases/download/$ReleaseTag/$Asset"
    $Dest = Join-Path $env:TEMP $Asset

    Write-Host "Downloading $Url ..."
    Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing

    Write-Host 'Installing (silent)...'
    $proc = Start-Process -FilePath $Dest -ArgumentList '/VERYSILENT', '/NORESTART', '/SUPPRESSMSGBOXES' -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        throw "Installer exit $($proc.ExitCode). Run GUI: $Dest"
    }

    $Exe = Join-Path $env:LOCALAPPDATA 'Programs\Ghostty\ghostty.exe'
    if (-not (Test-Path -LiteralPath $Exe)) {
        Write-Warning "Missing after install: $Exe (open Ghostty from Start Menu once)"
    } else {
        Write-Host "OK: $Exe"
    }
}

function Link-GhosttyConfig {
    if (-not (Test-Path -LiteralPath $SrcDir)) {
        throw "Missing: $SrcDir"
    }

    New-Item -ItemType Directory -Force -Path $GhosttyDir | Out-Null

    Copy-Item -LiteralPath (Join-Path $SrcDir 'config.ghostty') -Destination $MainCfg -Force
    Write-Host "config -> $MainCfg"

    if (-not (Test-Path -LiteralPath $LocalCfg)) {
        if (Test-Path -LiteralPath $ExampleLocal) {
            Copy-Item -LiteralPath $ExampleLocal -Destination $LocalCfg
            Write-Host "config.local (new) -> $LocalCfg"
        }
    } else {
        Write-Host "config.local kept: $LocalCfg"
    }
}

Test-GitBash | Out-Null

if ($Install) {
    Install-GhosttyWindows
}

Link-GhosttyConfig

Write-Host ''
Write-Host 'Next:'
Write-Host '  1. Start Ghostty'
Write-Host '  2. First window should ssh mini; extra tabs: Ctrl+Shift+T'
Write-Host '  3. Reload config: Ctrl+Shift+comma'
Write-Host ''
Write-Host 'Note: unofficial LIL-JRG Windows build (no official Ghostty Windows yet).'

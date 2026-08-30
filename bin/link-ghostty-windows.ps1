#Requires -Version 5.1
<#
.SYNOPSIS
  ThinkPad 向け Ghostty（LIL-JRG 非公式 Win32 版）の config を dotfiles から配置する。

.DESCRIPTION
  - %LOCALAPPDATA%\ghostty\ に config.ghostty / config.local.ghostty を置く
  - Ghostty 本体は別途インストール（このスクリプト末尾の案内、または -Install）

  前提: Git for Windows（Git Bash）
  例: winget install Git.Git

.PARAMETER Install
  LIL-JRG の最新 setup.exe を取得してサイレントインストールする。
#>
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
        Write-Warning "Git Bash が見つかりません: $BashExe"
        Write-Host '先に: winget install Git.Git'
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

    Write-Host "Installing (user scope, silent) ..."
    $proc = Start-Process -FilePath $Dest -ArgumentList '/VERYSILENT', '/NORESTART', '/SUPPRESSMSGBOXES' -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        throw "Installer exit code: $($proc.ExitCode). GUI で $Dest を実行してください。"
    }

    $Exe = Join-Path $env:LOCALAPPDATA 'Programs\Ghostty\ghostty.exe'
    if (-not (Test-Path -LiteralPath $Exe)) {
        Write-Warning "インストール後に $Exe が見つかりません。スタートメニューから Ghostty を一度起動してください。"
    } else {
        Write-Host "OK: $Exe"
    }
}

function Link-GhosttyConfig {
    if (-not (Test-Path -LiteralPath $SrcDir)) {
        throw "dotfiles ghostty/windows がありません: $SrcDir"
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
        Write-Host "config.local は既存のまま: $LocalCfg"
    }
}

Test-GitBash | Out-Null

if ($Install) {
    Install-GhosttyWindows
}

Link-GhosttyConfig

Write-Host ''
Write-Host 'Next:'
Write-Host '  1. Ghostty を起動（スタートメニュー / %LOCALAPPDATA%\Programs\Ghostty\ghostty.exe）'
Write-Host '  2. 1枚目が ssh mini で入れば OK。2枚目は Ctrl+Shift+T'
Write-Host '  3. config 変更後は Ctrl+Shift+, でリロード、または Ghostty 再起動'
Write-Host ''
Write-Host 'Note: 公式 Ghostty の Windows 版は未リリース。LIL-JRG 非公式ビルドを使用。'

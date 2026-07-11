Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:ProjectRoot = Split-Path -Parent $PSScriptRoot
$versionFile = Join-Path $script:ProjectRoot '.swift-version'
if (-not (Test-Path -LiteralPath $versionFile)) {
    throw "Missing Swift version file: $versionFile"
}

$script:RequiredSwiftVersion = (Get-Content -LiteralPath $versionFile -Raw).Trim()
if ($script:RequiredSwiftVersion -notmatch '^6\.3\.\d+$') {
    throw ".swift-version must pin a Swift 6.3 patch release, for example 6.3.3. Current value: '$script:RequiredSwiftVersion'."
}

function Get-InstalledSwiftExecutable {
    $expectedToolchain = Join-Path $env:LOCALAPPDATA "Programs\Swift\Toolchains\$script:RequiredSwiftVersion+Asserts\usr\bin\swift.exe"
    if (Test-Path -LiteralPath $expectedToolchain) {
        return $expectedToolchain
    }

    $command = Get-Command swift.exe -ErrorAction SilentlyContinue
    if ($null -ne $command -and (Test-Path -LiteralPath $command.Source)) {
        return $command.Source
    }

    $searchRoots = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\Swift'),
        'C:\Library\Developer\Toolchains'
    ) | Where-Object { Test-Path -LiteralPath $_ }

    foreach ($root in $searchRoots) {
        $swift = Get-ChildItem -LiteralPath $root -Filter swift.exe -File -Recurse -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if ($null -ne $swift) {
            return $swift.FullName
        }
    }

    return $null
}

function Get-SwiftVersion {
    param([Parameter(Mandatory)][string]$SwiftExecutable)

    $versionOutput = & $SwiftExecutable --version 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw "Swift could not be started: $versionOutput"
    }

    return $versionOutput
}

function Require-Swift {
    $swift = Get-InstalledSwiftExecutable
    if ($null -eq $swift) {
        throw "Swift $script:RequiredSwiftVersion is not available. Run .\scripts\Setup-Swift.ps1 first."
    }

    $versionOutput = Get-SwiftVersion -SwiftExecutable $swift
    if ($versionOutput -notmatch [regex]::Escape($script:RequiredSwiftVersion)) {
        throw "Swift $script:RequiredSwiftVersion is required, but the current toolchain is:`n$versionOutput"
    }

    return $swift
}

function Invoke-Swift {
    param([Parameter(Mandatory)][string[]]$Arguments)

    $swift = Require-Swift
    Push-Location $script:ProjectRoot
    try {
        & $swift @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "Swift command failed with exit code $LASTEXITCODE."
        }
    }
    finally {
        Pop-Location
    }
}

[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'Common.ps1')

function Broadcast-EnvironmentChange {
    if ($null -eq ('WindowsConnectionOrder.NativeEnvironment' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

namespace WindowsConnectionOrder {
    public static class NativeEnvironment {
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern IntPtr SendMessageTimeout(
            IntPtr hWnd,
            uint msg,
            IntPtr wParam,
            string lParam,
            uint flags,
            uint timeout,
            out IntPtr result
        );
    }
}
'@
    }

    $result = [IntPtr]::Zero
    [void][WindowsConnectionOrder.NativeEnvironment]::SendMessageTimeout(
        [IntPtr]0xffff,
        0x001A,
        [IntPtr]::Zero,
        'Environment',
        0x0002,
        5000,
        [ref]$result
    )
}

function Add-SwiftDirectoriesToUserPath {
    param([Parameter(Mandatory)][string]$SwiftExecutable)

    $toolchainDirectory = Split-Path -Parent $SwiftExecutable
    $toolchainsDirectory = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $toolchainDirectory))
    $swiftRoot = Split-Path -Parent $toolchainsDirectory
    $runtimeDirectory = Join-Path $swiftRoot "Runtimes\$RequiredSwiftVersion\usr\bin"
    $sdkRoot = Join-Path $swiftRoot "Platforms\$RequiredSwiftVersion\Windows.platform\Developer\SDKs\Windows.sdk"
    if (-not (Test-Path -LiteralPath $runtimeDirectory)) {
        throw "Swift runtime directory was not found: $runtimeDirectory"
    }
    if (-not (Test-Path -LiteralPath $sdkRoot)) {
        throw "Swift SDK directory was not found: $sdkRoot"
    }

    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $pathEntries = @($userPath -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $nonSwiftEntries = @($pathEntries | Where-Object { $_ -notmatch '\\Programs\\Swift\\' })
    $newUserPath = (@($runtimeDirectory, $toolchainDirectory) + $nonSwiftEntries) -join ';'

    [Environment]::SetEnvironmentVariable('Path', $newUserPath, 'User')
    [Environment]::SetEnvironmentVariable('SDKROOT', "$sdkRoot\", 'User')
    $env:Path = "$runtimeDirectory;$toolchainDirectory;$env:Path"
    $env:SDKROOT = "$sdkRoot\"
    Broadcast-EnvironmentChange
    Write-Host "Swift runtime and toolchain are first in the user PATH."
}

function Wait-ForSwiftExecutable {
    param([int]$TimeoutSeconds = 180)

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    do {
        $candidate = Get-InstalledSwiftExecutable
        if ($null -ne $candidate) {
            return $candidate
        }
        Start-Sleep -Seconds 2
    } while ((Get-Date) -lt $deadline)

    return $null
}

function Test-SwiftPrerequisites {
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($null -eq $winget) {
        throw 'winget is required. Install or update Microsoft App Installer, then run this script again.'
    }

    & $winget.Source show --id Swift.Toolchain --exact --version $RequiredSwiftVersion --source winget --accept-source-agreements --disable-interactivity | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "winget does not provide Swift.Toolchain version $RequiredSwiftVersion from the winget source."
    }

    $vswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
    $sdkRoot = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\Include'
    if (-not (Test-Path -LiteralPath $vswhere)) {
        throw 'Visual Studio Build Tools are required: install the MSVC x64/x86 tools and Windows SDK first.'
    }

    $vcTools = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ([string]::IsNullOrWhiteSpace($vcTools) -or -not (Test-Path -LiteralPath $sdkRoot)) {
        throw 'Swift requires the Visual Studio C++ x64/x86 tools and a Windows SDK.'
    }

    return $winget
}

$winget = Test-SwiftPrerequisites
$swift = Get-InstalledSwiftExecutable
if ($null -ne $swift) {
    Add-SwiftDirectoriesToUserPath -SwiftExecutable $swift
    $versionOutput = Get-SwiftVersion -SwiftExecutable $swift
    if ($versionOutput -match [regex]::Escape($RequiredSwiftVersion)) {
        & $swift package --version | Out-Host
        if ($LASTEXITCODE -ne 0) {
            throw 'Swift is present but Swift Package Manager could not start.'
        }
        Write-Host "Swift $RequiredSwiftVersion is ready: $swift"
        exit 0
    }
}

Write-Host "Installing Swift $RequiredSwiftVersion through winget..."
& $winget.Source install --id Swift.Toolchain --exact --version $RequiredSwiftVersion --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity
if ($LASTEXITCODE -ne 0) {
    throw "winget failed to install Swift $RequiredSwiftVersion (exit code $LASTEXITCODE)."
}

$swift = Wait-ForSwiftExecutable
if ($null -eq $swift) {
    throw 'winget finished, but swift.exe did not appear in the expected Swift toolchain location within three minutes.'
}

Add-SwiftDirectoriesToUserPath -SwiftExecutable $swift
$versionOutput = Get-SwiftVersion -SwiftExecutable $swift
if ($versionOutput -notmatch [regex]::Escape($RequiredSwiftVersion)) {
    throw "winget installed an unexpected Swift version:`n$versionOutput"
}

& $swift package --version | Out-Host
if ($LASTEXITCODE -ne 0) {
    throw 'Swift was installed, but Swift Package Manager could not start.'
}

Write-Host "Swift $RequiredSwiftVersion is ready: $swift"

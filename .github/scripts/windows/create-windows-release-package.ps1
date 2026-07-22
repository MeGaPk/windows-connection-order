param(
    [Parameter(Mandatory = $true)]
    [string] $Workspace,

    [Parameter(Mandatory = $true)]
    [string] $ArtifactsDir,

    [Parameter(Mandatory = $true)]
    [string] $ZipPath
)

Set-Location -LiteralPath $Workspace
$ErrorActionPreference = "Stop"

$appExe = Join-Path $ArtifactsDir "WindowsConnectionOrder.exe"
$cliExe = Join-Path $ArtifactsDir "WindowsConnectionOrderCLI.exe"

if (-not (Test-Path -LiteralPath $appExe)) {
    throw "Missing app executable: $appExe"
}
if (-not (Test-Path -LiteralPath $cliExe)) {
    throw "Missing CLI executable: $cliExe"
}

if (Test-Path -LiteralPath $ZipPath) {
    Remove-Item -LiteralPath $ZipPath -Force
}

Compress-Archive -Path @($appExe, $cliExe) -DestinationPath $ZipPath -Force
Write-Host "Created release package: $ZipPath"

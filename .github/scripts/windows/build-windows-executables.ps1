param(
    [Parameter(Mandatory = $true)]
    [string] $Workspace,

    [Parameter(Mandatory = $true)]
    [string] $ArtifactsDir,

    [string] $Configuration = "release",

    [string] $Products = "WindowsConnectionOrder,WindowsConnectionOrderCLI"
)

Set-Location -LiteralPath $Workspace
$ErrorActionPreference = "Stop"

Write-Host "Using swift version:"
& swift --version
if ($LASTEXITCODE -ne 0) {
    throw "Unable to execute Swift (exit code $LASTEXITCODE)."
}

& swift package resolve
if ($LASTEXITCODE -ne 0) {
    throw "Swift package resolution failed (exit code $LASTEXITCODE)."
}

$ProductList = $Products -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ }

foreach ($product in $ProductList) {
    Write-Host "Building product: $product ($Configuration)"
    & swift build -c $Configuration --product $product
    if ($LASTEXITCODE -ne 0) {
        throw "Build of product '$product' failed (exit code $LASTEXITCODE)."
    }
}

New-Item -ItemType Directory -Force -Path $ArtifactsDir | Out-Null
$binPathOutput = @(& swift build -c $Configuration --show-bin-path)
if ($LASTEXITCODE -ne 0) {
    throw "Unable to resolve Swift build output path (exit code $LASTEXITCODE)."
}
$binPath = $binPathOutput | Select-Object -Last 1

foreach ($product in $ProductList) {
    $exeName = "$product.exe"
    $candidate = Join-Path -Path $binPath -ChildPath $exeName

    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        throw "Build output '$candidate' not found. Check build logs."
    }

    $outPath = Join-Path -Path $ArtifactsDir -ChildPath $exeName
    Copy-Item -LiteralPath $candidate -Destination $outPath -Force
    Write-Host "Packed artifact: $outPath"
}

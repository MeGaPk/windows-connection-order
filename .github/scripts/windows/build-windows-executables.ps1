param(
    [Parameter(Mandatory = $true)]
    [string] $Workspace,

    [Parameter(Mandatory = $true)]
    [string] $ArtifactsDir,

    [string] $Configuration = "release",

    [string] $Products = "WindowsConnectionOrder,WindowsConnectionOrderCLI"
)

Set-Location -LiteralPath $Workspace

Write-Host "Using swift version:"
swift --version

swift package resolve

$ProductList = $Products -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ }

foreach ($product in $ProductList) {
    Write-Host "Building product: $product ($Configuration)"
    swift build -c $Configuration --product $product
}

New-Item -ItemType Directory -Force -Path $ArtifactsDir | Out-Null

foreach ($product in $ProductList) {
    $exeName = "$product.exe"
    $candidate = Get-ChildItem -Path ".build" -Recurse -Filter $exeName `
        | Where-Object { $_.FullName -match "\\$exeName$" } `
        | Select-Object -First 1

    if (-not $candidate) {
        throw "Build output '$exeName' not found. Check build logs."
    }

    $outPath = Join-Path -Path $ArtifactsDir -ChildPath $exeName
    Copy-Item -Path $candidate.FullName -Destination $outPath -Force
    Write-Host "Packed artifact: $outPath"
}

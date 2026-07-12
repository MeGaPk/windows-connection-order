. (Join-Path $PSScriptRoot 'Common.ps1')

& (Join-Path $PSScriptRoot 'Generate-Localizables.ps1')

$releaseDirectory = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot 'release_build'))
$projectPrefix = [System.IO.Path]::GetFullPath($ProjectRoot).TrimEnd('\') + '\'
if (-not $releaseDirectory.StartsWith($projectPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Release output must remain inside the project directory.'
}

if (Test-Path -LiteralPath $releaseDirectory) {
    Remove-Item -LiteralPath $releaseDirectory -Recurse -Force
}
New-Item -ItemType Directory -Path $releaseDirectory | Out-Null

Invoke-Swift -Arguments @('build', '-c', 'release')

$swift = Require-Swift
Push-Location $ProjectRoot
try {
    $binaryDirectory = (& $swift 'build' '-c' 'release' '--show-bin-path' | Select-Object -Last 1).Trim()
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $binaryDirectory)) {
        throw 'Swift did not return a valid release output directory.'
    }

    Copy-Item -Path (Join-Path $binaryDirectory '*') -Destination $releaseDirectory -Recurse -Force
}
finally {
    Pop-Location
}

Write-Host "Release build created in: $releaseDirectory"

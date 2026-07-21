. (Join-Path $PSScriptRoot 'Common.ps1')

& (Join-Path $PSScriptRoot 'Generate-Localizables.ps1')

Invoke-Swift -Arguments @('run', 'WindowsConnectionOrder')

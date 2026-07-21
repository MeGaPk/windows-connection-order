[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$installerUrl = 'https://aka.ms/windowsappsdk/1.5/1.5.240205001-preview1/windowsappruntimeinstall-x64.exe'
$installerPath = Join-Path $env:TEMP 'windowsappruntimeinstall-x64-1.5-preview1.exe'

Write-Host 'Downloading Windows App Runtime 1.5-preview1 x64...'
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

Write-Host 'Installing Windows App Runtime...'
$process = Start-Process -FilePath $installerPath -ArgumentList '--quiet' -Wait -PassThru -WindowStyle Hidden
if ($process.ExitCode -ne 0) {
    throw "Windows App Runtime installer failed with exit code $($process.ExitCode)."
}

Write-Host 'Windows App Runtime installation completed.'

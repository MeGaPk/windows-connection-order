[CmdletBinding()]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$vscodeDirectory = Join-Path $projectRoot '.vscode'
New-Item -ItemType Directory -Path $vscodeDirectory -Force | Out-Null

$files = @{
    'extensions.json' = @'
{
  "recommendations": [
    "swiftlang.swift-vscode"
  ]
}
'@
    'tasks.json' = @'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Bootstrap Swift",
      "type": "shell",
      "command": "powershell",
      "args": [
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        "${workspaceFolder}\\scripts\\Setup-Swift.ps1"
      ],
      "problemMatcher": []
    },
    {
      "label": "Setup Windows App Runtime",
      "type": "shell",
      "command": "powershell",
      "args": [
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        "${workspaceFolder}\\scripts\\Setup-WindowsAppRuntime.ps1"
      ],
      "problemMatcher": []
    },
    {
      "label": "Generate localization accessors",
      "type": "shell",
      "command": "powershell",
      "args": [
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        "${workspaceFolder}\\scripts\\Generate-Localizables.ps1"
      ],
      "problemMatcher": []
    },
    {
      "label": "Run demo",
      "type": "shell",
      "command": "powershell",
      "args": [
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        "${workspaceFolder}\\scripts\\Run-Demo.ps1"
      ],
      "problemMatcher": []
    },
    {
      "label": "Build debug",
      "type": "shell",
      "command": "powershell",
      "args": [
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        "${workspaceFolder}\\scripts\\Build-Debug.ps1"
      ],
      "problemMatcher": []
    },
    {
      "label": "Build release",
      "type": "shell",
      "command": "powershell",
      "args": [
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        "${workspaceFolder}\\scripts\\Build-Release.ps1"
      ],
      "problemMatcher": []
    }
  ]
}
'@
    'settings.json' = @'
{
  "swift.autoGenerateLaunchConfigurations": true,
  "editor.formatOnSave": true
}
'@
}

foreach ($file in $files.GetEnumerator()) {
    $path = Join-Path $vscodeDirectory $file.Key
    if ((Test-Path -LiteralPath $path) -and -not $Force) {
        Write-Host "Skipped existing file: $path"
        continue
    }

    Set-Content -LiteralPath $path -Value $file.Value -Encoding utf8
    Write-Host "Generated: $path"
}

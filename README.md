# Windows Connection Order

A Windows application for viewing and changing the network adapter connection order. The current Swift + SwiftCrossUI prototype uses mock data only: it does not read or change Windows network settings yet.

## Requirements

- Windows 10 x64 or later.
- Swift `6.3.3`, pinned in [`.swift-version`](.swift-version).
- Visual Studio Build Tools and Windows SDK, installed by the setup script. WinUIBackend documentation lists Windows SDK `10.0.17763`; the setup script installs a newer, compatible Windows SDK.
- **Windows App Runtime 1.5-preview1 x64** to run the current WinUI backend. This is a temporary `swift-winui` dependency; without it, Windows displays an application-launch error.

## First run

```powershell
.\scripts\Setup-Swift.ps1
.\scripts\Setup-WindowsAppRuntime.ps1
.\scripts\Build-Debug.ps1
```

Restart the terminal and VS Code after installing Swift or the runtime so they receive the updated environment variables.

## Commands

| Command | Description |
| --- | --- |
| `.\scripts\Setup-Swift.ps1` | Installs the pinned Swift toolchain through winget, C++ build tools, and Windows SDK; configures PATH and SDKROOT. |
| `.\scripts\Setup-WindowsAppRuntime.ps1` | Downloads and silently installs Windows App Runtime 1.5-preview1 x64 from Microsoft for the current GUI backend. |
| `.\scripts\Generate-Localizables.ps1` | Reads every `Resources/*.lproj/*.strings` file, validates keys and format arguments, then generates typed localization accessors. |
| `.\scripts\Build-Debug.ps1` | Generates localization accessors and builds the debug executable. |
| `.\scripts\Run-Demo.ps1` | Generates localization accessors, builds, and launches the demo UI. |
| `.\scripts\Build-Release.ps1` | Generates localization accessors, clears `release_build`, and creates a release build there. |
| `.\scripts\Generate-VSCodeFiles.ps1 -Force` | Creates or refreshes `.vscode` with the recommended extension and tasks. |

Generated localization files are stored in `Sources/Localization/Generated/` and intentionally excluded from Git. Use the build scripts rather than direct `swift build` in a clean checkout.

## Architecture

`EntryPoint` composes all dependencies. The UI is in `Nodes/Main`; data flows through:

```text
MainViewModel → UseCase → Repository → Gateway
```

Contracts and implementations are separate Swift Package targets: `Gateway` / `GatewayImpl`, `Repository` / `RepositoryImpl`, and `UseCase` / `UseCaseImpl`. The repository caches adapters through `AsyncCurrentValue` and exposes updates through `AsyncStream`.

## Windows App Runtime

The current WinUI backend is framework-dependent: a standalone `.exe` does not include Windows App Runtime. For development, run `Setup-WindowsAppRuntime.ps1`. A future public release must either ship the installer next to the app or use an MSIX package. The official runtime installer supports silent installation with `--quiet`. See [Microsoft's unpackaged app deployment guide](https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/deploy-unpackaged-apps) and the [SwiftCrossUI WinUIBackend guide](https://docs.swiftcrossui.dev/documentation/swiftcrossui/winuibackend).

# Windows Connection Order

Windows Connection Order is an open-source Windows desktop application for viewing network adapters and managing their connection priority through interface metrics.

> **Alpha software.** The project is under active development. The GUI currently reads real adapter names, addresses, and metrics on Windows. Writing metric changes to Windows is not implemented yet; changes made in the prototype affect only its in-memory state.

## What exists today

- Native Windows GUI built with Swift and SwiftCrossUI.
- A scrollable adapter table with selection, move-up/move-down prototype actions, editable metric cells, and light/dark/automatic appearance modes.
- English, Russian, and Estonian localization, switchable from Settings.
- Real adapter discovery on Windows through the Windows networking APIs.
- A command-line executable that uses the same adapter use cases as the GUI.
- A layered Swift Package architecture with separate targets for contracts, implementations, UI, and Windows-specific networking.

## Command-line mode

A separate `WindowsConnectionOrderCLI` executable lets automation and AI tools exercise the same adapter refresh and stream use cases as the GUI without opening a window.

Run it through SwiftPM during development:

```powershell
# Human-readable adapter table
swift run WindowsConnectionOrderCLI adapters list

# Stable machine-readable output
swift run WindowsConnectionOrderCLI adapters list --format json
```

On Windows, the CLI reads real adapters. On other platforms it uses the same mock gateway fallback as the GUI. Reorder and metric-update commands will be added after Windows write support is implemented.

## Requirements

- Windows 10 x64 or later.
- Swift `6.3.3`, pinned in [`.swift-version`](.swift-version).
- Visual Studio C++ build tools and a Windows SDK. The setup script installs the required components.
- **Windows App Runtime 1.5-preview1 x64** for the current SwiftCrossUI WinUI backend.

## Set up, build, and run

Run the following from the project root in PowerShell:

```powershell
.\scripts\Setup-Swift.ps1
.\scripts\Setup-WindowsAppRuntime.ps1
.\scripts\Run-Demo.ps1
```

After installing Swift or the runtime, restart your terminal and VS Code so they receive the updated environment variables.

To build without launching the app:

```powershell
.\scripts\Build-Debug.ps1
```

To create a release build, use:

```powershell
.\scripts\Build-Release.ps1
```

The release files are written to `release_build/`, which is intentionally excluded from Git.

## Project scripts

| Command | Description |
| --- | --- |
| `.\scripts\Setup-Swift.ps1` | Installs the pinned Swift toolchain through winget, Visual Studio C++ build tools, and the Windows SDK; configures `PATH` and `SDKROOT`. |
| `.\scripts\Setup-WindowsAppRuntime.ps1` | Downloads and silently installs Windows App Runtime 1.5-preview1 x64 for the current GUI backend. |
| `.\scripts\Generate-Localizables.ps1` | Reads all `Resources/*.lproj/*.strings` files, validates keys and format arguments, and generates typed localization accessors. |
| `.\scripts\Build-Debug.ps1` | Generates localization accessors and builds the debug executable. |
| `.\scripts\Run-Demo.ps1` | Generates localization accessors, builds, and launches the GUI. |
| `.\scripts\Build-Release.ps1` | Generates localization accessors, clears `release_build/`, and creates a release build there. |
| `.\scripts\Generate-VSCodeFiles.ps1 -Force` | Creates or refreshes the recommended VS Code configuration. |

Generated localization sources live in `Sources/Localization/Generated/` and are intentionally ignored by Git. Use the project scripts rather than bare `swift build` in a clean checkout.

## Architecture

`EntryPoint` performs dependency composition. The GUI lives in `Nodes`; data flows through the application layers:

```text
View model → Use case → Repository → Gateway
```

Contracts and implementations use separate Swift Package targets: `Gateway` / `GatewayImpl`, `Repository` / `RepositoryImpl`, and `UseCase` / `UseCaseImpl`. `WindowsNetworkGatewayImpl` contains the Windows-native adapter reader. The repository caches adapter state and exposes updates through `AsyncStream`.

See [the architecture document](ARCHITECTURE.md) for the complete target graph and dependency rules.

## Windows App Runtime

The current WinUI backend is framework-dependent: the executable does not contain Windows App Runtime. For development, run `Setup-WindowsAppRuntime.ps1`. A future public release will need to ship the runtime installer beside the app or use an MSIX package.

See [Microsoft's unpackaged app deployment guide](https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/deploy-unpackaged-apps) and the [SwiftCrossUI WinUIBackend guide](https://docs.swiftcrossui.dev/documentation/swiftcrossui/winuibackend).

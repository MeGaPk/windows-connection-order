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

## Recent changes (UI polish)

This section summarizes the most recent merged-or-ready-to-merge UI work. The detailed PR description is in [`PR_BODY.md`](PR_BODY.md).

### What landed

- **Weighted table columns.** `ScrollableTable` now distributes its width across `ScrollableTableColumn` children by `weight / totalWeight` through a custom `EnvironmentKey` (`columnLayout`). `AdaptersTable` declares explicit weights (`Order 0.5 / Adapter 2.5 / IPv4 1.6 / IPv6 1.6 / Metric 1.0`) with `minWidth`s, so long adapter names no longer push IPv4/IPv6 columns off-screen and the `#` column stops hogging space. `Rectangle().fill().overlay(...)` dividers were replaced with the public `Divider(_:)`.
- **Localization through the environment.** A new `LocalizablesProvider` (`@ObservableObject @unchecked Sendable final class`) is pushed once per screen through `\.localizablesProvider` and a `View.localizablesProvider(_:)` modifier. `MainViewModel` and `SettingsViewModel` hold the provider as a `weak var` and call `update(to:)` from the locale stream. Views read `localizablesProvider.current` instead of constructing a new `Localizables` on every `body` evaluation. `WindowsConnectionOrderApp` instantiates and threads the provider in `init()`.
- **Split error UI.** `MainViewModel` separates `errorMessage` into `systemError` (full-width `ErrorBanner` for permission / system / unknown) and `metricFieldError` (inline `FieldHint` under the metric `TextField`). `applyMetric()` validates locally before the use case, so a bad integer never reaches the gateway.
- **Refresh indicator.** `MainViewModel.isRefreshing` drives a small `HeaderProgressDot()` next to the Settings button while `RefreshAdaptersUseCase` is in flight. Disabled Move Up / Move Down render with `UIColors.Text.disabled`.
- **Semantic color palette.** `UIColors` is now organized into `Surface`, `Text`, `Accent`, and `Divider` groups. The old flat names (`pageBackground`, `tableBackground`, `tableHeaderBackground`, `selectedRowBackground`, `alternateRowBackground`, `errorBackground`, `errorForeground`) are kept as public aliases so nothing else had to change.
- **No domain, repository, use case, or gateway code was touched.** `Package.swift` is unchanged.

### Files touched in the change

- `Sources/UIUtils/UIColors.swift` — semantic groups + alias layer.
- `Sources/UIUtils/ScrollableTable.swift` — weighted distribution.
- `Sources/UIUtils/ErrorViews.swift` — new (`ErrorBanner`, `FieldHint`, `HeaderProgressDot`).
- `Sources/Nodes/LocalizablesProvider.swift` — new.
- `Sources/Nodes/Main/MainViewModel.swift`, `MainScreen.swift`, `AdaptersTable.swift`.
- `Sources/Nodes/Settings/SettingsViewModel.swift`, `SettingsScreen.swift`.
- `Sources/EntryPoint/WindowsConnectionOrderApp.swift`.

## Roadmap

The project is still alpha. Items below are tracked in priority order; nothing here is committed to a date.

### Up next (small, mostly UI)

- **Per-row reorder controls.** Add a small actions column in `AdaptersTable` with `▲` / `▼` buttons, disabled at the list boundaries. The Move Up / Move Down buttons above the table can then be promoted to a global "Apply changes" affordance once drag-and-drop is in.
- **Drag-and-drop reordering.** Teach `ScrollableTable` to host a drop handler and a "reorder-on-drag" event so rows can be dragged into a new position, matching the experience promised in [`PLAN.md`](PLAN.md).
- **Metric editor polish.** Render `auto` (or a localized "automatic") instead of raw `0` when the adapter is in automatic mode. Show a `FieldHint` immediately on focus loss if the value is not a valid `Int`, instead of waiting for Enter.
- **Auto-dismissing system errors.** `ErrorBanner` should fade out after 6–8 seconds for transient `systemError(code, _)` cases, keeping the manual `Dismiss` only for permission / unknown.
- **Shared stream-observation helper.** `MainViewModel` and `SettingsViewModel` repeat the same `startLocalesStream` / `startColorSchemeStream` shape; a small `observe<T>(_:assign:)` helper in `UIUtils` would remove the duplication and centralize the cancellation pattern.
- **Lazy row updates.** Switch `AdaptersTable` from `ForEach(Array(viewModel.adapters.enumerated()), id:)` to `List` with `id: \.id` so SwiftCrossUI's view graph can skip unchanged rows on stream updates.
- **Accessibility labels.** With the column weights settled, add localized `accessibilityLabel` values for screen readers — especially on the metric editor and on the per-row actions once they exist.

### Larger items

- **Windows write support.** Implement metric writes through the Windows IP Helper API (`SetIpInterfaceEntry`) in `WindowsNetworkGatewayImpl`. Until this lands, the GUI is read-only on Windows.
- **Administrator-mode UX.** Promote the `permissionDenied` branch from a transient `ErrorBanner` to a persistent banner with a "Restart as administrator" action, as described in `PLAN.md`.
- **Split IPv4 / IPv6 metrics.** The data model already tracks per-protocol metrics; the table currently shows a single "Metric" column. Splitting it into `Metric IPv4` and `Metric IPv6` is the next visible step after Windows write support.
- **Unavailable adapters section.** Fold a separate "Unavailable for editing (N)" collapsible section under the main table with reasons, per the product plan.
- **CLI reorder / update commands.** The `WindowsConnectionOrderCLI` executable currently exposes `adapters list`. Add `adapters reorder` and `adapters update-metric` once Windows write support is in place.
- **Self-contained release.** Ship a self-contained EXE (or an MSIX) so end-users do not need to install Windows App Runtime manually.
- **Unit tests for `LocalizablesProvider` and the new view models.** Lock in the contract of `update(to:)` and the split `systemError` / `metricFieldError` semantics.

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
| `.\scripts\Setup-Swift.ps1` | Downloads the signed official Swift installer for the pinned toolchain, verifies its signature, installs it, and configures `PATH` and `SDKROOT`. |
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

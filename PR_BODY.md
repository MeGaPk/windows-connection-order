# UI polish: weighted table columns, env-driven localization, separated error UI, refresh indicator, semantic colors

## Summary

This PR is a UI-only pass over the SwiftCrossUI prototype. It tightens the
adapter table layout, moves `Localizables` from per-`body` allocation to a
shared provider, splits system vs. field-level errors, surfaces an
in-progress indicator while adapters are being refreshed, and reorganizes
`UIColors` into semantic groups. No domain, repository, use case, or
gateway code changed.

## What was done

### 1. Weighted columns in `ScrollableTable`
- `ScrollableTable` now measures its width with `GeometryReader` and
  distributes it to `ScrollableTableColumn` children by `weight /
  totalWeight` through a custom `EnvironmentKey` (`columnLayout`).
- `AdaptersTable` declares explicit weights and `minWidth`s for each
  column:
  - Order: weight `0.5`
  - Adapter: weight `2.5`, `minWidth 140`
  - IPv4: weight `1.6`, `minWidth 110`
  - IPv6: weight `1.6`, `minWidth 110`
  - Metric: weight `1.0`, `minWidth 90`
  - `totalWeight = 7.2`
- The previous `Rectangle().fill(...).overlay(_, alignment: .bottom)`
  divider hack is replaced with the public SwiftCrossUI `Divider(_:)`.
- Result: long adapter names no longer push IPv4/IPv6 columns off the
  edge, the `#` column stops hogging space, and resizing the window
  reflows columns without an extra state round-trip.

### 2. `Localizables` via environment instead of per-`body` rebuild
- New `LocalizablesProvider` (`@ObservableObject @unchecked Sendable
  final class`) lives in `Sources/Nodes/LocalizablesProvider.swift`. It
  exposes one mutable `current: Localizables` and an `update(to:)`
  method. It is pushed into `EnvironmentValues` once per screen via
  `\.localizablesProvider` and a `View.localizablesProvider(_:)`
  modifier.
- `MainViewModel` and `SettingsViewModel` hold the provider through a
  `weak var`. The locale stream calls `provider.update(to:)`; the
  observation graph re-renders any view that reads
  `localizablesProvider.current`.
- `MainScreen` and `SettingsScreen` no longer construct `Localizables`
  on every `body` evaluation. They read it from the environment, with
  a defensive fallback to `viewModel.localeSettings?.selectedLocale` /
  `.systemDefault` for unit tests.
- The provider is instantiated in `WindowsConnectionOrderApp.init()`,
  stored in `@State` on the app, and threaded into both screens so a
  locale change updates the main and settings views through the same
  observable.

### 3. Split `ErrorBanner` vs. `FieldHint`
- New `Sources/UIUtils/ErrorViews.swift` introduces:
  - `ErrorBanner(message:, dismissTitle:, onDismiss:)` — full-width,
    red surface, used for permission / system / unknown errors.
  - `FieldHint(message:)` — small inline text under a field, used for
    validation errors.
  - `HeaderProgressDot` — compact `ProgressView()` next to the
    settings button.
- `MainViewModel` splits the old single `errorMessage` into:
  - `systemError: String?` — fed by `.permissionDenied`,
    `.adapterNotFound`, `.systemError`, `.unknown`.
  - `metricFieldError: String?` — fed by `applyMetric()`'s local
    validation and by `.invalidMetricValue` returned from the use
    case.
- `applyMetric()` validates the input *before* calling the use case,
  so a bad integer never reaches the gateway.

### 4. `isRefreshing` indicator
- `MainViewModel.isRefreshing: Bool`. Set to `true` synchronously
  inside `refreshAdapters()` before the `Task` is launched, reset in
  a `defer { … }` after the work completes.
- `MainScreen.screenHeader` shows `HeaderProgressDot()` next to the
  Settings button whenever `viewModel.isRefreshing == true`. Disabled
  Move Up / Move Down buttons are rendered with
  `UIColors.Text.disabled` so the inactive state is obvious.

### 5. `UIColors` as semantic groups
- Reorganized into nested namespaces with public aliases for backward
  compatibility:
  - `UIColors.Surface.{page, table, tableHeader, rowAlternate,
    selected, control, error}`
  - `UIColors.Text.{error, disabled}`
  - `UIColors.Accent.{primary, muted}`
  - `UIColors.Divider.default`
- Old flat names (`pageBackground`, `tableBackground`,
  `tableHeaderBackground`, `selectedRowBackground`,
  `alternateRowBackground`, `errorBackground`, `errorForeground`)
  remain as aliases so no other module needs to change.
- Used by the new table dividers, the disabled action buttons, and
  the split error / hint components.

## What was intentionally *not* done

- The original list also mentioned "actions column with per-row
  ▲/▼ buttons" and "drag-and-drop reordering" for the table. Those
  were deferred — the user explicitly asked for the five items above
  only.
- No changes to the `Repository`, `UseCase`, `Gateway`, or
  `Domain` layers. The public CLI executable is unaffected.
- No new localization keys; the existing `Main.strings` already
  covers everything the new code reads.
- `Package.swift` is untouched. The new `LocalizablesProvider` lives
  in the `Nodes` target so `UIUtils` does not pick up a dependency
  on `Domain` / `Localization`.
- The Russian-language product plan in `PLAN.md` is left alone.

## Ideas for follow-up work

These are the items from the original review that the user marked
out of scope, plus a few new ones I noticed while implementing the
PR. None of them are blockers.

1. **Per-row reorder controls.** Add a small actions column in
   `AdaptersTable` with up/down buttons and disabled styling at the
   list boundaries. The Move Up / Move Down buttons above the table
   could then be promoted to a global "Apply" affordance once
   drag-and-drop lands.
2. **Drag-and-drop reordering.** Teach `ScrollableTable` to host a
   drop handler and a "reorder-on-drag" event so the user can drag
   rows into a new position, matching the experience promised in
   `PLAN.md`.
3. **Metric editor polish.** Render `auto` (or a localized
   "automatic") instead of raw `0` when the adapter is in automatic
   mode. Show a `FieldHint` immediately on focus loss if the value
   is not a valid `Int` instead of waiting for the user to press
   Enter.
4. **Auto-dismissing system errors.** `ErrorBanner` could fade out
   after 6–8 seconds for transient `systemError(code, _)` cases,
   keeping the manual `Dismiss` only for permission / unknown.
5. **Shared stream-observation helper.** `MainViewModel` and
   `SettingsViewModel` both repeat the same
   `startLocalesStream` / `startColorSchemeStream` shape. A small
   `observe<T>(_:assign:)` helper in `UIUtils` would remove the
   duplication and centralize the cancellation pattern.
6. **Lazy row updates in `AdaptersTable`.** With many adapters the
   current `ForEach(Array(viewModel.adapters.enumerated()), id:)`
   is fine, but switching to `List` with `id: \.id` would let
   SwiftCrossUI's view graph skip unchanged rows on stream updates.
7. **Unit tests for `LocalizablesProvider`.** The provider is a
   simple observable; a few tests around `update(to:)` calling the
   `ObservableObject` publisher would lock in the contract.
8. **Error banner for the "no admin rights" case.** Once Windows
   write support lands (`SetIpInterfaceEntry`), the
   `permissionDenied` branch should be promoted from a transient
   banner to a persistent banner with a "Restart as administrator"
   action, as described in `PLAN.md`.
9. **Accessibility labels.** With the column weights and
   `Divider`s settled, the table is a good place to add localized
   `accessibilityLabel` values for screen readers, especially on
   the metric editor and the per-row actions once they exist.

## Test plan

- `swift build` (or open in Xcode) on Windows 10/11 with Swift
  `6.3.3` and Windows App Runtime 1.5-preview1 x64.
- `powershell -File scripts/Generate-Localizables.ps1` — should be a
  no-op for this PR (no key changes).
- `powershell -File scripts/Run-Demo.ps1` — smoke test:
  1. Resize the window; the columns should re-flow without the
     `#` column squeezing to nothing and IPv4/IPv6 staying readable.
  2. Pick an adapter; the metric cell becomes a `TextField`. Enter
     `abc` and press Enter — `FieldHint` should appear under the
     field; the `ErrorBanner` should *not* appear.
  3. Switch the locale in Settings; both screens should re-render
     with the new strings immediately, without a restart.
  4. While the initial `Refresh` is in flight, the small progress
     dot should be visible next to the Settings button.

## Risk

- UI-only. The single behavioral change is the validation step
  inside `applyMetric()`, which now rejects non-integer input
  locally instead of forwarding it to the use case. The use case
  contract is unchanged.
- The `weak` reference to `LocalizablesProvider` in the view models
  relies on the app keeping the provider alive through `@State` for
  the lifetime of the scene. This is verified by the constructor of
  `WindowsConnectionOrderApp`.
- `@unchecked Sendable` on `LocalizablesProvider` is justified by
  the fact that SwiftCrossUI runs all view code on the main actor,
  so a runtime race on `current` cannot occur. The annotation
  documents this rather than hides it.

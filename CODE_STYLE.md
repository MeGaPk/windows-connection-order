# Code Style

These rules apply to the Swift package and its build scripts unless a task explicitly requires an exception.

## File and module boundaries

- Keep every Swift source file at **180 lines or fewer**, including blank lines and comments.
- Split a file by responsibility before it reaches the limit; do not hide excess code in extensions solely to bypass it.
- Each target has one clear layer. Depend only in the direction defined by the architecture document.
- `Domain` contains value types, protocols, and application-wide concepts. It must not import UI, platform APIs, or implementation targets.
- Protocol targets (`Gateway`, `Repository`, `UseCase`) expose contracts only.
- Implementation targets (`GatewayImpl`, `RepositoryImpl`, `UseCaseImpl`, `WindowsNetworkGatewayImpl`) implement contracts and may depend on their protocol target plus lower-level modules.
- `Nodes` contains screens and their view models. `UIUtils` contains reusable, presentation-only SwiftCrossUI components and must not know domain models, localization, or app colours.
- `EntryPoint` composes GUI-only dependencies and owns app navigation. It must not contain screen business logic.
- `AppComposition` creates shared repositories and use cases for executable targets and selects a gateway. It does not contain UI, direct platform API calls, or command parsing.

## MVVM and Clean Architecture

- A screen owns a screen-specific view model; do not share one view model between unrelated screens.
- A view model is a `final` observable state holder. Keep renderable state explicit and minimal.
- Views render state and forward user intent. They do not call repositories, gateways, Windows APIs, or perform business decisions.
- View models call use-case protocols, never concrete repository or gateway implementations.
- Use cases express a single application action and depend on repository protocols.
- Repositories coordinate cached state and streams; gateways only retrieve or write external/platform data and never cache app state.
- Put dependency structs next to their consumer. Pass the struct to the view model initializer rather than a long list of parameters.
- Prefer protocol existential dependencies (`any SomeProtocol`) over generic parameters for app composition and runtime dependencies.

## Swift conventions

- Use `struct` for immutable values and `final class` or `actor` only where reference identity or shared mutable state is required.
- Make domain values `Sendable` whenever possible.
- Prefer `let`; use `var` only for intended mutation.
- Do not use force unwraps, force casts, implicitly unwrapped optionals, or `try!` in production code.
- Avoid `Any`, global mutable state, singletons, and `shared` instances unless an external API requires them.
- Name types as nouns and methods as verbs. Use precise domain names: `streamAdapters`, `refreshAdapters`, `setLocale`.
- Keep access control explicit for public target APIs; default internal implementation details to `private` or `fileprivate` where appropriate.
- Do not add `any` to protocol declarations; use it only at existential value positions.

## Dependencies and composition

- Inject dependencies through initializers. Do not create implementations inside a view model, use case, repository, or gateway.
- Only composition factories choose adapter implementations: `AppComposition` selects system or mock gateways; `EntryPoint` and `CommandLine` consume its use cases.
- Keep platform selection behind compilation conditions in the composition root, not in domain or feature code.
- Do not make a target depend on an implementation target just to reach a protocol; import the protocol target instead.

## UI and localization

- Keep strings out of Swift source. Use `Resources/<locale>.lproj/*.strings` and generated `Localizables` accessors.
- Only `Nodes` and `EntryPoint` may import `Localization`.
- Pass localized values to screens. View models store semantic state, never display strings.
- Put reusable visual primitives in `UIUtils`; inject app-specific colours and content from the caller.
- Support light, dark, and automatic colour schemes through app state; do not hard-code black or white backgrounds.

## Concurrency

- Use `async`/`await` and `AsyncStream` for asynchronous state. Do not introduce callback pyramids.
- Shared mutable repository state belongs in an `actor`.
- `AsyncStream` publishers must yield the current value to a new subscriber and remove continuations on termination.
- Keep UI mutations on the main actor as required by the UI framework.
- Cancel or release long-lived tasks when their owner is deallocated or replaced.

## Testing and builds

- Add deterministic mock gateways for use-case and CLI tests; do not require real network configuration for those tests.
- Prefer testing use cases and repositories over UI implementation details.
- Run localization generation before a build when resources or generated accessors change.
- Run the relevant debug build after changing package targets, public APIs, or platform interop.
- Keep generated files, build outputs, toolchains, and release artifacts out of Git unless explicitly required.

# SwiftUI iOS Template

An MVVM SwiftUI starter. Xcode projects can't really be templated as loose files (the `.xcodeproj` has machine-specific UUIDs), so this template is a **source drop-in**.

## Setup

1. Create a new Xcode project:
   - File → New → Project → iOS → App
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Product name: match your project folder name

2. Delete Xcode's auto-generated `ContentView.swift` and the `<Name>App.swift`.

3. Copy the contents of this template's `Sources/` folder into your Xcode project's main group.

4. In the Xcode project settings, set the deployment target to **iOS 17+** (the template uses `@Observable`).

5. Build and run.

## What's included
- **App entry point** (`App/MyApp.swift`) — minimal, no third-party injection
- **MVVM skeleton** — one `Feature/` folder with `View` + `ViewModel`, using `@Observable`
- **Networking stub** (`Core/APIClient.swift`) — async/await, `Codable`
- **Design tokens** (`Core/Theme.swift`) — colors and spacing as a single source of truth
- **Preview data** — mock `ViewModel` state for SwiftUI previews

## File tree
```
Sources/
├── App/
│   └── MyApp.swift                   # @main App entry
├── Core/
│   ├── APIClient.swift               # async/await HTTP client
│   └── Theme.swift                   # Color + Spacing tokens
└── Feature/
    ├── ExampleView.swift             # SwiftUI View
    └── ExampleViewModel.swift        # @Observable ViewModel
```

## Conventions (override via project_context/CONVENTIONS.md)
- Use `@Observable` over `ObservableObject` — less boilerplate, iOS 17+ only
- No force unwraps without a `// safe because …` comment
- No singletons — pass dependencies through init
- ViewModels are `@MainActor`; heavy work explicitly moved off-main
- Every interactive control has `.accessibilityLabel`

# BinaryApp

A small iOS app that computes the **binary gap** of a positive integer: the longest run of consecutive zeros surrounded by ones in the number's binary representation.

| Input | Binary | Binary gap |
| --- | --- | --- |
| 529  | `1000010001`  | 4 |
| 1041 | `10000010001` | 5 |
| 15   | `1111`        | 0 |

The app is built in UIKit with a VIPER architecture, dependency injection, and unit tests against the algorithm, persistence layer, and the home presenter.

## Running the project

Requirements: Xcode 16+, iOS 17+ simulator or device.

1. Clone the repository.
   ```bash
   git clone git@github.com:gaston-maspero/binary-gap-app.git
   cd binary-gap-app
   ```
2. Open `BinaryApp.xcodeproj`.
3. Select an iPhone simulator (e.g. iPhone 16) or a connected device.
4. `⌘R` to run.
5. `⌘U` to run the unit tests.

There are no third-party dependencies, no Swift Package Manager packages, and nothing to install. The app boots programmatically from `SceneDelegate` — there is no main storyboard.

## What's inside

### Features

- Numeric input with live validation (positive integer, digit-only)
- Animated result card with the binary representation rendered as a row of chips, the longest gap highlighted in orange
- Recent results on the home screen (tap to re-display)
- Full history screen with swipe-to-delete and clear-all
- Three-page onboarding shown on first launch, reopenable anytime from the `?` button
- Local persistence via `UserDefaults` (with dedup, capped size, thread-safe access)
- Haptics on calculate, navigation, and delete actions
- Dynamic Type, VoiceOver labels, and accessibility announcements throughout

## Architecture

### Why VIPER

Each screen is split into five collaborators with single responsibilities:

| Role | Responsibility |
| --- | --- |
| **View** (`UIViewController`) | Renders view models, forwards user events to the presenter. No business or formatting logic. |
| **Interactor** | Owns the use cases. Talks to domain services (calculator, store). No UI knowledge. |
| **Presenter** | The brain. Translates user intent into interactor calls, transforms domain objects into view models, decides what the view should display. |
| **Router** | Resolves navigation. Owns no state; holds a weak reference to the source view controller. |
| **Builder** | Composition root for the module. Resolves dependencies from the `DependencyContainer` and wires the V/I/P/E/R graph. |

Communication between layers is **always** through protocols, which keeps each piece independently mockable. Each protocol lives in the same file as its primary implementation — there are no separate `*Contracts.swift` files.

### Dependency injection

A single `DependencyContainer` (see `App/DependencyContainer.swift`) owns the application-wide services and the module builders. It is constructed once in `AppDelegate` and resolved from `SceneDelegate` when the root view controller is built.

```
AppDelegate
   └── DependencyContainer
          ├── BinaryGapCalculating
          ├── CalculationHistoryStoring
          ├── HapticsFeedbackProviding
          ├── OnboardingStateProviding
          ├── HomeBuilding       ── builds Home VIPER module
          ├── HistoryBuilding    ── builds History VIPER module
          └── OnboardingBuilding ── builds Onboarding VIPER module
```

Every collaborator is exposed as a protocol; the container holds the concrete instances. Builders consume the container, not the concrete types, so individual services can be swapped (e.g. in tests) without touching the modules.

### Project layout

```
BinaryApp/
├── App/                         AppDelegate, SceneDelegate, DependencyContainer
├── Design/
│   ├── Theme.swift              Color / spacing / typography / radius / animation tokens
│   └── Components/              Reusable UIKit pieces
│       ├── GradientButton.swift
│       ├── CardView.swift
│       └── BinaryRepresentationView.swift
├── Domain/
│   ├── Models/
│   │   └── BinaryCalculation.swift
│   └── Services/
│       ├── BinaryGapCalculator.swift     O(log n) algorithm, no string conversion
│       ├── CalculationHistoryStore.swift UserDefaults-backed, thread-safe, capped
│       ├── HapticsFeedback.swift
│       └── OnboardingState.swift
└── Modules/
    ├── Home/                    Input + result + recent list
    ├── History/                 Diffable table, swipe-to-delete, clear all
    └── Onboarding/              Paged help, first-launch & on-demand
```

Tests live in `BinaryAppTests/`.

### Binary gap algorithm

Implemented in `Domain/Services/BinaryGapCalculator.swift`. Rather than walking a string, it scans the number bit-by-bit with two bitwise operators (`& 1`, `>>= 1`), tracking the longest closed run of zeros. Runs in `O(log n)` time and `O(1)` space.

The presenter additionally computes the index range of the winning gap so the view can highlight it visually (`HomePresenter.ResultFormatter.longestGapRange(in:)`).

### Persistence

`CalculationHistoryStore` is a thin wrapper around `UserDefaults`. Decisions worth highlighting:

- Items are stored as `Codable` JSON under a single key.
- Reads/writes are serialised through a concurrent `DispatchQueue` with barrier writes, so the store is safe to call from any thread.
- Inserting a value that's already present deduplicates and moves it to the top — most-recent-first ordering with no duplicates.
- Maximum 100 entries; older ones drop off the end. Keeps the defaults blob small.

### Accessibility

- All labels and buttons use system fonts and `adjustsFontForContentSizeCategory = true`, so Dynamic Type scales the entire UI.
- The bit-chip view exposes each bit as its own accessibility element (`Bit one` / `Bit zero` / `Bit zero inside gap`).
- After a calculation, the home view posts a `UIAccessibility.announcement` so VoiceOver users hear the result immediately.
- All custom controls (`GradientButton`, `RecentItemControl`, history cell) expose semantic accessibility labels and traits.

## Testing

Three suites in `BinaryAppTests/`, written with Swift Testing:

| Suite | Covers |
| --- | --- |
| `BinaryGapCalculatorTests` | The algorithm — canonical samples, edge cases (single bit, all ones, trailing zeros, zero input). |
| `CalculationHistoryStoreTests` | Persistence — insert ordering, dedup, delete, delete all, recency limit. Each test uses an isolated `UserDefaults` suite. |
| `HomePresenterTests` | Presenter logic — input validation states, calculate flow, recent refresh, recent re-selection, router dispatch. The view, interactor, router, and haptics are spied via protocols. |

Run with `⌘U` in Xcode.

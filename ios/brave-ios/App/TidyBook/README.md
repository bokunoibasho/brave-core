# Tidy Book

A standalone iOS app that reuses Brave's Playlist feature as an iPhone
Music-app-style player for YouTube and other web media. It deliberately
avoids the `BraveCore` (Chromium) xcframework so it can be built and run
without the full brave-core / chromium iOS build pipeline.

Lives inside `bokunoibasho/brave-core` on the `tidy-book` branch.

## Status

Phase 1 — scaffold only. The app launches into a placeholder library view
with a "+" button that opens a `WKWebView` pointed at `m.youtube.com`.
The injected JS reports `<video>`/`<audio>` elements back to Swift, and
the library currently just lists detected URLs in memory.

Brave's actual `PlaylistManager` / `PlaylistRootView` integration is
Phase 2 (see `/Users/o/.claude/plans/ios-brave-tidy-book.md`).

## Layout

```
App/TidyBook/
├── Package.swift              # Standalone Swift Package (no BraveCore)
├── Sources/
│   ├── TidyBook/              # @main app + root SwiftUI view
│   ├── TidyBookBrowser/       # WKWebView + JS media-detection bridge
│   └── TidyBookShims/         # Stand-ins for BraveCore / BraveShared APIs
├── Tests/
│   └── TidyBookShimsTests/
└── Resources/
```

The Swift Package builds the two libraries (`TidyBookBrowser`,
`TidyBookShims`). An Xcode app target wires them into an iOS executable;
see "Opening in Xcode" below.

## Opening in Xcode

This package isn't an iOS app on its own — Swift Package Manager can't
produce iOS app executables. To run on Simulator/device:

1. In Xcode, choose **File ▸ New ▸ Project ▸ iOS App** named `TidyBook`,
   bundle id `app.tidybook` (or whatever you prefer), interface SwiftUI,
   language Swift. Save it inside this folder as
   `App/TidyBook/TidyBook.xcodeproj` (committing the project is fine).
2. Add the local package: **File ▸ Add Package Dependencies… ▸ Add
   Local…** and pick `App/TidyBook/`. Add both `TidyBook`-prefixed
   libraries to the app target's "Frameworks, Libraries, and Embedded
   Content".
3. Delete the auto-generated `ContentView.swift` and `*App.swift` —
   the package already provides them in `Sources/TidyBook/`.
4. Add `Info.plist` keys:
   - `UIBackgroundModes` = `["audio"]`
   - `NSAppTransportSecurity ▸ NSAllowsArbitraryLoads` = `NO` (default;
     we don't need HTTP)
5. Build & run on an iOS 17+ simulator.

(A future commit will check in a pre-made `TidyBook.xcodeproj` or a
`project.yml` for XcodeGen so these steps go away.)

## What lives where

| Layer | Path | Notes |
|---|---|---|
| App entry | `Sources/TidyBook/TidyBookApp.swift` | `@main`, sets `AVAudioSession(.playback)` for background audio |
| Root view | `Sources/TidyBook/TidyBookRootView.swift` | Library list + "+ ▸ browser" sheet |
| Mini-browser | `Sources/TidyBookBrowser/BrowserView.swift` | SwiftUI wrapper presented as a sheet |
| WebView host | `Sources/TidyBookBrowser/WebViewContainer.swift` | Owns the `WKWebView`, injects detection JS |
| Pref shim | `Sources/TidyBookShims/PrefServiceShim.swift` | `UserDefaults`-backed stand-in for `BraveCore.PrefService` |
| UA shim | `Sources/TidyBookShims/UserAgentShim.swift` | Returns a Mobile Safari UA string |
| Shields shim | `Sources/TidyBookShims/BraveShieldsShim.swift` | No-op (TidyBook isn't a privacy browser) |
| Logging shim | `Sources/TidyBookShims/LoggingShim.swift` | `Logger.module` over `os.Logger` |

## License

Mozilla Public License 2.0, same as the rest of brave-core. The reused
Brave source files (Playlist, PlaylistUI, PlaylistScript.js — to be
brought in during Phase 2) retain their MPL 2.0 headers.

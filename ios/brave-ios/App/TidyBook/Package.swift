// swift-tools-version:5.9
// Copyright 2026 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import PackageDescription

// TidyBook is a standalone iOS app that reuses Brave's Playlist feature
// without depending on the BraveCore (Chromium) xcframework.
//
// It deliberately defines its own Swift package, separate from
// `ios/brave-ios/Package.swift`, so that we don't need BraveCore.xcframework
// to be built before this app can compile.
//
// Source files from Brave's modules (e.g. Sources/Playlist) are referenced
// via local `path:` targets and selectively included. Where the original
// Brave code depends on BraveCore symbols, we use `#if TIDYBOOK` guards to
// switch to lightweight shims provided by the `TidyBookShims` target.
let package = Package(
  name: "TidyBook",
  defaultLocalization: "en",
  platforms: [.iOS(.v17)],
  products: [
    .library(name: "TidyBookShims", targets: ["TidyBookShims"]),
    .library(name: "TidyBookBrowser", targets: ["TidyBookBrowser"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "TidyBookShims",
      path: "Sources/TidyBookShims"
    ),
    .target(
      name: "TidyBookBrowser",
      dependencies: ["TidyBookShims"],
      path: "Sources/TidyBookBrowser"
    ),
    .testTarget(
      name: "TidyBookShimsTests",
      dependencies: ["TidyBookShims"],
      path: "Tests/TidyBookShimsTests"
    ),
  ]
)

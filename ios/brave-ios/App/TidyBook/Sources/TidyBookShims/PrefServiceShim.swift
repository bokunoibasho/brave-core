// Copyright 2026 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import Foundation

// MARK: - BraveCore PrefService shim
//
// Brave's `PlaylistPreferences.swift` adds an extension on
// `BraveCore.PrefService` to expose `isPlaylistAvailable`. The real
// PrefService is a Chromium-backed key/value preferences store.
//
// For TidyBook we don't have Chromium, so this shim provides a tiny
// UserDefaults-backed stand-in that satisfies the same API surface used
// by Playlist. In particular:
//
//   - `boolean(forPath:)`
//   - `isManagedPreference(forPath:)`
//
// and the pref key constants Playlist references
// (e.g. `kPlaylistEnabledPrefName`).
//
// When TidyBook code says `import TidyBookShims`, it gets `PrefService`
// from this file. The original Brave Playlist source uses
// `#if TIDYBOOK ... import TidyBookShims #else import BraveCore #endif`
// to swap between the two transparently.

/// Drop-in replacement for `BraveCore.PrefService` covering just the surface
/// area touched by Brave's Playlist module.
public final class PrefService {
  /// Shared singleton. In Brave, PrefService is owned by the profile and
  /// vended through `BraveCoreMain`. TidyBook is single-profile, so a
  /// singleton is sufficient.
  public static let shared = PrefService()

  private let defaults: UserDefaults

  /// Designated initializer. Tests can pass an isolated UserDefaults suite.
  public init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  /// Returns the bool value for the given pref path. Mirrors
  /// `BraveCore.PrefService.boolean(forPath:)`. Unknown paths return false.
  public func boolean(forPath path: String) -> Bool {
    return defaults.bool(forKey: path)
  }

  /// Returns whether the pref at the given path is being managed by policy.
  /// TidyBook is consumer-only with no MDM policy, so this is always false.
  public func isManagedPreference(forPath path: String) -> Bool {
    return false
  }

  /// Convenience write path used by tests. Not in the real PrefService API,
  /// but harmless to expose.
  public func setBoolean(_ value: Bool, forPath path: String) {
    defaults.set(value, forKey: path)
  }
}

// MARK: - Pref key constants
//
// In Brave these live in C++ and are exported into Swift through BraveCore's
// generated headers. We mirror just the ones Playlist references.

/// Whether the Playlist feature is enabled (possibly forced by policy).
/// Mirrors Chromium's `kPlaylistEnabledPrefName`.
public let kPlaylistEnabledPrefName: String = "brave.playlist.enabled"

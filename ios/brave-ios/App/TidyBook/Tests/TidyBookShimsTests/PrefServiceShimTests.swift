// Copyright 2026 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import XCTest

@testable import TidyBookShims

final class PrefServiceShimTests: XCTestCase {
  private var defaults: UserDefaults!
  private var prefs: PrefService!

  override func setUp() {
    super.setUp()
    // Isolated suite so tests don't pollute the real defaults.
    let suiteName = "tidybook.tests.\(UUID().uuidString)"
    defaults = UserDefaults(suiteName: suiteName)!
    prefs = PrefService(defaults: defaults)
  }

  override func tearDown() {
    defaults.removePersistentDomain(forName: defaults.dictionaryRepresentation().description)
    prefs = nil
    defaults = nil
    super.tearDown()
  }

  func testBooleanRoundTrip() {
    XCTAssertFalse(prefs.boolean(forPath: kPlaylistEnabledPrefName))
    prefs.setBoolean(true, forPath: kPlaylistEnabledPrefName)
    XCTAssertTrue(prefs.boolean(forPath: kPlaylistEnabledPrefName))
  }

  func testUnknownKeyReturnsFalse() {
    XCTAssertFalse(prefs.boolean(forPath: "some.unknown.path"))
  }

  func testIsManagedAlwaysFalse() {
    // TidyBook is consumer-only, no MDM policy.
    XCTAssertFalse(prefs.isManagedPreference(forPath: kPlaylistEnabledPrefName))
    prefs.setBoolean(true, forPath: kPlaylistEnabledPrefName)
    XCTAssertFalse(prefs.isManagedPreference(forPath: kPlaylistEnabledPrefName))
  }

  func testPlaylistEnabledPrefNameStable() {
    // This key is observed in storage; renaming it would migrate prefs.
    XCTAssertEqual(kPlaylistEnabledPrefName, "brave.playlist.enabled")
  }
}

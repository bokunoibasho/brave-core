// Copyright 2026 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import Foundation

// MARK: - BraveShields shim (no-op)
//
// In Brave, the `BraveShields` module exposes per-domain ad/tracker block
// settings, fingerprint protections, etc. Playlist consults a handful of
// these for things like "should we strip the Referer header on this load".
//
// TidyBook is a personal music-app, not a privacy browser. We provide
// permissive no-op replacements: every shield reports "disabled", every
// request is allowed through.
//
// If you decide to add ad-blocking later, replace these stubs with
// `WKContentRuleList`-based logic.

public enum ShieldLevel {
  case allow
  case standard
  case aggressive
}

public enum BraveShields {
  /// Whether the given URL should have ad-blocking applied. TidyBook always
  /// returns false (allow everything).
  public static func adBlockEnabled(for url: URL) -> Bool { false }

  /// Whether trackers should be blocked. Always false in TidyBook.
  public static func trackerBlockEnabled(for url: URL) -> Bool { false }

  /// HTTPS-upgrade level. TidyBook leaves URLs as-is.
  public static func httpsUpgradeLevel(for url: URL) -> ShieldLevel { .allow }
}

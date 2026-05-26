// Copyright 2026 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import Foundation
import UIKit

// MARK: - UserAgent shim
//
// Brave's `UserAgent` module is a sizable utility that picks per-site UA
// strings, handles desktop-mode toggles, etc. For TidyBook's narrow
// use-case (loading YouTube to extract `<video>` URLs), a static
// mobile-Safari UA is sufficient.

public enum UserAgent {
  /// A Mobile Safari user-agent string that YouTube and most sites accept.
  ///
  /// We deliberately advertise a recent iPhone Safari rather than a
  /// custom token so that mobile site variants (e.g. m.youtube.com) are
  /// served.
  public static let mobile: String = {
    let device = UIDevice.current
    let osVersion = device.systemVersion.replacingOccurrences(of: ".", with: "_")
    return
      "Mozilla/5.0 (iPhone; CPU iPhone OS \(osVersion) like Mac OS X) "
      + "AppleWebKit/605.1.15 (KHTML, like Gecko) "
      + "Version/\(device.systemVersion) Mobile/15E148 Safari/604.1"
  }()

  /// Brave's API takes a URL so per-site UAs are possible. TidyBook ignores
  /// the URL and always returns the mobile UA.
  public static func userAgent(forURL url: URL) -> String {
    return mobile
  }
}

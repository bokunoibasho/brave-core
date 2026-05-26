// Copyright 2026 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import Foundation
import OSLog

// MARK: - Logger shim
//
// Brave's `Shared` module exposes a `Logger.module` static used widely in
// Playlist (e.g. `Logger.module.error("...")`). It's a thin wrapper around
// `os.Logger` plus categorization.
//
// We provide a minimal `Logger.module` here in TidyBookShims for code that
// has been adapted to `import TidyBookShims` instead of `import Shared`.

extension Logger {
  /// Module-scoped logger used by Playlist code.
  ///
  /// Matches the API shape of `Shared.Logger.module` closely enough that
  /// the call sites compile unchanged.
  public static let module = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "app.tidybook",
    category: "TidyBook"
  )
}

// Copyright 2026 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import AVFoundation
import SwiftUI

// MARK: - App entry point
//
// Launches the app directly into the Playlist root view. Configures the
// audio session for `.playback` so audio continues when the screen is
// locked or the app is backgrounded.
//
// The app target's Info.plist must declare:
//   UIBackgroundModes = ["audio"]
// for this to take effect on a real device.

@main
struct TidyBookApp: App {
  init() {
    configureAudioSession()
  }

  var body: some Scene {
    WindowGroup {
      TidyBookRootView()
    }
  }

  private func configureAudioSession() {
    do {
      try AVAudioSession.sharedInstance().setCategory(
        .playback,
        mode: .default,
        options: []
      )
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      // Logging only — failing to set the category is non-fatal at startup.
      // The user just won't get background audio until they tap play again
      // (which retries via AVPlayer).
      print("TidyBook: failed to set audio session: \(error)")
    }
  }
}

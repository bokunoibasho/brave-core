// Copyright 2026 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI
import WebKit

// MARK: - SwiftUI wrapper for the mini-browser
//
// `BrowserView` is the public surface of `TidyBookBrowser`. The app
// (`TidyBook` target) presents this as a sheet when the user taps the
// "+" button on the Playlist root view.
//
// Detected media (via `PlaylistScript.js` injection) is forwarded to the
// `onMediaDetected` callback so the host app can hand it to PlaylistManager.

public struct BrowserView: View {
  /// Initial URL when the browser opens. Defaults to YouTube mobile.
  public let initialURL: URL

  /// Called whenever the injected media-detection script reports a
  /// playable `<video>`/`<audio>` source. The host wires this into the
  /// Playlist data layer.
  public let onMediaDetected: (DetectedMedia) -> Void

  /// Tapped when the user wants to close the browser (e.g. from a
  /// nav-bar button).
  public let onDismiss: () -> Void

  public init(
    initialURL: URL = URL(string: "https://m.youtube.com/")!,
    onMediaDetected: @escaping (DetectedMedia) -> Void,
    onDismiss: @escaping () -> Void
  ) {
    self.initialURL = initialURL
    self.onMediaDetected = onMediaDetected
    self.onDismiss = onDismiss
  }

  public var body: some View {
    NavigationStack {
      WebViewContainer(
        initialURL: initialURL,
        onMediaDetected: onMediaDetected
      )
      .ignoresSafeArea(edges: .bottom)
      .navigationTitle("Add from web")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close", action: onDismiss)
        }
      }
    }
  }
}

// MARK: - Detected media model
//
// Mirrors the fields PlaylistScript.js posts back from the page. The host
// app converts this into a Playlist data-layer entity.

public struct DetectedMedia: Equatable, Sendable {
  public let pageURL: URL
  public let pageTitle: String
  public let mediaURL: URL
  public let mimeType: String?
  public let duration: TimeInterval?

  public init(
    pageURL: URL,
    pageTitle: String,
    mediaURL: URL,
    mimeType: String?,
    duration: TimeInterval?
  ) {
    self.pageURL = pageURL
    self.pageTitle = pageTitle
    self.mediaURL = mediaURL
    self.mimeType = mimeType
    self.duration = duration
  }
}

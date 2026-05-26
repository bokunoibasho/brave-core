// Copyright 2026 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import OSLog
import SwiftUI
import TidyBookShims
import UIKit
import WebKit

// MARK: - UIViewControllerRepresentable wrapper for WKWebView
//
// Owns a single `WKWebView` plus the injected media-detection user-script
// and the message handler that bridges JS -> Swift.

struct WebViewContainer: UIViewControllerRepresentable {
  let initialURL: URL
  let onMediaDetected: (DetectedMedia) -> Void

  func makeUIViewController(context: Context) -> WebViewController {
    let controller = WebViewController(
      initialURL: initialURL,
      onMediaDetected: onMediaDetected
    )
    return controller
  }

  func updateUIViewController(_ controller: WebViewController, context: Context) {
    // No-op: state lives on the controller.
  }
}

// MARK: - WebViewController
//
// Hosts the WKWebView, sets the user-agent, installs the JS bridge, and
// loads the initial URL. Keeping this as a UIViewController (rather than
// a UIViewRepresentable) makes the WKWebView lifetime explicit and lets
// us add a URL bar / back-forward toolbar later.

final class WebViewController: UIViewController {
  private let initialURL: URL
  private let onMediaDetected: (DetectedMedia) -> Void
  private var webView: WKWebView!
  private let messageHandlerName = "tidybookMediaDetector"

  init(initialURL: URL, onMediaDetected: @escaping (DetectedMedia) -> Void) {
    self.initialURL = initialURL
    self.onMediaDetected = onMediaDetected
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported")
  }

  override func loadView() {
    let config = WKWebViewConfiguration()
    config.allowsInlineMediaPlayback = true
    config.mediaTypesRequiringUserActionForPlayback = []

    let userContent = WKUserContentController()
    // Install JS->Swift bridge. JS calls
    //   window.webkit.messageHandlers.tidybookMediaDetector.postMessage(payload)
    // and the handler below receives `payload`.
    userContent.add(
      MessageHandlerProxy(target: self),
      name: messageHandlerName
    )
    if let script = Self.loadMediaDetectionScript() {
      userContent.addUserScript(
        WKUserScript(
          source: script,
          injectionTime: .atDocumentStart,
          forMainFrameOnly: false
        )
      )
    } else {
      Logger.module.error("TidyBookBrowser: media-detection script not found")
    }
    config.userContentController = userContent

    let web = WKWebView(frame: .zero, configuration: config)
    web.customUserAgent = UserAgent.mobile
    web.allowsBackForwardNavigationGestures = true
    self.webView = web
    self.view = web
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    webView.load(URLRequest(url: initialURL))
  }

  // MARK: - JS bridge

  fileprivate func handleScriptMessage(_ body: Any) {
    // The injected JS posts a dictionary with keys "src", "pageURL",
    // "pageTitle", "mimeType", "duration". Decode defensively.
    guard
      let dict = body as? [String: Any],
      let mediaString = dict["src"] as? String,
      let mediaURL = URL(string: mediaString),
      let pageString = dict["pageURL"] as? String,
      let pageURL = URL(string: pageString)
    else {
      return
    }
    let detected = DetectedMedia(
      pageURL: pageURL,
      pageTitle: dict["pageTitle"] as? String ?? "",
      mediaURL: mediaURL,
      mimeType: dict["mimeType"] as? String,
      duration: dict["duration"] as? TimeInterval
    )
    onMediaDetected(detected)
  }

  // MARK: - Script loading

  /// Loads the bundled media-detection script. For now this is a small
  /// inline detector that finds `<video>` and `<audio>` elements; later we
  /// can swap in Brave's PlaylistScript.js verbatim (it lives at
  /// `Sources/Brave/Frontend/UserContent/UserScripts/Scripts_Dynamic/Scripts/Paged/PlaylistScript.js`
  /// in the brave-core tree).
  private static func loadMediaDetectionScript() -> String? {
    return """
      (function() {
        const channel =
          window.webkit && window.webkit.messageHandlers &&
          window.webkit.messageHandlers.tidybookMediaDetector;
        if (!channel) return;

        function report(el) {
          if (!el || !el.src) return;
          channel.postMessage({
            src: el.currentSrc || el.src,
            pageURL: location.href,
            pageTitle: document.title,
            mimeType: el.type || null,
            duration: isFinite(el.duration) ? el.duration : null
          });
        }

        function scan() {
          document.querySelectorAll('video, audio').forEach(report);
        }

        // Initial scan + periodic re-scan to catch lazy players.
        scan();
        setInterval(scan, 2000);

        // Catch elements added after load.
        const observer = new MutationObserver(scan);
        observer.observe(document.documentElement, {
          childList: true, subtree: true
        });
      })();
      """
  }
}

// MARK: - WKScriptMessageHandler proxy
//
// We can't make `WebViewController` itself the WKScriptMessageHandler
// because that creates a strong retain cycle through WKUserContentController.
// The proxy holds the controller weakly.

private final class MessageHandlerProxy: NSObject, WKScriptMessageHandler {
  private weak var target: WebViewController?

  init(target: WebViewController) {
    self.target = target
  }

  func userContentController(
    _ userContentController: WKUserContentController,
    didReceive message: WKScriptMessage
  ) {
    target?.handleScriptMessage(message.body)
  }
}

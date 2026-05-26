// Copyright 2026 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI
import TidyBookBrowser

// MARK: - Root view
//
// In the eventual product this should render Brave's `PlaylistRootView`
// directly. For now (Phase 1 scaffold) it shows a placeholder library
// view with a "+" button that opens the mini-browser sheet.
//
// Swapping to Brave's PlaylistUI is tracked in Phase 2.

struct TidyBookRootView: View {
  @State private var showBrowser = false
  @State private var library: [LibraryEntry] = []

  var body: some View {
    NavigationStack {
      Group {
        if library.isEmpty {
          ContentUnavailableView(
            "No songs yet",
            systemImage: "music.note.list",
            description: Text("Tap + to find music on the web.")
          )
        } else {
          List(library) { entry in
            VStack(alignment: .leading) {
              Text(entry.title).font(.body)
              Text(entry.pageURL.absoluteString)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }
          }
        }
      }
      .navigationTitle("Tidy Book")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            showBrowser = true
          } label: {
            Image(systemName: "plus")
          }
          .accessibilityLabel("Add song from web")
        }
      }
    }
    .sheet(isPresented: $showBrowser) {
      BrowserView(
        onMediaDetected: { detected in
          // Phase 1: just record what we saw so the empty state goes away.
          // Phase 2 replaces this with PlaylistManager.shared.addItem(...).
          let entry = LibraryEntry(
            id: detected.mediaURL,
            title: detected.pageTitle,
            pageURL: detected.pageURL,
            mediaURL: detected.mediaURL
          )
          if !library.contains(where: { $0.id == entry.id }) {
            library.append(entry)
          }
        },
        onDismiss: {
          showBrowser = false
        }
      )
    }
  }
}

// MARK: - Phase-1 placeholder model
//
// This is a stand-in until we wire up Brave's Core Data-backed
// `PlaylistItem` entities via the real PlaylistManager.

private struct LibraryEntry: Identifiable {
  let id: URL
  let title: String
  let pageURL: URL
  let mediaURL: URL
}

#Preview {
  TidyBookRootView()
}

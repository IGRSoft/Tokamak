// Copyright 2019-2020 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Jed Fox on 07/01/2020.
//

import TokamakShim

#if !canImport(SwiftUI)
  import TokamakCore
#endif

struct TitleViewModifier: ViewModifier {
  let title: String

  @ViewBuilder
  func body(content: Content) -> some View {
    if #available(OSX 10.16, iOS 14.0, *) {
      content.navigationTitle(title)
    } else {
      #if !os(macOS)
        content.navigationBarTitle(title)
      #else
        content
      #endif
    }
  }
}

struct NavItem<Label: View>: View {
  let id: String
  let destination: Label?

  init<V>(_ id: String, destination: V) where V: View, Label == ModifiedContent<V, TitleViewModifier> {
    self.id = id
    self.destination = destination.modifier(TitleViewModifier(title: id))
  }

  init(unavailable id: String) where Label == Never? {
    self.id = id
    self.destination = nil
  }

  @ViewBuilder
  var body: some View {
    if let dest = destination {
      NavigationLink(id, destination: dest)
    } else {
      #if os(WASI)
        Text(id)
      #elseif os(macOS)
        Text(id).opacity(0.5)
      #elseif os(Linux)
        HStack {
          Text(id)
          Spacer()
          Text("unavailable")
        }
      #endif
    }
  }
}

public struct TokamakDemoView: View {
  public init() {}

  // Preserve the original visual section order, derived once from the catalog.
  private var sectionOrder: [String] {
    var seen = [String]()
    for entry in demoCatalog where !seen.contains(entry.section) {
      seen.append(entry.section)
    }
    return seen
  }

  // The hand-written `Section { NavItem … }` block is now derived from `demoCatalog`,
  // grouped by section in the catalog's authoritative order. All other List chrome
  // (header image, frame, title modifier, sidebar/toolbar branch, environmentObject)
  // is preserved verbatim below.
  @ViewBuilder
  private var catalogSections: some View {
    ForEach(sectionOrder, id: \.self) { section in
      Section(header: Text(section)) {
        ForEach(demoCatalog.filter { $0.section == section }) { entry in
          NavItem(entry.name, destination: entry.view)
        }
        // Re-emit the platform-specific unavailable placeholders for this section
        // using the SAME guards as the original List. On the declared targets
        // (macOS 26 / iOS 26) these are all empty (no-op), but they preserve
        // byte-for-byte structural parity if the deployment target is ever lowered.
        unavailablePlaceholders(for: section)
      }
    }
  }

  // The original `else { NavItem(unavailable: "X") }` branches, kept as app chrome
  // (NOT catalog data — a disabled placeholder is not a capturable demo). Guarded
  // identically to the original List.
  @ViewBuilder
  private func unavailablePlaceholders(for section: String) -> some View {
    switch section {
    case "Containers":
      if #available(iOS 14.0, *) {} else { NavItem(unavailable: "Sidebar") }
      if #available(OSX 10.16, iOS 14.0, *) {} else { NavItem(unavailable: "OutlineGroup") }
    case "Layout":
      if #available(OSX 10.16, iOS 14.0, *) {} else { NavItem(unavailable: "Grid") }
    case "Misc":
      if #available(OSX 11.0, iOS 14.0, *) {} else { NavItem(unavailable: "AppStorage") }
      if #available(OSX 11.0, iOS 14.0, *) {} else { NavItem(unavailable: "Redaction") }
    default:
      EmptyView()
    }
  }

  public var body: some View {
    NavigationView {
      let list = List {
        Image("logo-header.png", label: Text("Tokamak Demo"))
          .frame(height: 50)
          .padding(.bottom, 20)
        #if !canImport(SwiftUI)
          LocalePicker()
        #endif
        catalogSections
      }
      .frame(minHeight: 300)
      .modifier(TitleViewModifier(title: "Demos"))

      if #available(iOS 14.0, *) {
        list
          .listStyle(SidebarListStyle())
          .navigationTitle("Tokamak")
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Cancellation Action") {}
            }
            ToolbarItem(placement: .confirmationAction) {
              Button("Confirmation Action") {}
            }
            ToolbarItem(placement: .destructiveAction) {
              Button("Destructive Action") {}
            }
            ToolbarItem(placement: .navigation) {
              Text("Some nav-text")
                .italic()
            }
            ToolbarItem(placement: .status) {
              Text("Status: Live")
                .bold()
                .foregroundColor(.green)
            }
          }
      } else {
        list
      }
    }
    .environmentObject(TestEnvironment())
  }
}

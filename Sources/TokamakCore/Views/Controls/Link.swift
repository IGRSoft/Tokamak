// Copyright 2018-2020 Tokamak contributors
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
//  Created by Carson Katri on 9/9/20.
//

import struct Foundation.URL

/// A control for navigating to a URL.
///
///     Link("View Our Terms of Service", destination: URL(string: "https://example.com/tos")!)
public struct Link<Label>: _PrimitiveView where Label: View {
  let destination: URL
  let label: Label

  /// Creates a control, consisting of a URL and a label, used to navigate to the given URL.
  ///
  /// - Parameters:
  ///   - destination: The URL for the link.
  ///   - label: A view builder that produces the link's label.
  public init(destination: URL, @ViewBuilder label: () -> Label) {
    (self.destination, self.label) = (destination, label())
  }
}

public extension Link where Label == Text {
  /// Creates a control, consisting of a URL and a title string, used to navigate to a URL.
  ///
  /// - Parameters:
  ///   - titleKey: A string that describes the purpose of this link.
  ///   - destination: The URL for the link.
  init<S: StringProtocol>(_ titleKey: S, destination: URL) {
    self.init(destination: destination) { Text(titleKey) }
  }
}

/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _LinkProxy<Label> where Label: View {
  /// The link this proxy reads from.
  public let subject: Link<Label>

  /// Creates a proxy that exposes the internals of the given link.
  ///
  /// - Parameter subject: The link to wrap.
  public init(_ subject: Link<Label>) { self.subject = subject }

  /// The link's label view.
  public var label: Label { subject.label }
  /// The URL the link navigates to.
  public var destination: URL {
    subject.destination
  }
}

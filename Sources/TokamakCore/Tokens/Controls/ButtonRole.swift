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
//  Created by Carson Katri on 7/12/21.
//

/// A value that describes the purpose of a button.
public struct ButtonRole: Equatable, Sendable {
  /// A role that indicates a destructive button.
  public static let destructive = ButtonRole(rawValue: 0)
  /// A role that indicates a button that cancels an operation.
  public static let cancel = ButtonRole(rawValue: 1)

  private let rawValue: Int
  private init(rawValue: Int) {
    self.rawValue = rawValue
  }
}

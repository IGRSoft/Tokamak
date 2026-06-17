// Copyright 2020-2021 Tokamak contributors
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
//  Created by Carson Katri on 7/17/20.
//

/// An interface for a stored variable that updates an external property of a view.
///
/// The view gives values to these properties prior to recomputing the view's
/// ``View/body-swift.property``. Conform to this protocol to create custom
/// property wrappers, such as ``State`` and ``Binding``, that participate in the
/// view update cycle.
public protocol DynamicProperty {
  /// Updates the underlying value of the stored value.
  ///
  /// Tokamak calls this method before rendering a view's body to ensure the view
  /// has the most recent value.
  mutating func update()
}

public extension DynamicProperty {
  /// Updates the underlying value of the stored value.
  ///
  /// The default implementation does nothing.
  mutating func update() {}
}

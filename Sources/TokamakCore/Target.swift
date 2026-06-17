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
//  Created by Max Desiatov on 10/02/2019.
//

/// A platform-specific render target that a renderer mounts views into.
///
/// Renderers declare a concrete conforming type (for example, a DOM node or an
/// `NSView`) as their ``Renderer/TargetType``.
public protocol Target: AnyObject {
  /// The host view currently rendered to this target.
  var view: AnyView { get set }
}

// Copyright 2020 Tokamak contributors
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
//  Created by Carson Katri on 7/22/20.
//

/// A path paired with the stroke style used to trace it.
public struct StrokedPath: Equatable {
  /// The path that is stroked.
  public let path: Path
  /// The style used to stroke the path.
  public let style: StrokeStyle

  /// Creates a stroked path from the given path and stroke style.
  ///
  /// - Parameters:
  ///   - path: The path that is stroked.
  ///   - style: The style used to stroke the path.
  public init(path: Path, style: StrokeStyle) {
    self.path = path
    self.style = style
  }
}

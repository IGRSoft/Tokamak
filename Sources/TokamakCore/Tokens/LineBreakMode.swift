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
//  Created by Max Desiatov on 14/02/2019.
//

/// The strategies for wrapping or truncating text that does not fit on a single line.
public enum LineBreakMode {
  /// Wrapping occurs at word boundaries, unless a single word is too long for the line.
  case wordWrap
  /// Wrapping occurs before the first character that does not fit.
  case charWrap
  /// Lines are simply not drawn past the edge of the bounding rectangle.
  case clip
  /// Text is truncated at the beginning of the line, displaying an ellipsis there.
  case truncateHead
  /// Text is truncated at the end of the line, displaying an ellipsis there.
  case truncateTail
  /// Text is truncated in the middle of the line, displaying an ellipsis there.
  case truncateMiddle
}

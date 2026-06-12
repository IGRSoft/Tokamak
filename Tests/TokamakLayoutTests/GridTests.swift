// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 2/4/23.
//

#if os(macOS) && swift(>=5.7)
import SwiftUI
import TokamakStaticHTML
import XCTest

final class GridTests: XCTestCase {
  override func setUpWithError() throws { try requireReferenceBrowser() }

  @available(macOS 13.0, *)
  func testGrid() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Grid(alignment: .bottomTrailing, horizontalSpacing: 10, verticalSpacing: 10) {
        SwiftUI.GridRow(alignment: .top) {
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.25))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.4))
        }
        SwiftUI.GridRow(alignment: .top) {
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.25))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.4))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.6))
        }
      }
    } to: {
      TokamakStaticHTML.Grid(
        alignment: .bottomTrailing,
        horizontalSpacing: 10,
        verticalSpacing: 10
      ) {
        TokamakStaticHTML.GridRow(alignment: .top) {
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.25))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.4))
        }
        TokamakStaticHTML.GridRow(alignment: .top) {
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.25))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.4))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.6))
        }
      }
    }
  }

  @available(macOS 13.0, *)
  func testGridCellColumns() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Grid(alignment: .bottomTrailing, horizontalSpacing: 10, verticalSpacing: 10) {
        SwiftUI.GridRow(alignment: .top) {
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.25))
            .gridCellColumns(2)
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.4))
        }
        SwiftUI.GridRow(alignment: .top) {
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.25))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.4))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.6))
        }
      }
    } to: {
      TokamakStaticHTML.Grid(
        alignment: .bottomTrailing,
        horizontalSpacing: 10,
        verticalSpacing: 10
      ) {
        TokamakStaticHTML.GridRow(alignment: .top) {
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.25))
            .gridCellColumns(2)
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.4))
        }
        TokamakStaticHTML.GridRow(alignment: .top) {
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.25))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.4))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.6))
        }
      }
    }
  }

  @available(macOS 13.0, *)
  func testGridColumnAlignment() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Grid(alignment: .bottomTrailing, horizontalSpacing: 10, verticalSpacing: 10) {
        SwiftUI.GridRow(alignment: .top) {
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.25))
            .frame(width: 15)
            .gridColumnAlignment(.trailing)
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.4))
        }
        SwiftUI.GridRow(alignment: .top) {
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.25))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.4))
        }
      }
    } to: {
      TokamakStaticHTML.Grid(
        alignment: .bottomTrailing,
        horizontalSpacing: 10,
        verticalSpacing: 10
      ) {
        TokamakStaticHTML.GridRow(alignment: .top) {
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.25))
            .frame(width: 15)
            .gridColumnAlignment(.trailing)
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.4))
        }
        TokamakStaticHTML.GridRow(alignment: .top) {
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.25))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.4))
        }
      }
    }
  }

  @available(macOS 13.0, *)
  func testGridCellAnchor() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Grid(alignment: .topLeading, horizontalSpacing: 10, verticalSpacing: 10) {
        SwiftUI.GridRow(alignment: .top) {
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
            .frame(width: 15, height: 15)
            .gridCellAnchor(.bottomTrailing)
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
        }
        SwiftUI.GridRow(alignment: .top) {
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
            .frame(width: 15, height: 15)
            .gridCellAnchor(.leading)
        }
      }
    } to: {
      TokamakStaticHTML.Grid(alignment: .topLeading, horizontalSpacing: 10, verticalSpacing: 10) {
        TokamakStaticHTML.GridRow(alignment: .top) {
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
            .frame(width: 15, height: 15)
            .gridCellAnchor(.bottomTrailing)
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
        }
        TokamakStaticHTML.GridRow(alignment: .top) {
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
            .frame(width: 15, height: 15)
            .gridCellAnchor(.leading)
        }
      }
    }
  }

  @available(macOS 13.0, *)
  func testGridCellUnsizedAxes() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Grid(alignment: .bottomTrailing, horizontalSpacing: 10, verticalSpacing: 10) {
        SwiftUI.GridRow(alignment: .top) {
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
            .frame(width: 100, height: 100)
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.25))
            .frame(width: 100, height: 100)
        }
        SwiftUI.Rectangle()
          .fill(SwiftUI.Color(white: 0))
          .frame(height: 5)
          .gridCellUnsizedAxes(.horizontal)
        SwiftUI.GridRow(alignment: .top) {
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
            .frame(width: 100, height: 100)
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0.25))
            .frame(width: 100, height: 100)
        }
      }
    } to: {
      TokamakStaticHTML.Grid(
        alignment: .bottomTrailing,
        horizontalSpacing: 10,
        verticalSpacing: 10
      ) {
        TokamakStaticHTML.GridRow(alignment: .top) {
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
            .frame(width: 100, height: 100)
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.25))
            .frame(width: 100, height: 100)
        }
        TokamakStaticHTML.Rectangle()
          .fill(TokamakStaticHTML.Color(white: 0))
          .frame(height: 5)
          .gridCellUnsizedAxes(.horizontal)
        TokamakStaticHTML.GridRow(alignment: .top) {
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
            .frame(width: 100, height: 100)
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0.25))
            .frame(width: 100, height: 100)
        }
      }
    }
  }
}
#endif

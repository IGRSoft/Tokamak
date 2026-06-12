// Copyright 2024 Tokamak contributors
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
//  D5 — Stack→Fiber Reconciler Unification: dual-engine byte-parity oracle.
//
//  Renders every existing HTMLTests fixture body + fuzz rows + one App fixture
//  through BOTH the legacy StackReconciler engine and the new Fiber engine and
//  asserts byte-equality. The engine is selected per-render via the
//  TOKAMAK_SSR_ENGINE env var (wired in C3). Until then both renders are legacy
//  and the assertions pass trivially — the harness compiles and runs.

#if canImport(SnapshotTesting)

import Foundation
@testable import TokamakStaticHTML
import XCTest

final class SSRParityTests: XCTestCase {
  // MARK: - Engine toggle

  private enum Engine: String {
    case legacy
    case fiber
  }

  /// Render `view` under the given SSR engine by toggling the env var the
  /// facade reads at init. Restores the prior value afterward.
  private func render<V: View>(
    _ view: V,
    engine: Engine,
    shouldSortAttributes: Bool = true
  ) -> String {
    let key = "TOKAMAK_SSR_ENGINE"
    let previous = ProcessInfo.processInfo.environment[key]
    setenv(key, engine.rawValue, 1)
    defer {
      if let previous = previous { setenv(key, previous, 1) } else { unsetenv(key) }
    }
    return StaticHTMLRenderer(view).render(shouldSortAttributes: shouldSortAttributes)
  }

  /// Render an `App` under the given SSR engine.
  private func render<A: App>(
    _ app: A,
    engine: Engine,
    shouldSortAttributes: Bool = true
  ) -> String {
    let key = "TOKAMAK_SSR_ENGINE"
    let previous = ProcessInfo.processInfo.environment[key]
    setenv(key, engine.rawValue, 1)
    defer {
      if let previous = previous { setenv(key, previous, 1) } else { unsetenv(key) }
    }
    return StaticHTMLRenderer(app).render(shouldSortAttributes: shouldSortAttributes)
  }

  /// Assert the two engines produce byte-identical output for `view`.
  private func assertParity<V: View>(
    _ view: V,
    _ message: String,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    let legacy = render(view, engine: .legacy)
    let fiber = render(view, engine: .fiber)
    XCTAssertEqual(legacy, fiber, "SSR parity divergence — \(message)", file: file, line: line)
  }

  // MARK: - Ported HTMLTests bodies (the snapshot oracle, engine-differential)

  private struct Model { let color: Color }

  private struct OptionalBody: View {
    var model: Model?
    var body: some View {
      if let color = model?.color {
        VStack {
          color
          Spacer()
        }
      }
    }
  }

  func testOptionalBody() {
    assertParity(OptionalBody(model: Model(color: Color.red)), "optional VStack + Spacer")
    assertParity(OptionalBody(model: nil), "optional empty body")
  }

  func testPaddingFusion() {
    assertParity(Color.red.padding(10).padding(20), "padding fusion x2")
    assertParity(Color.red.padding(20).padding(20).padding(20), "padding fusion x3")
  }

  func testFontStacks() {
    assertParity(
      Text("Hello, world!").font(.custom("Marker Felt", size: 17)),
      "custom font"
    )
    assertParity(
      VStack {
        Text("Hello, world!").font(.custom("Marker Felt", size: 17))
      }
      .font(.system(.body, design: .serif)),
      "fallback font stack"
    )
  }

  func testHTMLSanitizer() {
    let text = "<b>\"Hello\" & 'World'</b> "
    assertParity(Text(text), "sanitized text")
    assertParity(
      Text(text)._domTextSanitizer(Sanitizers.HTML.insecure),
      "insecure (unsanitized) text"
    )
  }

  func testTitle() {
    assertParity(
      VStack {
        HTMLTitle("Tokamak")
        Text("Hello, world!")
      },
      "title preference"
    )
  }

  func testDoubleTitle() {
    // q5: inner title must win (last-write-wins, depth-first).
    assertParity(
      VStack {
        HTMLTitle("Tokamak 1")
        Text("Hello, world!")
        VStack {
          HTMLTitle("Tokamak 2")
        }
      },
      "double title (inner wins)"
    )
  }

  func testTitleModifier() {
    assertParity(Text("Hello, world!").htmlTitle("Tokamak"), "title modifier")
  }

  func testDoubleTitleModifier() {
    assertParity(
      Text("Hello, world!").htmlTitle("Tokamak 1").htmlTitle("Tokamak 2"),
      "double title modifier (last wins)"
    )
  }

  func testMetaCharset() {
    assertParity(
      VStack {
        HTMLMeta(charset: "utf-8")
        Text("Hello, world!")
      },
      "meta charset"
    )
  }

  func testMetaCharsetModifier() {
    assertParity(Text("Hello, world!").htmlMeta(charset: "utf-8"), "meta charset modifier")
  }

  func testMetaAll() {
    assertParity(
      VStack {
        HTMLMeta(charset: "utf-8")
        HTMLMeta(name: "description", content: "SwiftUI on the web")
        HTMLMeta(property: "og:image", content: "https://image.png")
        HTMLMeta(httpEquiv: "refresh", content: "60")
        Text("Hello, world!")
      },
      "all meta tags"
    )
  }

  func testPreferencePropagation() {
    // q5: scoped reductions (title0==Tokamak 3, title1==1, title2==2, title3==3).
    assertParity(
      VStack {
        HTMLTitle("Tokamak 1")
          .onPreferenceChange(HTMLTitlePreferenceKey.self) { _ in }
        VStack {
          HTMLTitle("Tokamak 2")
        }
        .onPreferenceChange(HTMLTitlePreferenceKey.self) { _ in }
        VStack {
          HTMLTitle("Tokamak 3")
        }
        .onPreferenceChange(HTMLTitlePreferenceKey.self) { _ in }
      }
      .onPreferenceChange(HTMLTitlePreferenceKey.self) { _ in },
      "scoped preference propagation"
    )
  }

  // MARK: - Differential fuzz rows (R4 — inputs without a recorded fixture)

  func testFuzzNestedStacks() {
    assertParity(
      VStack {
        HStack {
          ZStack {
            VStack {
              Text("a")
              Text("b")
            }
          }
        }
      },
      "nested VStack/HStack/ZStack 4-deep"
    )
  }

  func testFuzzModifierChains() {
    assertParity(
      Color.blue.frame(width: 10, height: 10).padding(5),
      "frame + padding"
    )
    assertParity(
      VStack { Text("x") }.background(Color.red).overlay(Color.green),
      "background + overlay"
    )
  }

  func testFuzzConditionals() {
    assertParity(
      VStack {
        Group {
          Text("g1")
          Text("g2")
        }
        Text("after")
      },
      "Group + TupleView flatten"
    )
  }

  func testFuzzFontFallback() {
    assertParity(
      Text("fallback").font(.system(.body, design: .monospaced)),
      "monospaced system font"
    )
  }

  func testFuzzSanitizerEdges() {
    assertParity(Text("a\nb\nc"), "newline -> <br />")
    assertParity(Text("& < > \" '"), "five escape chars")
  }

  // MARK: - App fixture (AC-2 — App-path title/meta, host-untested today)

  private struct TestApp: App {
    var body: some Scene {
      WindowGroup {
        VStack {
          HTMLTitle("SSRTest")
          Text("App body")
        }
      }
    }
  }

  // MARK: - D2 accumulator equivalence (C5)

  /// Verbatim reimplementation of the pre-D2 map/join serializer, used to prove
  /// the inout-buffer accumulator produces identical bytes on a deep tree.
  private func legacyJoinOuterHTML(
    html: AnyHTML,
    children: [HTMLTarget],
    shouldSortAttributes: Bool
  ) -> String {
    let attributes = html.attributes
    let renderedAttributes: String
    if attributes.isEmpty {
      renderedAttributes = ""
    } else {
      let mappedAttributes = attributes
        .filter { !$1.isEmpty }
        .map { #"\#($0)="\#($1)""# }
      if shouldSortAttributes {
        renderedAttributes = mappedAttributes.sorted().joined(separator: " ")
      } else {
        renderedAttributes = mappedAttributes.joined(separator: " ")
      }
    }
    return """
    <\(html.tag)\(attributes.isEmpty ? "" : " ")\
    \(renderedAttributes)>\
    \(html.innerHTML(shouldSortAttributes: shouldSortAttributes) ?? "")\
    \(children
      .map { legacyJoinOuterHTML(
        html: $0.html,
        children: $0.children,
        shouldSortAttributes: shouldSortAttributes
      ) }
      .joined(separator: "\n"))\
    </\(html.tag)>
    """
  }

  func testD2AccumulatorEquivalence() {
    // 6-level nested stacks with leaf Texts — exercises sibling separators,
    // empty-attribute filtering, and innerHTML at depth.
    let renderer = StaticHTMLRenderer(
      VStack {
        HStack {
          VStack {
            HStack {
              VStack {
                Text("deep")
                Text("siblings")
              }
              Text("mid")
            }
          }
          Text("shallow")
        }
        Text("top")
      }
    )
    let root = renderer.rootTarget
    let accumulated = root.outerHTML(shouldSortAttributes: true)
    let joined = legacyJoinOuterHTML(
      html: root.html,
      children: root.children,
      shouldSortAttributes: true
    )
    XCTAssertEqual(accumulated, joined, "D2 accumulator must be byte-identical to map/join")
  }

  func testAppPath() {
    let legacy = render(TestApp(), engine: .legacy)
    let fiber = render(TestApp(), engine: .fiber)
    XCTAssertEqual(legacy, fiber, "App-path full document parity")
    XCTAssertTrue(legacy.contains("<title>SSRTest</title>"), "legacy App title extracted")
    XCTAssertTrue(fiber.contains("<title>SSRTest</title>"), "fiber App title extracted")
  }
}

#endif

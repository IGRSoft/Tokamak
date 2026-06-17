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
//  Created by Carson Katri on 7/20/20.
//

#if canImport(JavaScriptKit)
import JavaScriptKit
import OpenCombineShim
import TokamakCore

// Single-threaded JS event loop (WASM): web storage is only accessed on the main JS
// thread, so this module-level state is never touched concurrently.
nonisolated(unsafe) private let rootPublisher = ObservableObjectPublisher()
nonisolated(unsafe) private let localStorage = JSObject.global.localStorage.object!

/// A storage provider backed by the browser's `localStorage`, persisting `AppStorage` values.
public class LocalStorage: WebStorage, _StorageProvider {
  nonisolated(unsafe) static let closure = JSClosure { _ in
    rootPublisher.send()
    return .undefined
  }

  let storage = localStorage

  required init() {
    _ = JSObject.global.window.object!.addEventListener!("storage", Self.closure)
    publisher = rootPublisher
  }

  /// The shared `localStorage`-backed provider used as the default app storage.
  public static var standard: _StorageProvider {
    Self()
  }

  /// Publishes a change whenever a stored value is written.
  public let publisher: ObservableObjectPublisher
}

#endif

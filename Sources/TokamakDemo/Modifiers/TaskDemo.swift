// Copyright 2021 Tokamak contributors
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

#if os(WASI) && canImport(_Concurrency)
  import TokamakDOM

  // NOTE: The live `fetch`-driven version of this demo (see git history) cannot
  // compile under the swift-6.3.2 wasm toolchain's strict concurrency: TokamakCore's
  // `.task(_:)` takes an `@escaping @Sendable () async -> ()`, but `TokamakCore.View`
  // is not `@MainActor`, so a stateful `View` cannot capture `self` in that
  // `@Sendable` closure, and JavaScriptKit's `JSPromise`/`JSValue` are non-Sendable
  // across the await. Reinstating the real fetch needs a strict-concurrency-friendly
  // rewrite of the async story (framework-level). Until then this is a static
  // placeholder so the demo still appears in the wasm gallery and the bundle builds.
  struct TaskDemo: View {
    var body: some View {
      VStack {
        Text("Async `.task` fetch demo")
        Text("(disabled under strict concurrency — see TaskDemo.swift)")
      }
    }
  }
#endif

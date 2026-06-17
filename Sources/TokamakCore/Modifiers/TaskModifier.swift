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

public extension View {
  /// Adds an asynchronous task to perform before this view appears.
  ///
  /// Use this modifier to perform an asynchronous task with a lifetime that matches that of the
  /// modified view. The task starts when the view appears and is cancelled when it disappears.
  /// - Parameters:
  ///   - priority: The task priority to use when creating the asynchronous task. The default
  ///     priority is `userInitiated`.
  ///   - action: A closure that runs asynchronously when the view appears.
  /// - Returns: A view that runs the specified action asynchronously when the view appears.
  func task(
    priority: TaskPriority = .userInitiated,
    _ action: @escaping @Sendable () async -> ()
  ) -> some View {
    var task: Task<(), Never>?
    return onAppear {
      task = Task(priority: priority, operation: action)
    }
    .onDisappear {
      task?.cancel()
    }
  }
}

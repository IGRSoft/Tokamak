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
//  Created by Max Desiatov on 21/12/2018.
//

import TokamakCore

/// A scheduler that runs the given work immediately on the calling thread.
///
/// Using a synchronous scheduler keeps test rendering deterministic across all platforms.
///
/// - Parameter closure: The work to run immediately.
public func testScheduler(closure: @escaping () -> ()) {
  // immediate scheduler on all platforms for easier debugging and support on all platforms
  closure()
}

/// A `Renderer` that renders a view tree into an inspectable tree of ``TestView`` targets.
///
/// This is the stack-reconciler-based test renderer; it mounts and updates ``TestView``
/// instances synchronously so tests can examine the resulting subview hierarchy.
public final class TestRenderer: Renderer {
  /// The reconciler driving this renderer's view tree.
  public private(set) var reconciler: StackReconciler<TestRenderer>?

  /// The root ``TestView`` that rendered content is mounted under.
  public var rootTarget: TestView {
    reconciler!.rootTarget
  }

  /// Creates a renderer that mounts the given app's scenes.
  ///
  /// - Parameter app: The app whose body is rendered.
  public init<A: App>(_ app: A) {
    reconciler = StackReconciler(
      app: app,
      target: TestView(EmptyView()),
      environment: .init(),
      renderer: self,
      scheduler: testScheduler
    )
  }

  /// Creates a renderer that mounts the given view.
  ///
  /// - Parameter view: The root view to render.
  public init<V: View>(_ view: V) {
    reconciler = StackReconciler(
      view: view,
      target: TestView(EmptyView()),
      environment: .init(),
      renderer: self,
      scheduler: testScheduler
    )
  }

  /// Mounts a new ``TestView`` target as a subview of `parent`.
  ///
  /// - Parameters:
  ///   - before: The sibling to insert before; unused by the test renderer.
  ///   - parent: The parent target to add the new subview to.
  ///   - mountedHost: The mounted host describing the view to mount.
  /// - Returns: The newly created ``TestView`` target.
  public func mountTarget(
    before _: TestView?,
    to parent: TestView,
    with mountedHost: TestRenderer.MountedHost
  ) -> TestView? {
    let result = TestView(mountedHost.view)
    parent.add(subview: result)

    return result
  }

  /// Updates an existing target; a no-op for the test renderer.
  ///
  /// - Parameters:
  ///   - target: The target to update.
  ///   - mountedHost: The mounted host describing the new view state.
  public func update(
    target: TestView,
    with mountedHost: TestRenderer.MountedHost
  ) {}

  /// Unmounts a target by removing it from its parent and finishing the unmount task.
  ///
  /// - Parameters:
  ///   - target: The target to remove.
  ///   - parent: The parent the target is removed from.
  ///   - task: The unmount task to finish once removal completes.
  public func unmount(
    target: TestView,
    from parent: TestView,
    with task: UnmountHostTask<TestRenderer>
  ) {
    target.removeFromSuperview()
    task.finish()
  }

  /// Returns the primitive body for a view; always `nil` for the test renderer.
  ///
  /// - Parameter view: The view to inspect.
  /// - Returns: Always `nil`, since the test renderer has no primitive views.
  public func primitiveBody(for view: Any) -> AnyView? {
    nil
  }

  /// Returns whether a view type is a renderer primitive; always `false` for the test renderer.
  ///
  /// - Parameter type: The view type to test.
  /// - Returns: Always `false`, since the test renderer has no primitive views.
  public func isPrimitiveView(_ type: Any.Type) -> Bool {
    false
  }
}

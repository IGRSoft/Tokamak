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
//  Created by Carson Katri on 9/17/21.
//

import Foundation

/// A view that updates according to a schedule that you provide.
///
/// A timeline view acts as a container with no appearance of its own. Instead, it redraws the
/// content it contains at scheduled points in time.
///
/// ```swift
/// TimelineView(.periodic(from: .now, by: 1)) { context in
///   Text(context.date.description)
/// }
/// ```
public struct TimelineView<Schedule, Content> where Schedule: TimelineSchedule {
  let schedule: Schedule
  let content: (Context) -> Content

  /// Information passed to a timeline view's content callback.
  public struct Context {
    /// A rate at which a timeline view updates its content.
    public enum Cadence: Hashable, Comparable {
      /// Updates the view continuously.
      case live
      /// Updates the view approximately once every second.
      case seconds
      /// Updates the view approximately once every minute.
      case minutes
    }

    let dateProvider: () -> Date
    /// The date from the schedule that triggered the current update.
    public var date: Date { dateProvider() }
    /// The rate at which the timeline view updates its content.
    public let cadence: Cadence
  }

  /// The context type for a timeline view that updates every minute and renders no content.
  public typealias TimelineViewDefaultContext = TimelineView<EveryMinuteTimelineSchedule, Never>.Context
}

extension TimelineView: View, _PrimitiveView where Content: View {
  /// Creates a timeline view that updates its content on the given schedule.
  ///
  /// - Parameters:
  ///   - schedule: The schedule that determines when the view updates.
  ///   - content: A view builder that produces the content, receiving the update context.
  public init(
    _ schedule: Schedule,
    @ViewBuilder content: @escaping (Context) -> Content
  ) {
    self.schedule = schedule
    self.content = content
  }
}

/// A helper type that works around the absence of "package private" access control in Swift.
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _TimelineViewProxy<Schedule, Content> where Schedule: TimelineSchedule {
  let subject: TimelineView<Schedule, Content>

  /// Wraps the given timeline view so renderers can drive its schedule and content.
  public init(_ subject: TimelineView<Schedule, Content>) {
    self.subject = subject
  }

  /// The schedule that determines when the wrapped view updates.
  public var schedule: Schedule { subject.schedule }
  /// The content callback of the wrapped timeline view.
  public var content: (TimelineView<Schedule, Content>.Context) -> Content { subject.content }

  /// Builds a context for the wrapped view using the given date provider.
  ///
  /// - Parameter date: A closure that supplies the date for the current update.
  /// - Returns: A context with a live cadence and the given date provider.
  public func context(date: @escaping () -> Date) -> TimelineView<Schedule, Content>.Context {
    .init(dateProvider: date, cadence: .live)
  }
}

/// A type that provides a sequence of dates for use as a schedule.
public protocol TimelineSchedule {
  /// The mode that determines how frequently a schedule produces entries.
  typealias Mode = TimelineScheduleMode
  /// The sequence of dates within a schedule.
  associatedtype Entries: Sequence where Entries.Element == Date
  /// Provides a sequence of dates starting around the given date.
  ///
  /// - Parameters:
  ///   - startDate: The date from which the sequence begins.
  ///   - mode: The frequency mode for the schedule.
  /// - Returns: A sequence of dates at which the timeline should update.
  func entries(from startDate: Date, mode: Self.Mode) -> Self.Entries
}

/// The mode of a schedule that determines how frequently it produces entries.
public enum TimelineScheduleMode: Hashable {
  /// Provides dates at the schedule's normal frequency.
  case normal
  /// Provides dates at a reduced frequency to conserve resources.
  case lowFrequency
}

extension TimelineSchedule where Self == PeriodicTimelineSchedule {
  /// A schedule for updating a timeline view at regular intervals.
  ///
  /// - Parameters:
  ///   - startDate: The date on which to start the sequence of updates.
  ///   - interval: The time interval between updates.
  /// - Returns: A periodic timeline schedule.
  @inlinable
  public static func periodic(
    from startDate: Date,
    by interval: TimeInterval
  ) -> PeriodicTimelineSchedule {
    .init(from: startDate, by: interval)
  }
}

extension TimelineSchedule where Self == EveryMinuteTimelineSchedule {
  /// A schedule for updating a timeline view at the start of every minute.
  @inlinable
  public static var everyMinute: EveryMinuteTimelineSchedule { .init() }
}

extension TimelineSchedule {
  /// A schedule composed of the dates you explicitly provide.
  ///
  /// - Parameter dates: The sequence of dates at which to update the view.
  /// - Returns: An explicit timeline schedule built from the given dates.
  public static func explicit<S>(_ dates: S) -> ExplicitTimelineSchedule<S>
  where Self == ExplicitTimelineSchedule<S>, S.Element == Date {
    .init(dates)
  }
}

/// A schedule for updating a timeline view at regular intervals.
public struct PeriodicTimelineSchedule: TimelineSchedule {
  private let entries: Entries

  /// The sequence of dates produced by a periodic timeline schedule.
  public struct Entries: Sequence, IteratorProtocol {
    var date: Date
    let interval: TimeInterval

    /// Advances to and returns the next date in the schedule.
    public mutating func next() -> Date? {
      defer { date.addTimeInterval(interval) }
      return date
    }

    /// The type of element produced by the sequence.
    public typealias Element = Date
    /// The iterator type that produces the sequence's dates.
    public typealias Iterator = Self
  }

  /// Creates a periodic schedule beginning at the given date and repeating at the given interval.
  ///
  /// - Parameters:
  ///   - startDate: The date on which to start the sequence of updates.
  ///   - interval: The time interval between updates.
  public init(from startDate: Date, by interval: TimeInterval) {
    entries = Entries(date: startDate, interval: interval)
  }

  /// Provides the sequence of dates at which the timeline updates.
  ///
  /// - Parameters:
  ///   - startDate: The date from which the sequence begins.
  ///   - mode: The frequency mode for the schedule.
  /// - Returns: The sequence of update dates.
  public func entries(from startDate: Date, mode: TimelineScheduleMode) -> Entries {
    entries
  }
}

/// A schedule for updating a timeline view at the start of every minute.
public struct EveryMinuteTimelineSchedule: TimelineSchedule {
  /// The sequence of dates produced by an every-minute timeline schedule.
  public struct Entries: Sequence, IteratorProtocol {
    var date: Date

    /// Advances to and returns the next date in the schedule.
    public mutating func next() -> Date? {
      defer { date.addTimeInterval(60) }
      return date
    }

    /// The type of element produced by the sequence.
    public typealias Element = Date
    /// The iterator type that produces the sequence's dates.
    public typealias Iterator = Self
  }

  /// Creates an every-minute timeline schedule.
  public init() {}

  /// Provides the sequence of dates at which the timeline updates.
  ///
  /// - Parameters:
  ///   - startDate: The date from which the sequence begins.
  ///   - mode: The frequency mode for the schedule.
  /// - Returns: The sequence of update dates.
  public func entries(
    from startDate: Date,
    mode: TimelineScheduleMode
  ) -> EveryMinuteTimelineSchedule.Entries {
    Entries(date: startDate)
  }
}

/// A schedule composed of an explicit sequence of dates that you provide.
public struct ExplicitTimelineSchedule<Entries>: TimelineSchedule
where
  Entries: Sequence,
  Entries.Element == Date
{
  private let dates: Entries

  /// Creates a schedule from the given sequence of dates.
  ///
  /// - Parameter dates: The dates at which to update the view.
  public init(_ dates: Entries) {
    self.dates = dates
  }

  /// Provides the sequence of dates at which the timeline updates.
  ///
  /// - Parameters:
  ///   - startDate: The date from which the sequence begins.
  ///   - mode: The frequency mode for the schedule.
  /// - Returns: The sequence of update dates.
  public func entries(from startDate: Date, mode: TimelineScheduleMode) -> Entries {
    dates
  }
}

extension TimelineSchedule where Self == AnimationTimelineSchedule {
  /// A schedule for updating a timeline view at the device's natural refresh rate.
  @inlinable
  public static var animation: AnimationTimelineSchedule { .init() }
  /// A schedule for updating a timeline view at the device's refresh rate, with options.
  ///
  /// - Parameters:
  ///   - minimumInterval: The minimum interval between updates, or `nil` for the natural rate.
  ///   - paused: Whether the schedule is paused. Defaults to `false`.
  /// - Returns: An animation timeline schedule.
  @inlinable
  public static func animation(
    minimumInterval: Double? = nil,
    paused: Bool = false
  ) -> AnimationTimelineSchedule {
    .init(minimumInterval: minimumInterval, paused: paused)
  }
}

/// A schedule for updating a timeline view at the device's natural refresh rate.
public struct AnimationTimelineSchedule: TimelineSchedule {
  private let minimumInterval: Double?
  /// An implementation detail of Tokamak's rendering; not intended for use in application code.
  public let _paused: Bool

  /// The sequence of dates produced by an animation timeline schedule.
  public struct Entries: Sequence, IteratorProtocol {
    var date: Date
    let minimumInterval: Double?
    let paused: Bool

    /// Advances to and returns the next date in the schedule, or `nil` when paused.
    public mutating func next() -> Date? {
      guard !paused else { return nil }
      defer { date.addTimeInterval(minimumInterval ?? (1 / 60)) }
      return date
    }

    /// The type of element produced by the sequence.
    public typealias Element = Date
    /// The iterator type that produces the sequence's dates.
    public typealias Iterator = Self
  }

  /// Creates an animation schedule with the given minimum interval and paused state.
  ///
  /// - Parameters:
  ///   - minimumInterval: The minimum interval between updates, or `nil` for the natural rate.
  ///   - paused: Whether the schedule is paused. Defaults to `false`.
  public init(minimumInterval: Double? = nil, paused: Bool = false) {
    self.minimumInterval = minimumInterval
    _paused = paused
  }

  /// Provides the sequence of dates at which the timeline updates.
  ///
  /// - Parameters:
  ///   - startDate: The date from which the sequence begins.
  ///   - mode: The frequency mode for the schedule.
  /// - Returns: The sequence of update dates.
  public func entries(from startDate: Date, mode: TimelineScheduleMode) -> Entries {
    Entries(date: startDate, minimumInterval: minimumInterval, paused: _paused)
  }
}

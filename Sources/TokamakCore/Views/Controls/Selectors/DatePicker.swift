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
//  Created by Emil Pedersen on 2021-03-26.
//

import struct Foundation.Date

/// A control for selecting an absolute date.
///
/// Available when `Label` conform to `View`.
public struct DatePicker<Label>: _PrimitiveView where Label: View {
  let label: Label
  let valueBinding: Binding<Date>
  let displayedComponents: DatePickerComponents
  let min: Date?
  let max: Date?

  /// The set of date components a date picker can display and edit.
  public typealias Components = DatePickerComponents
}

public extension DatePicker {
  /// Creates a date picker for selecting a date within a closed range, with a custom label.
  ///
  /// - Parameters:
  ///   - selection: A binding to the selected date.
  ///   - range: The inclusive range of selectable dates.
  ///   - displayedComponents: The date components the picker displays and edits.
  ///   - label: A view builder that produces the picker's label.
  init(
    selection: Binding<Date>,
    in range: ClosedRange<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date],
    @ViewBuilder label: () -> Label
  ) {
    self.init(
      label: label(),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: range.lowerBound,
      max: range.upperBound
    )
  }

  /// Creates a date picker for selecting a date, with a custom label.
  ///
  /// - Parameters:
  ///   - selection: A binding to the selected date.
  ///   - displayedComponents: The date components the picker displays and edits.
  ///   - label: A view builder that produces the picker's label.
  init(
    selection: Binding<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date],
    @ViewBuilder label: () -> Label
  ) {
    self.init(
      label: label(),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: nil,
      max: nil
    )
  }

  /// Creates a date picker for selecting a date on or after a given date, with a custom label.
  ///
  /// - Parameters:
  ///   - selection: A binding to the selected date.
  ///   - range: The range of selectable dates, starting at its lower bound.
  ///   - displayedComponents: The date components the picker displays and edits.
  ///   - label: A view builder that produces the picker's label.
  init(
    selection: Binding<Date>,
    in range: PartialRangeFrom<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date],
    @ViewBuilder label: () -> Label
  ) {
    self.init(
      label: label(),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: range.lowerBound,
      max: nil
    )
  }

  /// Creates a date picker for selecting a date on or before a given date, with a custom label.
  ///
  /// - Parameters:
  ///   - selection: A binding to the selected date.
  ///   - range: The range of selectable dates, ending at its upper bound.
  ///   - displayedComponents: The date components the picker displays and edits.
  ///   - label: A view builder that produces the picker's label.
  init(
    selection: Binding<Date>,
    in range: PartialRangeThrough<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date],
    @ViewBuilder label: () -> Label
  ) {
    self.init(
      label: label(),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: nil,
      max: range.upperBound
    )
  }
}

public extension DatePicker where Label == Text {
  /// Creates a date picker for a closed date range that generates its label from a string.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the picker.
  ///   - selection: A binding to the selected date.
  ///   - range: The inclusive range of selectable dates.
  ///   - displayedComponents: The date components the picker displays and edits.
  init<S>(
    _ title: S,
    selection: Binding<Date>,
    in range: ClosedRange<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date]
  ) where S: StringProtocol {
    self.init(
      label: Text(title),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: range.lowerBound,
      max: range.upperBound
    )
  }

  /// Creates a date picker that generates its label from a string.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the picker.
  ///   - selection: A binding to the selected date.
  ///   - displayedComponents: The date components the picker displays and edits.
  init<S>(
    _ title: S,
    selection: Binding<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date]
  ) where S: StringProtocol {
    self.init(
      label: Text(title),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: nil,
      max: nil
    )
  }

  /// Creates a date picker for dates on or after a given date that generates its label from a
  /// string.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the picker.
  ///   - selection: A binding to the selected date.
  ///   - range: The range of selectable dates, starting at its lower bound.
  ///   - displayedComponents: The date components the picker displays and edits.
  init<S>(
    _ title: S,
    selection: Binding<Date>,
    in range: PartialRangeFrom<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date]
  ) where S: StringProtocol {
    self.init(
      label: Text(title),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: range.lowerBound,
      max: nil
    )
  }

  /// Creates a date picker for dates on or before a given date that generates its label from a
  /// string.
  ///
  /// - Parameters:
  ///   - title: A string that describes the purpose of the picker.
  ///   - selection: A binding to the selected date.
  ///   - range: The range of selectable dates, ending at its upper bound.
  ///   - displayedComponents: The date components the picker displays and edits.
  init<S>(
    _ title: S,
    selection: Binding<Date>,
    in range: PartialRangeThrough<Date>,
    displayedComponents: DatePickerComponents = [.hourAndMinute, .date]
  ) where S: StringProtocol {
    self.init(
      label: Text(title),
      valueBinding: selection,
      displayedComponents: displayedComponents,
      min: nil,
      max: range.upperBound
    )
  }
}

/// The set of date components a date picker can display and edit.
public struct DatePickerComponents: OptionSet, Sendable {
  /// Displays hour and minute components.
  public static let hourAndMinute = DatePickerComponents(rawValue: 1 << 0)
  /// Displays day, month, and year components.
  public static let date = DatePickerComponents(rawValue: 1 << 1)

  /// The raw bitmask value backing the option set.
  public let rawValue: UInt

  /// Creates a set of date picker components from a raw bitmask value.
  ///
  /// - Parameter rawValue: The raw bitmask value backing the option set.
  public init(rawValue: UInt) {
    self.rawValue = rawValue
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
///
/// An implementation detail of Tokamak's rendering; not intended for use in application code.
public struct _DatePickerProxy<Label> where Label: View {
  /// The date picker this proxy reads from.
  public let subject: DatePicker<Label>

  /// Creates a proxy that exposes the internals of the given date picker.
  ///
  /// - Parameter subject: The date picker to wrap.
  public init(_ subject: DatePicker<Label>) { self.subject = subject }

  /// The picker's label view.
  public var label: Label { subject.label }
  /// A binding to the selected date.
  public var valueBinding: Binding<Date> { subject.valueBinding }
  /// The date components the picker displays and edits.
  public var displayedComponents: DatePickerComponents { subject.displayedComponents }
  /// The earliest selectable date, if bounded.
  public var min: Date? { subject.min }
  /// The latest selectable date, if bounded.
  public var max: Date? { subject.max }
}

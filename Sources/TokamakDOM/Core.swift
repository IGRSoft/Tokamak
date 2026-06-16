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
//  Created by Jed Fox on 7/18/20.
//

#if canImport(JavaScriptKit)
import TokamakCore

// MARK: Environment & State

/// A SwiftUI-compatible `DynamicProperty` re-exported from TokamakCore.
public typealias DynamicProperty = TokamakCore.DynamicProperty

/// A SwiftUI-compatible `Environment` re-exported from TokamakCore.
public typealias Environment = TokamakCore.Environment
/// A SwiftUI-compatible `EnvironmentKey` re-exported from TokamakCore.
public typealias EnvironmentKey = TokamakCore.EnvironmentKey
/// A SwiftUI-compatible `EnvironmentObject` re-exported from TokamakCore.
public typealias EnvironmentObject = TokamakCore.EnvironmentObject
/// A SwiftUI-compatible `EnvironmentValues` re-exported from TokamakCore.
public typealias EnvironmentValues = TokamakCore.EnvironmentValues
/// A SwiftUI-compatible `EditMode` re-exported from TokamakCore.
public typealias EditMode = TokamakCore.EditMode

/// A SwiftUI-compatible `PreferenceKey` re-exported from TokamakCore.
public typealias PreferenceKey = TokamakCore.PreferenceKey

/// A SwiftUI-compatible `Binding` re-exported from TokamakCore.
public typealias Binding = TokamakCore.Binding
/// A SwiftUI-compatible `ObservableObject` re-exported from TokamakCore.
public typealias ObservableObject = TokamakCore.ObservableObject
/// A SwiftUI-compatible `ObservedObject` re-exported from TokamakCore.
public typealias ObservedObject = TokamakCore.ObservedObject
/// A SwiftUI-compatible `Published` re-exported from TokamakCore.
public typealias Published = TokamakCore.Published
/// A SwiftUI-compatible `State` re-exported from TokamakCore.
public typealias State = TokamakCore.State
/// A SwiftUI-compatible `StateObject` re-exported from TokamakCore.
public typealias StateObject = TokamakCore.StateObject

// MARK: Modifiers & Styles

/// A SwiftUI-compatible `ViewModifier` re-exported from TokamakCore.
public typealias ViewModifier = TokamakCore.ViewModifier
/// A SwiftUI-compatible `ModifiedContent` re-exported from TokamakCore.
public typealias ModifiedContent = TokamakCore.ModifiedContent

/// A SwiftUI-compatible `DefaultTextFieldStyle` re-exported from TokamakCore.
public typealias DefaultTextFieldStyle = TokamakCore.DefaultTextFieldStyle
/// A SwiftUI-compatible `PlainTextFieldStyle` re-exported from TokamakCore.
public typealias PlainTextFieldStyle = TokamakCore.PlainTextFieldStyle
/// A SwiftUI-compatible `RoundedBorderTextFieldStyle` re-exported from TokamakCore.
public typealias RoundedBorderTextFieldStyle = TokamakCore.RoundedBorderTextFieldStyle
/// A SwiftUI-compatible `SquareBorderTextFieldStyle` re-exported from TokamakCore.
public typealias SquareBorderTextFieldStyle = TokamakCore.SquareBorderTextFieldStyle

/// A SwiftUI-compatible `DefaultListStyle` re-exported from TokamakCore.
public typealias DefaultListStyle = TokamakCore.DefaultListStyle
/// A SwiftUI-compatible `PlainListStyle` re-exported from TokamakCore.
public typealias PlainListStyle = TokamakCore.PlainListStyle
/// A SwiftUI-compatible `InsetListStyle` re-exported from TokamakCore.
public typealias InsetListStyle = TokamakCore.InsetListStyle
/// A SwiftUI-compatible `GroupedListStyle` re-exported from TokamakCore.
public typealias GroupedListStyle = TokamakCore.GroupedListStyle
/// A SwiftUI-compatible `InsetGroupedListStyle` re-exported from TokamakCore.
public typealias InsetGroupedListStyle = TokamakCore.InsetGroupedListStyle
/// A SwiftUI-compatible `SidebarListStyle` re-exported from TokamakCore.
public typealias SidebarListStyle = TokamakCore.SidebarListStyle

/// A SwiftUI-compatible `DefaultPickerStyle` re-exported from TokamakCore.
public typealias DefaultPickerStyle = TokamakCore.DefaultPickerStyle
/// A SwiftUI-compatible `PopUpButtonPickerStyle` re-exported from TokamakCore.
public typealias PopUpButtonPickerStyle = TokamakCore.PopUpButtonPickerStyle
/// A SwiftUI-compatible `RadioGroupPickerStyle` re-exported from TokamakCore.
public typealias RadioGroupPickerStyle = TokamakCore.RadioGroupPickerStyle
/// A SwiftUI-compatible `SegmentedPickerStyle` re-exported from TokamakCore.
public typealias SegmentedPickerStyle = TokamakCore.SegmentedPickerStyle
/// A SwiftUI-compatible `WheelPickerStyle` re-exported from TokamakCore.
public typealias WheelPickerStyle = TokamakCore.WheelPickerStyle

/// A SwiftUI-compatible `ToggleStyle` re-exported from TokamakCore.
public typealias ToggleStyle = TokamakCore.ToggleStyle
/// A SwiftUI-compatible `ToggleStyleConfiguration` re-exported from TokamakCore.
public typealias ToggleStyleConfiguration = TokamakCore.ToggleStyleConfiguration

/// A SwiftUI-compatible `ButtonStyle` re-exported from TokamakCore.
public typealias ButtonStyle = TokamakCore.ButtonStyle
/// A SwiftUI-compatible `ButtonStyleConfiguration` re-exported from TokamakCore.
public typealias ButtonStyleConfiguration = TokamakCore.ButtonStyleConfiguration
/// A SwiftUI-compatible `DefaultButtonStyle` re-exported from TokamakCore.
public typealias DefaultButtonStyle = TokamakCore.DefaultButtonStyle
/// A SwiftUI-compatible `PlainButtonStyle` re-exported from TokamakCore.
public typealias PlainButtonStyle = TokamakCore.PlainButtonStyle
/// A SwiftUI-compatible `BorderedButtonStyle` re-exported from TokamakCore.
public typealias BorderedButtonStyle = TokamakCore.BorderedButtonStyle
/// A SwiftUI-compatible `BorderedProminentButtonStyle` re-exported from TokamakCore.
public typealias BorderedProminentButtonStyle = TokamakCore.BorderedProminentButtonStyle
/// A SwiftUI-compatible `BorderlessButtonStyle` re-exported from TokamakCore.
public typealias BorderlessButtonStyle = TokamakCore.BorderlessButtonStyle
/// A SwiftUI-compatible `LinkButtonStyle` re-exported from TokamakCore.
public typealias LinkButtonStyle = TokamakCore.LinkButtonStyle

/// A SwiftUI-compatible `ControlGroupStyle` re-exported from TokamakCore.
public typealias ControlGroupStyle = TokamakCore.ControlGroupStyle
/// A SwiftUI-compatible `AutomaticControlGroupStyle` re-exported from TokamakCore.
public typealias AutomaticControlGroupStyle = TokamakCore.AutomaticControlGroupStyle
/// A SwiftUI-compatible `NavigationControlGroupStyle` re-exported from TokamakCore.
public typealias NavigationControlGroupStyle = TokamakCore.NavigationControlGroupStyle

/// A SwiftUI-compatible `LabelStyle` re-exported from TokamakCore.
public typealias LabelStyle = TokamakCore.LabelStyle
/// A SwiftUI-compatible `LabelStyleConfiguration` re-exported from TokamakCore.
public typealias LabelStyleConfiguration = TokamakCore.LabelStyleConfiguration
/// A SwiftUI-compatible `DefaultLabelStyle` re-exported from TokamakCore.
public typealias DefaultLabelStyle = TokamakCore.DefaultLabelStyle
/// A SwiftUI-compatible `TitleAndIconLabelStyle` re-exported from TokamakCore.
public typealias TitleAndIconLabelStyle = TokamakCore.TitleAndIconLabelStyle
/// A SwiftUI-compatible `TitleOnlyLabelStyle` re-exported from TokamakCore.
public typealias TitleOnlyLabelStyle = TokamakCore.TitleOnlyLabelStyle
/// A SwiftUI-compatible `IconOnlyLabelStyle` re-exported from TokamakCore.
public typealias IconOnlyLabelStyle = TokamakCore.IconOnlyLabelStyle

/// A SwiftUI-compatible `GroupBoxStyle` re-exported from TokamakCore.
public typealias GroupBoxStyle = TokamakCore.GroupBoxStyle
/// A SwiftUI-compatible `GroupBoxStyleConfiguration` re-exported from TokamakCore.
public typealias GroupBoxStyleConfiguration = TokamakCore.GroupBoxStyleConfiguration
/// A SwiftUI-compatible `DefaultGroupBoxStyle` re-exported from TokamakCore.
public typealias DefaultGroupBoxStyle = TokamakCore.DefaultGroupBoxStyle
/// A SwiftUI-compatible `AutomaticGroupBoxStyle` re-exported from TokamakCore.
public typealias AutomaticGroupBoxStyle = TokamakCore.AutomaticGroupBoxStyle

/// A SwiftUI-compatible `GaugeStyle` re-exported from TokamakCore.
public typealias GaugeStyle = TokamakCore.GaugeStyle
/// A SwiftUI-compatible `GaugeStyleConfiguration` re-exported from TokamakCore.
public typealias GaugeStyleConfiguration = TokamakCore.GaugeStyleConfiguration
/// A SwiftUI-compatible `DefaultGaugeStyle` re-exported from TokamakCore.
public typealias DefaultGaugeStyle = TokamakCore.DefaultGaugeStyle
/// A SwiftUI-compatible `LinearGaugeStyle` re-exported from TokamakCore.
public typealias LinearGaugeStyle = TokamakCore.LinearGaugeStyle
/// A SwiftUI-compatible `AccessoryLinearGaugeStyle` re-exported from TokamakCore.
public typealias AccessoryLinearGaugeStyle = TokamakCore.AccessoryLinearGaugeStyle
/// A SwiftUI-compatible `AccessoryCircularGaugeStyle` re-exported from TokamakCore.
public typealias AccessoryCircularGaugeStyle = TokamakCore.AccessoryCircularGaugeStyle

/// A SwiftUI-compatible `TextFieldStyle` re-exported from TokamakCore.
public typealias TextFieldStyle = TokamakCore.TextFieldStyle

/// A SwiftUI-compatible `FillStyle` re-exported from TokamakCore.
public typealias FillStyle = TokamakCore.FillStyle
/// A SwiftUI-compatible `ShapeStyle` re-exported from TokamakCore.
public typealias ShapeStyle = TokamakCore.ShapeStyle
/// A SwiftUI-compatible `StrokeStyle` re-exported from TokamakCore.
public typealias StrokeStyle = TokamakCore.StrokeStyle

/// A SwiftUI-compatible `ColorScheme` re-exported from TokamakCore.
public typealias ColorScheme = TokamakCore.ColorScheme

// MARK: Shapes

/// A SwiftUI-compatible `Shape` re-exported from TokamakCore.
public typealias Shape = TokamakCore.Shape

/// A SwiftUI-compatible `Capsule` re-exported from TokamakCore.
public typealias Capsule = TokamakCore.Capsule
/// A SwiftUI-compatible `Circle` re-exported from TokamakCore.
public typealias Circle = TokamakCore.Circle
/// A SwiftUI-compatible `Ellipse` re-exported from TokamakCore.
public typealias Ellipse = TokamakCore.Ellipse
/// A SwiftUI-compatible `Path` re-exported from TokamakCore.
public typealias Path = TokamakCore.Path
/// A SwiftUI-compatible `Rectangle` re-exported from TokamakCore.
public typealias Rectangle = TokamakCore.Rectangle
/// A SwiftUI-compatible `RoundedRectangle` re-exported from TokamakCore.
public typealias RoundedRectangle = TokamakCore.RoundedRectangle
/// A SwiftUI-compatible `ContainerRelativeShape` re-exported from TokamakCore.
public typealias ContainerRelativeShape = TokamakCore.ContainerRelativeShape

// MARK: Shape Styles

/// A SwiftUI-compatible `HierarchicalShapeStyle` re-exported from TokamakCore.
public typealias HierarchicalShapeStyle = TokamakCore.HierarchicalShapeStyle

/// A SwiftUI-compatible `ForegroundStyle` re-exported from TokamakCore.
public typealias ForegroundStyle = TokamakCore.ForegroundStyle
/// A SwiftUI-compatible `BackgroundStyle` re-exported from TokamakCore.
public typealias BackgroundStyle = TokamakCore.BackgroundStyle

/// A SwiftUI-compatible `Material` re-exported from TokamakCore.
public typealias Material = TokamakCore.Material

/// A SwiftUI-compatible `Gradient` re-exported from TokamakCore.
public typealias Gradient = TokamakCore.Gradient
/// A SwiftUI-compatible `LinearGradient` re-exported from TokamakCore.
public typealias LinearGradient = TokamakCore.LinearGradient
/// A SwiftUI-compatible `RadialGradient` re-exported from TokamakCore.
public typealias RadialGradient = TokamakCore.RadialGradient
/// A SwiftUI-compatible `EllipticalGradient` re-exported from TokamakCore.
public typealias EllipticalGradient = TokamakCore.EllipticalGradient
/// A SwiftUI-compatible `AngularGradient` re-exported from TokamakCore.
public typealias AngularGradient = TokamakCore.AngularGradient

// MARK: Primitive values

/// A SwiftUI-compatible `Color` re-exported from TokamakCore.
public typealias Color = TokamakCore.Color
/// A SwiftUI-compatible `Font` re-exported from TokamakCore.
public typealias Font = TokamakCore.Font

#if !canImport(CoreGraphics)
/// A SwiftUI-compatible `CGAffineTransform` re-exported from TokamakCore.
public typealias CGAffineTransform = TokamakCore.CGAffineTransform
#endif

/// A SwiftUI-compatible `Angle` re-exported from TokamakCore.
public typealias Angle = TokamakCore.Angle
/// A SwiftUI-compatible `Axis` re-exported from TokamakCore.
public typealias Axis = TokamakCore.Axis
/// A SwiftUI-compatible `UnitPoint` re-exported from TokamakCore.
public typealias UnitPoint = TokamakCore.UnitPoint

/// A SwiftUI-compatible `Edge` re-exported from TokamakCore.
public typealias Edge = TokamakCore.Edge

/// A SwiftUI-compatible `Prominence` re-exported from TokamakCore.
public typealias Prominence = TokamakCore.Prominence

/// A SwiftUI-compatible `GraphicsContext` re-exported from TokamakCore.
public typealias GraphicsContext = TokamakCore.GraphicsContext

/// A SwiftUI-compatible `TimelineSchedule` re-exported from TokamakCore.
public typealias TimelineSchedule = TokamakCore.TimelineSchedule
/// A SwiftUI-compatible `TimelineScheduleMode` re-exported from TokamakCore.
public typealias TimelineScheduleMode = TokamakCore.TimelineScheduleMode
/// A SwiftUI-compatible `AnimationTimelineSchedule` re-exported from TokamakCore.
public typealias AnimationTimelineSchedule = TokamakCore.AnimationTimelineSchedule
/// A SwiftUI-compatible `EveryMinuteTimelineSchedule` re-exported from TokamakCore.
public typealias EveryMinuteTimelineSchedule = TokamakCore.EveryMinuteTimelineSchedule
/// A SwiftUI-compatible `ExplicitTimelineSchedule` re-exported from TokamakCore.
public typealias ExplicitTimelineSchedule = TokamakCore.ExplicitTimelineSchedule
/// A SwiftUI-compatible `PeriodicTimelineSchedule` re-exported from TokamakCore.
public typealias PeriodicTimelineSchedule = TokamakCore.PeriodicTimelineSchedule

/// A SwiftUI-compatible `HorizontalAlignment` re-exported from TokamakCore.
public typealias HorizontalAlignment = TokamakCore.HorizontalAlignment
/// A SwiftUI-compatible `VerticalAlignment` re-exported from TokamakCore.
public typealias VerticalAlignment = TokamakCore.VerticalAlignment

// MARK: Views

/// A SwiftUI-compatible `Alignment` re-exported from TokamakCore.
public typealias Alignment = TokamakCore.Alignment
/// A SwiftUI-compatible `Button` re-exported from TokamakCore.
public typealias Button = TokamakCore.Button
/// A SwiftUI-compatible `Canvas` re-exported from TokamakCore.
public typealias Canvas = TokamakCore.Canvas
/// A SwiftUI-compatible `ControlGroup` re-exported from TokamakCore.
public typealias ControlGroup = TokamakCore.ControlGroup
/// A SwiftUI-compatible `ControlSize` re-exported from TokamakCore.
public typealias ControlSize = TokamakCore.ControlSize
/// A SwiftUI-compatible `ColorPicker` re-exported from TokamakCore.
public typealias ColorPicker = TokamakCore.ColorPicker
/// A SwiftUI-compatible `DatePicker` re-exported from TokamakCore.
public typealias DatePicker = TokamakCore.DatePicker
/// A SwiftUI-compatible `DisclosureGroup` re-exported from TokamakCore.
public typealias DisclosureGroup = TokamakCore.DisclosureGroup
/// A SwiftUI-compatible `Divider` re-exported from TokamakCore.
public typealias Divider = TokamakCore.Divider
/// A SwiftUI-compatible `EditButton` re-exported from TokamakCore.
public typealias EditButton = TokamakCore.EditButton
/// A SwiftUI-compatible `EquatableView` re-exported from TokamakCore.
public typealias EquatableView = TokamakCore.EquatableView
/// A SwiftUI-compatible `ForEach` re-exported from TokamakCore.
public typealias ForEach = TokamakCore.ForEach
/// A SwiftUI-compatible `Form` re-exported from TokamakCore.
public typealias Form = TokamakCore.Form
/// A SwiftUI-compatible `Gauge` re-exported from TokamakCore.
public typealias Gauge = TokamakCore.Gauge
/// A SwiftUI-compatible `GeometryReader` re-exported from TokamakCore.
public typealias GeometryReader = TokamakCore.GeometryReader
/// A SwiftUI-compatible `GridItem` re-exported from TokamakCore.
public typealias GridItem = TokamakCore.GridItem
/// A SwiftUI-compatible `Group` re-exported from TokamakCore.
public typealias Group = TokamakCore.Group
/// A SwiftUI-compatible `GroupBox` re-exported from TokamakCore.
public typealias GroupBox = TokamakCore.GroupBox
/// A SwiftUI-compatible `HSplitView` re-exported from TokamakCore.
public typealias HSplitView = TokamakCore.HSplitView
/// A SwiftUI-compatible `HStack` re-exported from TokamakCore.
public typealias HStack = TokamakCore.HStack
/// A SwiftUI-compatible `Image` re-exported from TokamakCore.
public typealias Image = TokamakCore.Image
/// A SwiftUI-compatible `Label` re-exported from TokamakCore.
public typealias Label = TokamakCore.Label
/// A SwiftUI-compatible `LazyHGrid` re-exported from TokamakCore.
public typealias LazyHGrid = TokamakCore.LazyHGrid
/// A SwiftUI-compatible `LazyHStack` re-exported from TokamakCore.
public typealias LazyHStack = TokamakCore.LazyHStack
/// A SwiftUI-compatible `LazyVGrid` re-exported from TokamakCore.
public typealias LazyVGrid = TokamakCore.LazyVGrid
/// A SwiftUI-compatible `LazyVStack` re-exported from TokamakCore.
public typealias LazyVStack = TokamakCore.LazyVStack
/// A SwiftUI-compatible `Link` re-exported from TokamakCore.
public typealias Link = TokamakCore.Link
/// A SwiftUI-compatible `List` re-exported from TokamakCore.
public typealias List = TokamakCore.List
/// A SwiftUI-compatible `Menu` re-exported from TokamakCore.
public typealias Menu = TokamakCore.Menu
/// A SwiftUI-compatible `NavigationLink` re-exported from TokamakCore.
public typealias NavigationLink = TokamakCore.NavigationLink
/// A SwiftUI-compatible `NavigationView` re-exported from TokamakCore.
public typealias NavigationView = TokamakCore.NavigationView
/// A SwiftUI-compatible `OutlineGroup` re-exported from TokamakCore.
public typealias OutlineGroup = TokamakCore.OutlineGroup
/// A SwiftUI-compatible `PasteButton` re-exported from TokamakCore.
public typealias PasteButton = TokamakCore.PasteButton
/// A SwiftUI-compatible `Picker` re-exported from TokamakCore.
public typealias Picker = TokamakCore.Picker
/// A SwiftUI-compatible `ProgressView` re-exported from TokamakCore.
public typealias ProgressView = TokamakCore.ProgressView
/// A SwiftUI-compatible `ScrollView` re-exported from TokamakCore.
public typealias ScrollView = TokamakCore.ScrollView
/// A SwiftUI-compatible `ScrollViewReader` re-exported from TokamakCore.
public typealias ScrollViewReader = TokamakCore.ScrollViewReader
/// A SwiftUI-compatible `Section` re-exported from TokamakCore.
public typealias Section = TokamakCore.Section
/// A SwiftUI-compatible `SecureField` re-exported from TokamakCore.
public typealias SecureField = TokamakCore.SecureField
/// A SwiftUI-compatible `SignInWithAppleButton` re-exported from TokamakCore.
public typealias SignInWithAppleButton = TokamakCore.SignInWithAppleButton
/// A SwiftUI-compatible `Slider` re-exported from TokamakCore.
public typealias Slider = TokamakCore.Slider
/// A SwiftUI-compatible `Spacer` re-exported from TokamakCore.
public typealias Spacer = TokamakCore.Spacer
/// A SwiftUI-compatible `Stepper` re-exported from TokamakCore.
public typealias Stepper = TokamakCore.Stepper
/// A SwiftUI-compatible `TabView` re-exported from TokamakCore.
public typealias TabView = TokamakCore.TabView
/// A SwiftUI-compatible `Text` re-exported from TokamakCore.
public typealias Text = TokamakCore.Text
/// A SwiftUI-compatible `TextEditor` re-exported from TokamakCore.
public typealias TextEditor = TokamakCore.TextEditor
/// A SwiftUI-compatible `TextField` re-exported from TokamakCore.
public typealias TextField = TokamakCore.TextField
/// A SwiftUI-compatible `TimelineView` re-exported from TokamakCore.
public typealias TimelineView = TokamakCore.TimelineView
/// A SwiftUI-compatible `Toggle` re-exported from TokamakCore.
public typealias Toggle = TokamakCore.Toggle
/// A SwiftUI-compatible `VSplitView` re-exported from TokamakCore.
public typealias VSplitView = TokamakCore.VSplitView
/// A SwiftUI-compatible `VStack` re-exported from TokamakCore.
public typealias VStack = TokamakCore.VStack
/// A SwiftUI-compatible `ZStack` re-exported from TokamakCore.
public typealias ZStack = TokamakCore.ZStack

/// A SwiftUI-compatible `Grid` re-exported from TokamakCore.
public typealias Grid = TokamakCore.Grid
/// A SwiftUI-compatible `GridRow` re-exported from TokamakCore.
public typealias GridRow = TokamakCore.GridRow

// MARK: Gestures

/// A SwiftUI-compatible `Gesture` re-exported from TokamakCore.
public typealias Gesture = TokamakCore.Gesture
/// A SwiftUI-compatible `GestureMask` re-exported from TokamakCore.
public typealias GestureMask = TokamakCore.GestureMask
/// A SwiftUI-compatible `GestureState` re-exported from TokamakCore.
public typealias GestureState = TokamakCore.GestureState
/// A SwiftUI-compatible `TapGesture` re-exported from TokamakCore.
public typealias TapGesture = TokamakCore.TapGesture
/// A SwiftUI-compatible `DragGesture` re-exported from TokamakCore.
public typealias DragGesture = TokamakCore.DragGesture
/// A SwiftUI-compatible `LongPressGesture` re-exported from TokamakCore.
public typealias LongPressGesture = TokamakCore.LongPressGesture
/// A SwiftUI-compatible `CoordinateSpace` re-exported from TokamakCore.
public typealias CoordinateSpace = TokamakCore.CoordinateSpace

// MARK: Special Views

/// A SwiftUI-compatible `View` re-exported from TokamakCore.
public typealias View = TokamakCore.View
/// A SwiftUI-compatible `AnyView` re-exported from TokamakCore.
public typealias AnyView = TokamakCore.AnyView
/// A SwiftUI-compatible `EmptyView` re-exported from TokamakCore.
public typealias EmptyView = TokamakCore.EmptyView

// MARK: Layout

/// A SwiftUI-compatible `Layout` re-exported from TokamakCore.
public typealias Layout = TokamakCore.Layout
/// A SwiftUI-compatible `AnyLayout` re-exported from TokamakCore.
public typealias AnyLayout = TokamakCore.AnyLayout
/// A SwiftUI-compatible `LayoutProperties` re-exported from TokamakCore.
public typealias LayoutProperties = TokamakCore.LayoutProperties
/// A SwiftUI-compatible `LayoutSubviews` re-exported from TokamakCore.
public typealias LayoutSubviews = TokamakCore.LayoutSubviews
/// A SwiftUI-compatible `LayoutSubview` re-exported from TokamakCore.
public typealias LayoutSubview = TokamakCore.LayoutSubview
/// A SwiftUI-compatible `LayoutValueKey` re-exported from TokamakCore.
public typealias LayoutValueKey = TokamakCore.LayoutValueKey
/// A SwiftUI-compatible `ProposedViewSize` re-exported from TokamakCore.
public typealias ProposedViewSize = TokamakCore.ProposedViewSize
/// A SwiftUI-compatible `ViewSpacing` re-exported from TokamakCore.
public typealias ViewSpacing = TokamakCore.ViewSpacing

// MARK: Toolbars

/// A SwiftUI-compatible `ToolbarItem` re-exported from TokamakCore.
public typealias ToolbarItem = TokamakCore.ToolbarItem
/// A SwiftUI-compatible `ToolbarItemGroup` re-exported from TokamakCore.
public typealias ToolbarItemGroup = TokamakCore.ToolbarItemGroup
/// A SwiftUI-compatible `ToolbarItemPlacement` re-exported from TokamakCore.
public typealias ToolbarItemPlacement = TokamakCore.ToolbarItemPlacement
/// A SwiftUI-compatible `ToolbarContentBuilder` re-exported from TokamakCore.
public typealias ToolbarContentBuilder = TokamakCore.ToolbarContentBuilder

// MARK: Text

/// A SwiftUI-compatible `TextAlignment` re-exported from TokamakCore.
public typealias TextAlignment = TokamakCore.TextAlignment

// MARK: App & Scene

/// A SwiftUI-compatible `App` re-exported from TokamakCore.
public typealias App = TokamakCore.App
/// An implementation detail re-exported from TokamakCore so other modules can reach it.
public typealias _AppConfiguration = TokamakCore._AppConfiguration
/// A SwiftUI-compatible `Scene` re-exported from TokamakCore.
public typealias Scene = TokamakCore.Scene
/// A SwiftUI-compatible `WindowGroup` re-exported from TokamakCore.
public typealias WindowGroup = TokamakCore.WindowGroup
/// A SwiftUI-compatible `ScenePhase` re-exported from TokamakCore.
public typealias ScenePhase = TokamakCore.ScenePhase
/// A SwiftUI-compatible `AppStorage` re-exported from TokamakCore.
public typealias AppStorage = TokamakCore.AppStorage
/// A SwiftUI-compatible `SceneStorage` re-exported from TokamakCore.
public typealias SceneStorage = TokamakCore.SceneStorage

// MARK: Misc

/// A SwiftUI-compatible `ViewBuilder` re-exported from TokamakCore.
public typealias ViewBuilder = TokamakCore.ViewBuilder

// MARK: Animation

/// A SwiftUI-compatible `Animation` re-exported from TokamakCore.
public typealias Animation = TokamakCore.Animation
/// A SwiftUI-compatible `Transaction` re-exported from TokamakCore.
public typealias Transaction = TokamakCore.Transaction

/// A SwiftUI-compatible `Animatable` re-exported from TokamakCore.
public typealias Animatable = TokamakCore.Animatable
/// A SwiftUI-compatible `AnimatablePair` re-exported from TokamakCore.
public typealias AnimatablePair = TokamakCore.AnimatablePair
/// A SwiftUI-compatible `EmptyAnimatableData` re-exported from TokamakCore.
public typealias EmptyAnimatableData = TokamakCore.EmptyAnimatableData

/// A SwiftUI-compatible `AnimatableModifier` re-exported from TokamakCore.
public typealias AnimatableModifier = TokamakCore.AnimatableModifier

/// A SwiftUI-compatible `AnyTransition` re-exported from TokamakCore.
public typealias AnyTransition = TokamakCore.AnyTransition

/// Runs `body` with the given `transaction` applied to the current animation context.
/// - Parameters:
///   - transaction: The transaction whose animation settings apply to changes in `body`.
///   - body: The closure to execute under the supplied transaction.
/// - Returns: The value returned by `body`.
public func withTransaction<Result>(
  _ transaction: Transaction,
  _ body: () throws -> Result
) rethrows -> Result {
  try TokamakCore.withTransaction(transaction, body)
}

/// Runs `body` and animates any state changes it makes with the given animation.
/// - Parameters:
///   - animation: The animation to apply to changes made in `body`, or `nil` to disable them.
///   - body: The closure whose state changes should be animated.
/// - Returns: The value returned by `body`.
public func withAnimation<Result>(
  _ animation: Animation? = .default,
  _ body: () throws -> Result
) rethrows -> Result {
  try TokamakCore.withAnimation(animation, body)
}

// FIXME: I would put this inside TokamakCore, but for
// some reason it doesn't get exported with the typealias
public extension Text {
  /// Concatenates two `Text` values into a single run, preserving their styling.
  static func + (lhs: Self, rhs: Self) -> Self {
    _concatenating(lhs: lhs, rhs: rhs)
  }
}

/// A SwiftUI-compatible `PreviewProvider` re-exported from TokamakCore.
public typealias PreviewProvider = TokamakCore.PreviewProvider

#endif

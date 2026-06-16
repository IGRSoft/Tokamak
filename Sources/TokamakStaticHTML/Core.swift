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

import TokamakCore

// MARK: Environment & State

/// A SwiftUI-compatible `Environment` re-exported from TokamakCore.
public typealias Environment = TokamakCore.Environment

// MARK: Modifiers & Styles

/// A SwiftUI-compatible `ViewModifier` re-exported from TokamakCore.
public typealias ViewModifier = TokamakCore.ViewModifier
/// A SwiftUI-compatible `ModifiedContent` re-exported from TokamakCore.
public typealias ModifiedContent = TokamakCore.ModifiedContent

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

/// A SwiftUI-compatible `Axis` re-exported from TokamakCore.
public typealias Axis = TokamakCore.Axis

/// A SwiftUI-compatible `Color` re-exported from TokamakCore.
public typealias Color = TokamakCore.Color
/// A SwiftUI-compatible `Font` re-exported from TokamakCore.
public typealias Font = TokamakCore.Font

/// A SwiftUI-compatible `Alignment` re-exported from TokamakCore.
public typealias Alignment = TokamakCore.Alignment
/// A SwiftUI-compatible `AlignmentID` re-exported from TokamakCore.
public typealias AlignmentID = TokamakCore.AlignmentID
/// A SwiftUI-compatible `HorizontalAlignment` re-exported from TokamakCore.
public typealias HorizontalAlignment = TokamakCore.HorizontalAlignment
/// A SwiftUI-compatible `VerticalAlignment` re-exported from TokamakCore.
public typealias VerticalAlignment = TokamakCore.VerticalAlignment

#if !canImport(CoreGraphics)
/// A SwiftUI-compatible `CGAffineTransform` re-exported from TokamakCore.
public typealias CGAffineTransform = TokamakCore.CGAffineTransform
#endif

// MARK: Views

/// A SwiftUI-compatible `Divider` re-exported from TokamakCore.
public typealias Divider = TokamakCore.Divider
/// A SwiftUI-compatible `EquatableView` re-exported from TokamakCore.
public typealias EquatableView = TokamakCore.EquatableView
/// A SwiftUI-compatible `ForEach` re-exported from TokamakCore.
public typealias ForEach = TokamakCore.ForEach
/// A SwiftUI-compatible `Form` re-exported from TokamakCore.
public typealias Form = TokamakCore.Form
/// A SwiftUI-compatible `Gauge` re-exported from TokamakCore.
public typealias Gauge = TokamakCore.Gauge
/// A SwiftUI-compatible `GridItem` re-exported from TokamakCore.
public typealias GridItem = TokamakCore.GridItem
/// A SwiftUI-compatible `Group` re-exported from TokamakCore.
public typealias Group = TokamakCore.Group
/// A SwiftUI-compatible `GroupBox` re-exported from TokamakCore.
public typealias GroupBox = TokamakCore.GroupBox
/// A SwiftUI-compatible `HStack` re-exported from TokamakCore.
public typealias HStack = TokamakCore.HStack
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
/// A SwiftUI-compatible `List` re-exported from TokamakCore.
public typealias List = TokamakCore.List
/// A SwiftUI-compatible `ProgressView` re-exported from TokamakCore.
public typealias ProgressView = TokamakCore.ProgressView
/// A SwiftUI-compatible `ScrollView` re-exported from TokamakCore.
public typealias ScrollView = TokamakCore.ScrollView
/// A SwiftUI-compatible `Section` re-exported from TokamakCore.
public typealias Section = TokamakCore.Section
/// A SwiftUI-compatible `Spacer` re-exported from TokamakCore.
public typealias Spacer = TokamakCore.Spacer
/// A SwiftUI-compatible `Text` re-exported from TokamakCore.
public typealias Text = TokamakCore.Text
/// A SwiftUI-compatible `VStack` re-exported from TokamakCore.
public typealias VStack = TokamakCore.VStack
/// A SwiftUI-compatible `ZStack` re-exported from TokamakCore.
public typealias ZStack = TokamakCore.ZStack
/// A SwiftUI-compatible `Link` re-exported from TokamakCore.
public typealias Link = TokamakCore.Link

/// A SwiftUI-compatible `Grid` re-exported from TokamakCore.
public typealias Grid = TokamakCore.Grid
/// A SwiftUI-compatible `GridRow` re-exported from TokamakCore.
public typealias GridRow = TokamakCore.GridRow

// MARK: Special Views

/// A SwiftUI-compatible `View` re-exported from TokamakCore.
public typealias View = TokamakCore.View
/// A SwiftUI-compatible `AnyView` re-exported from TokamakCore.
public typealias AnyView = TokamakCore.AnyView
/// A SwiftUI-compatible `EmptyView` re-exported from TokamakCore.
public typealias EmptyView = TokamakCore.EmptyView

/// A SwiftUI-compatible `Layout` re-exported from TokamakCore.
public typealias Layout = TokamakCore.Layout
/// A SwiftUI-compatible `AnyLayout` re-exported from TokamakCore.
public typealias AnyLayout = TokamakCore.AnyLayout

// MARK: Toolbars

/// A SwiftUI-compatible `ToolbarItem` re-exported from TokamakCore.
public typealias ToolbarItem = TokamakCore.ToolbarItem
/// A SwiftUI-compatible `ToolbarItemGroup` re-exported from TokamakCore.
public typealias ToolbarItemGroup = TokamakCore.ToolbarItemGroup
/// A SwiftUI-compatible `ToolbarItemPlacement` re-exported from TokamakCore.
public typealias ToolbarItemPlacement = TokamakCore.ToolbarItemPlacement
/// A SwiftUI-compatible `ToolbarContentBuilder` re-exported from TokamakCore.
public typealias ToolbarContentBuilder = TokamakCore.ToolbarContentBuilder

// MARK: App & Scene

/// A SwiftUI-compatible `App` re-exported from TokamakCore.
public typealias App = TokamakCore.App
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

// FIXME: I would put this inside TokamakCore, but for
// some reason it doesn't get exported with the typealias
public extension Text {
  /// Concatenates two `Text` values into a single run, mirroring SwiftUI's `Text` `+`.
  static func + (lhs: Self, rhs: Self) -> Self {
    _concatenating(lhs: lhs, rhs: rhs)
  }
}

/// A SwiftUI-compatible `PreviewProvider` re-exported from TokamakCore.
public typealias PreviewProvider = TokamakCore.PreviewProvider

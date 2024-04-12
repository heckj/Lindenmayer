//
//  Angle.swift
//
//
//  Created by Joseph Heck on 1/22/22.
//

import Foundation
#if canImport(SwiftUI)
    @_exported import SwiftUI

    /// A geometric angle whose value you access in either radians or degrees.
    public typealias Angle = SwiftUI.Angle
#else
    /// A geometric angle whose value you access in either radians or degrees.
    public typealias Angle = SimpleAngle
#endif

/// A geometric angle whose value you access in either radians or degrees.
///
/// ## Topics
///
/// ### Creating an Angle
///
/// - ``degrees(_:)``
/// - ``radians(_:)``
/// - ``init(degrees:)``
/// - ``init(radians:)``
/// - ``init()``
///
/// ### Inspecting the value of an Angle
///
/// - ``degrees``
/// - ``radians``
///
@frozen public struct SimpleAngle {
    /// The value of the angle in radians.
    public var radians: Double

    /// The value of the angle in degrees.
    @inlinable public var degrees: Double {
        radians * 180.0 / .pi
    }

    /// Creates a new Angle of zero radians.
    @inlinable public init() {
        radians = 0
    }

    /// Creates a new Angle with the value of radians you provide.
    @inlinable public init(radians: Double) {
        self.radians = radians
    }

    /// Creates a new Angle with the value of degrees you provide.
    @inlinable public init(degrees: Double) {
        radians = degrees * .pi / 180
    }

    /// Creates a new Angle with the value of radians you provide.
    @inlinable public static func radians(_ radians: Double) -> Angle {
        Angle(radians: radians)
    }

    /// Creates a new Angle with the value of degrees you provide.
    @inlinable public static func degrees(_ degrees: Double) -> Angle {
        Angle(degrees: degrees)
    }
}

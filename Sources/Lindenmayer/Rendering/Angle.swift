//
//  Angel.swift
//
//
//  Created by Joseph Heck on 1/22/22.
//

import Foundation

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
        return radians * 180.0 / .pi
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
    @inlinable public static func radians(_ radians: Double) -> SimpleAngle {
        return SimpleAngle(radians: radians)
    }
    
    /// Creates a new Angle with the value of degrees you provide.
    @inlinable public static func degrees(_ degrees: Double) -> SimpleAngle {
        return SimpleAngle(degrees: degrees)
    }
    
    @inlinable public static func + (left: SimpleAngle, right: SimpleAngle) -> SimpleAngle {
        return SimpleAngle(radians: left.radians+right.radians)
    }
    
    @inlinable public static func - (left: SimpleAngle, right: SimpleAngle) -> SimpleAngle {
        return SimpleAngle(radians: left.radians-right.radians)
    }
}

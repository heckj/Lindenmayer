//
//  Transforms.swift
//  
//  Created by Joseph Heck on 12/21/21.
//

import Foundation
import simd

/// Creates a 3D translation transform that scales by the values you provide.
/// - Parameters:
///   - x: The amount to translate along the X axis.
///   - y: The amount to translate along the Y axis.
///   - z: The amount to translate along the Z axis.
/// - Returns: A translation transform.
public func translationTransform(x: Float, y: Float, z: Float) -> simd_float4x4 {
    return simd_float4x4(
        SIMD4<Float>(1, 0, 0, 0),
        SIMD4<Float>(0, 1, 0, 0),
        SIMD4<Float>(0, 0, 1, 0),
        SIMD4<Float>(x, y, z, 1)
    )
}

/// Creates a 3D scaling transform that scales by the values you provide.
/// - Parameters:
///   - x: The amount to scale along the X axis.
///   - y: The amount to scale along the Y axis.
///   - z: The amount to scale along the Z axis.
/// - Returns: A scaling transform.
public func scalingTransform(x: Float, y: Float, z: Float) -> simd_float4x4 {
    return simd_float4x4(
        SIMD4<Float>(x, 0, 0, 0),
        SIMD4<Float>(0, y, 0, 0),
        SIMD4<Float>(0, 0, z, 0),
        SIMD4<Float>(0, 0, 0, 1)
    )
}

/// Creates a 3D rotation transform that rotates around the Z axis by the angle that you provide
/// - Parameter angle: The amount (in radians) to rotate around the Z axis.
/// - Returns: A Z-axis rotation transform.
public func rotationAroundZAxisTransform(angle: Float) -> simd_float4x4 {
    return simd_float4x4(
        SIMD4<Float>( cos(angle), sin(angle), 0, 0),
        SIMD4<Float>(-sin(angle), cos(angle), 0, 0),
        SIMD4<Float>(          0,          0, 1, 0),
        SIMD4<Float>(          0,          0, 0, 1)
    )
}

/// Creates a 3D rotation transform that rotates around the X axis by the angle that you provide
/// - Parameter angle: The amount (in radians) to rotate around the X axis.
/// - Returns: A X-axis rotation transform.
public func rotationAroundXAxisTransform(angle: Float) -> simd_float4x4 {
    return simd_float4x4(
        SIMD4<Float>(1,           0,          0, 0),
        SIMD4<Float>(0,  cos(angle), sin(angle), 0),
        SIMD4<Float>(0, -sin(angle), cos(angle), 0),
        SIMD4<Float>(0,           0,          0, 1)
    )
}

/// Creates a 3D rotation transform that rotates around the Y axis by the angle that you provide
/// - Parameter angle: The amount (in radians) to rotate around the Y axis.
/// - Returns: A Y-axis rotation transform.
public func rotationAroundYAxisTransform(angle: Float) -> simd_float4x4 {
    return simd_float4x4(
        SIMD4<Float>( cos(angle), 0, -sin(angle), 0),
        SIMD4<Float>(          0, 1,           0, 0),
        SIMD4<Float>( sin(angle), 0,  cos(angle), 0),
        SIMD4<Float>(          0, 0,           0, 1)
    )
}

extension simd_float4x4 {
    
    /// Returns a multi-line string that represents the simd4x4 matrix for easier visual reading.
    /// - Parameter indent: If provided, the string to use as a prefix for each line.
    func prettyPrintString(_ indent:String="") -> String {
        var result = ""
        result += "\(indent)[\(self.columns.0.x), \(self.columns.0.y), \(self.columns.0.z), \(self.columns.0.w)]\n"
        result += "\(indent)[\(self.columns.1.x), \(self.columns.1.y), \(self.columns.1.z), \(self.columns.1.w)]\n"
        result += "\(indent)[\(self.columns.2.x), \(self.columns.2.y), \(self.columns.2.z), \(self.columns.2.w)]\n"
        result += "\(indent)[\(self.columns.3.x), \(self.columns.3.y), \(self.columns.3.z), \(self.columns.3.w)]\n"
        return result
    }
}

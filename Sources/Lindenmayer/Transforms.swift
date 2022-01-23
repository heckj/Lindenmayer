//
//  Transforms.swift
//
//  Created by Joseph Heck on 12/21/21.
//

import Foundation
import simd

extension SceneKitRenderer {
    /// Creates a 3D translation transform that scales by the values you provide.
    /// - Parameters:
    ///   - x: The amount to translate along the X axis.
    ///   - y: The amount to translate along the Y axis.
    ///   - z: The amount to translate along the Z axis.
    /// - Returns: A translation transform.
    public static func translationTransform(x: Float, y: Float, z: Float) -> simd_float4x4 {
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
    public static func scalingTransform(x: Float, y: Float, z: Float) -> simd_float4x4 {
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
    public static func rotationAroundZAxisTransform(angle: Angle) -> simd_float4x4 {
        return simd_float4x4(
            SIMD4<Float>(cos(Float(angle.radians)), sin(Float(angle.radians)), 0, 0),
            SIMD4<Float>(-sin(Float(angle.radians)), cos(Float(angle.radians)), 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }
    
    /// Creates a 3D rotation transform that rotates around the X axis by the angle that you provide
    /// - Parameter angle: The amount (in radians) to rotate around the X axis.
    /// - Returns: A X-axis rotation transform.
    public static func rotationAroundXAxisTransform(angle: Angle) -> simd_float4x4 {
        return simd_float4x4(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, cos(Float(angle.radians)), sin(Float(angle.radians)), 0),
            SIMD4<Float>(0, -sin(Float(angle.radians)), cos(Float(angle.radians)), 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }
    
    /// Creates a 3D rotation transform that rotates around the Y axis by the angle that you provide
    /// - Parameter angle: The amount (in radians) to rotate around the Y axis.
    /// - Returns: A Y-axis rotation transform.
    public static func rotationAroundYAxisTransform(angle: Angle) -> simd_float4x4 {
        return simd_float4x4(
            SIMD4<Float>(cos(Float(angle.radians)), 0, -sin(Float(angle.radians)), 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(sin(Float(angle.radians)), 0, cos(Float(angle.radians)), 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }
    
}

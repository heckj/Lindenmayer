//
//  SIMD_Float4x4+Extensions.swift
//
//
//  Created by Joseph Heck on 1/3/22.
//

import Foundation
import simd

extension simd_float4x4 {
    /// Returns a multi-line string that represents the simd4x4 matrix for easier visual reading.
    /// - Parameter indent: If provided, the string to use as a prefix for each line.
    public func prettyPrintString(_ indent: String = "") -> String {
        var result = ""
        result += "\(indent)[\(columns.0.x), \(columns.1.x), \(columns.2.x), \(columns.3.x)]\n"
        result += "\(indent)[\(columns.0.y), \(columns.1.y), \(columns.2.y), \(columns.3.y)]\n"
        result += "\(indent)[\(columns.0.z), \(columns.1.z), \(columns.2.z), \(columns.3.z)]\n"
        result += "\(indent)[\(columns.0.w), \(columns.1.w), \(columns.2.w), \(columns.3.w)]\n"
        return result
    }

    public var rotationTransform: matrix_float3x3 {
        // extract the rotational component from the transform matrix
        let (col1, col2, col3, _) = columns
        let rotationTransform = matrix_float3x3(
            simd_float3(x: col1.x, y: col1.y, z: col1.z),
            simd_float3(x: col2.x, y: col2.y, z: col2.z),
            simd_float3(x: col3.x, y: col3.y, z: col3.z)
        )
        return rotationTransform
    }

    /// Calculate a normalized heading vector, originally vertical, using a 4x4 state transform
    /// - Returns: a 3D unit vector of the heading
    public func headingVector() -> simd_float3 {
//        // full affine method
//        let original_heading_vector = simd_float4(x: 0, y: 1, z: 0, w: 1)
//        let rotated_heading_4 = matrix_multiply(self, original_heading_vector)
//        return simd_float3(x: rotated_heading_4.x, y: rotated_heading_4.y, z:rotated_heading_4.z)
        // pulling just the transform out:
        let short_heading_vector = simd_float3(x: 0, y: 1, z: 0)
        let rotated_heading_3 = matrix_multiply(self.rotationTransform, short_heading_vector)
        return rotated_heading_3
    }

    public func angleFromVertical() -> Float {
        let northpole = simd_float3(x: 0, y: 1, z: 0)
        let heading = headingVector()
        let dot = simd_dot(northpole, heading)
        let calc_angle = acos(dot) / (simd_length(heading) * simd_length(northpole))
        return calc_angle
    }
}

public extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

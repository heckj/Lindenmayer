//
//  RollUpToVerticalTests.swift
//  
//
//  Created by Joseph Heck on 1/18/22.
//

import Lindenmayer
import SceneKit
import SwiftUI // for `Angle`
import simd
import XCTest

final class RollUpToVerticalTests: XCTestCase {

    // NOTE(heckj): When transcribing a 4x4 matrix, the initializer uses
    // 'COLUMNS', not rows - so create simd_float4x4 matrices by vertical columns:
    // top to bottom, left to right.
    static var transform_119 = simd_float4x4(
        simd_float4(-1.1513867, -0.12829041, 2.2153668, 0.0),
        simd_float4(2.173691, 0.43699712, 1.155033, 0.0),
        simd_float4(-0.44651538, 2.458165, -0.08971556, 0.0),
        simd_float4(4.4409075, 13.833499, 8.220964, 1.0)
    )

    func testMatchingEulerAngles() throws {
        let node = SCNNode()
        node.simdTransform = RollUpToVerticalTests.transform_119
        XCTAssertEqual(node.simdEulerAngles.x, 1.648, accuracy: 0.001) // pitch
        XCTAssertEqual(node.simdEulerAngles.y, -1.089, accuracy: 0.001) // yaw
        XCTAssertEqual(node.simdEulerAngles.z, -3.031, accuracy: 0.001) // roll
    }

    func testApplyingAffineTransformsToA3DPoint() throws {
        let pt = simd_float4(0, 0, 1, 1) // x=0, y=0, z=1
        let result = matrix_multiply(RollUpToVerticalTests.transform_119, pt)
        let result2 = matrix_multiply(pt, RollUpToVerticalTests.transform_119)
        // ORDER MATTERS!!
        XCTAssertNotEqual(result, result2)
        print(result)
        
//        print("[0,0,0] through translations: \(matrix_multiply(RollUpToVerticalTests.transform_119, simd_float4(0,0,0,1)))")
//        print("[0,0,1] through translations: \(matrix_multiply(RollUpToVerticalTests.transform_119, simd_float4(0,0,1,1)))")
//        print("[1,0,0] through translations: \(matrix_multiply(RollUpToVerticalTests.transform_119, simd_float4(1,0,0,1)))")
                
        // This insanity is just verifying for myself that I can legit pull out the rotation transform from the
        // 4x4 3D affine transform matrix and use it to get a correct rotation applying it directly to a 1x3 float vector.
        let pt3 = simd_float3(0,0,1)
        let rotation_matrix_3x3 = RollUpToVerticalTests.transform_119.rotationTransform
        let result3 = matrix_multiply(rotation_matrix_3x3, pt3)
        
        XCTAssertEqual(result3.x, result.x - RollUpToVerticalTests.transform_119.columns.3.x, accuracy: 0.00001)
        XCTAssertEqual(result3.y, result.y - RollUpToVerticalTests.transform_119.columns.3.y, accuracy: 0.0001)
        XCTAssertEqual(result3.z, result.z - RollUpToVerticalTests.transform_119.columns.3.z, accuracy: 0.001)
    }

    func testApplyingKnownTransformsToA3DPoint() throws {
        let pt = simd_float3(0, 0, 1) // x=0, y=0, z=1
        let rotate_90_around_Y = rotationAroundYAxisTransform(angle: Float.pi/2).rotationTransform
        
        // DUH tests - identity should be equivalent in either direction
        XCTAssertEqual(matrix_multiply(matrix_identity_float3x3, pt), pt)
        XCTAssertEqual(matrix_multiply(pt, matrix_identity_float3x3), pt)
        
        let rotation_first_result = matrix_multiply(rotate_90_around_Y, pt)
        let point_first_result = matrix_multiply(pt, rotate_90_around_Y)
        // ORDER MATTERS!! - result should be +1 in the X direction
        // which means the matrix calculation with the transform first, then the
        // point we're transforming, is correct.
        XCTAssertNotEqual(rotation_first_result, point_first_result)
        print(rotation_first_result)
        XCTAssertEqual(rotation_first_result.x, 1, accuracy: 0.00001)
        XCTAssertEqual(rotation_first_result.y, 0, accuracy: 0.00001)
        XCTAssertEqual(rotation_first_result.z, 0, accuracy: 0.00001)

        // Doing this in the reverse order gives you a vector in the opposite direction
        print(point_first_result)
        XCTAssertEqual(point_first_result.x, -1, accuracy: 0.00001)
        XCTAssertEqual(rotation_first_result.y, 0, accuracy: 0.00001)
        XCTAssertEqual(rotation_first_result.z, 0, accuracy: 0.00001)
    }
    
    func testRotatingIdentityMatrix() throws {
        // Identity state vector indicates we've not moved from start, so the forward vector is +Y and the
        // up vector is +Z. No amount of rotation will do us any good, since the plane we're rotating on (the X-Z plane)
        // can't get any closer to +Y.
        let rotation_on_XZ_plane = try rotationToVerticalTestCode(matrix_identity_float4x4)
        XCTAssertEqual(0, rotation_on_XZ_plane)
    }

    func testRotating45degToRightMatrix() throws {
        // This rotation is a "right turn" from the starting position, straight up. We rotation 45° around
        // the Z axis - negative rotation to make it to the right.
        // The resulting rotation plane is tilted 45° to the right as well, so should result in a rotation
        // of -90° on that plane to get the "up" vector as close to +Y as possible.
        let state_transform = matrix_multiply(matrix_identity_float4x4, rotationAroundZAxisTransform(angle: -Float.pi/4))
        let rotation_on_plane = try rotationToVerticalTestCode(state_transform)
        XCTAssertEqual(-Float.pi/2, rotation_on_plane, accuracy: 0.0001)
    }

    func testRotating45degToLeftMatrix() throws {
        // This rotation is a "right turn" from the starting position, straight up. We rotation 45° around
        // the Z axis - negative rotation to make it to the right.
        // The resulting rotation plane is tilted 45° to the right as well, so should result in a rotation
        // of -90° on that plane to get the "up" vector as close to +Y as possible.
        let state_transform = matrix_multiply(matrix_identity_float4x4, rotationAroundZAxisTransform(angle: Float.pi/4))
        let rotation_on_plane = try rotationToVerticalTestCode(state_transform)
        XCTAssertEqual(Float.pi/2, rotation_on_plane, accuracy: 0.0001)
    }

    func testRotating45degPitchUpMatrix() throws {
        // This rotation is a "pitch up" from the starting position, straight up. We rotate 45° around
        // the X axis - negative rotation to make it pitch 'up'.
        // The resulting rotation plane is tilted 45° up towards -Z, so should result in a rotation
        // of 180° on that plane to get the "up" vector as close to +Y as possible.
        let state_transform = matrix_multiply(matrix_identity_float4x4, rotationAroundXAxisTransform(angle: -Float.pi/4))
        let rotation_on_plane = try rotationToVerticalTestCode(state_transform)
        XCTAssertEqual(Float.pi, rotation_on_plane, accuracy: 0.0001)
    }

    func testRotating45degPitchDownMatrix() throws {
        // This rotation is a "pitch down" from the starting position, straight up. We rotate 45° around
        // the X axis - positive rotation to make it to pitch 'down'.
        // The resulting rotation plane is tilted 45° up towards the +z, so should result in a rotation
        // of 0° on that plane to get the "up" vector as close to +Y as possible.
        let state_transform = matrix_multiply(matrix_identity_float4x4, rotationAroundXAxisTransform(angle: Float.pi/4))
        let rotation_on_plane = try rotationToVerticalTestCode(state_transform)
        XCTAssertEqual(0, rotation_on_plane, accuracy: 0.0001)
    }

    func testRotating90degPitchUpMatrix() throws {
        // Since we start facing straight up, pitching up another 90° results in us facing the +z direction
        // with the "up" vector now rotated to point pretty much straight in the -Y direction.
        let state_transform = matrix_multiply(matrix_identity_float4x4, rotationAroundXAxisTransform(angle: Float.pi/2))
        let rotation_on_plane = try rotationToVerticalTestCode(state_transform)
        XCTAssertEqual(Float.pi, rotation_on_plane, accuracy: 0.0001)
    }

    func rotationToVerticalTestCode(_ full_transform: simd_float4x4) throws -> Float {
        // The interpretation of this symbol is a tricky beast. From pg 41 of
        // http://algorithmicbotany.org/papers/hanan.dis1992.pdf
        // 'PARAMETRIC L-SYSTEMS AND THEIR APPLICATION TO THE MODELLING AND VISUALIZATION OF PLANTS'
        //
        // @V rotates the turtle around it's heading vector so that the left vector is horizontal and the y component of the up vector is positive.
        // The initial heading of the 3D turtle vector is "upward" (in the +Y direction in SceneKit),
        // and the "up vector" relative to that heading is a unit-vector in the +Z direction.
        // The intention of this symbol is to take the rotation around the axis of the heading (whatever
        // the +Y unit vector has been rotated to), and rotate/roll around that vector so that the
        // "up" direction is as close to vertical in the world-space as possible.
        
        // We implement this by pulling out just the rotation portion of the transform from the
        // current world transform and applying that to the original "up" vector to get the up vector
        // rotated to match the current state of the heading.
        let original_heading_up_vector = simd_float3(x: 0, y: 0, z: 1)
        let north_pole_vector = simd_float3(x: 0,y: 1,z: 0)
        let rotated_up_vector = matrix_multiply(full_transform.rotationTransform, original_heading_up_vector)
        print("rotated up vector: \(rotated_up_vector), length: \(simd_length(rotated_up_vector))")
        
        // Now we need to project this onto the rotated X,Z plane - which is most conveniently defined
        // as the normal vector from that plane - otherwise known as our heading vector.
        let heading_vector = full_transform.headingVector()
        print("heading vector: \(heading_vector), length: \(simd_length(heading_vector))")
        
        // These two vector should be 90° difference from each other, so let's double check that by
        // computing the angle between the rotated heading and rotated up vectors:
        let double_check_angle = acos(
            simd_dot(heading_vector, rotated_up_vector) /
            ( simd_length(heading_vector) * simd_length(rotated_up_vector) )
        )
        XCTAssertEqual(Float.pi/2, double_check_angle, accuracy: 0.00001)
        
        // Now we need to project the world +y Vector onto the plane represented by the heading vector
        // as a normal to that plane. The resulting vector will be limited to that plane, and that's what
        // we can use to compare the angle to the rotated up vector, which is also on that plane, as we
        // just verified.
        
        // The formula for projecting a vector onto a plane:
        // vec_projected = vector - ( ( vector • plane_normal ) / plane_normal.length^2 ) * plane_normal
        // You can look at this conceptually as taking the vector you want to project and subtracting from it
        // the portion of the vector that corresponds to the normal vector, which leaves you with just the
        // component that's aligned on the plane.
        // 🎩 to Greg Titus, who referred me to https://www.maplesoft.com/support/help/maple/view.aspx?path=MathApps%2FProjectionOfVectorOntoPlane
        
        print("+Y • plane-normal = \(simd_dot(north_pole_vector, heading_vector))")
        
        let component_of_normal = ( simd_dot(north_pole_vector, heading_vector) / simd_length_squared(heading_vector) ) * heading_vector
        print("component along normal vector: \(component_of_normal), length: \(simd_length(component_of_normal))")
        let projected_vector = north_pole_vector - component_of_normal
        print("projected vector onto plane: \(projected_vector), length: \(simd_length(projected_vector))")
        
        // Finally, we calculate the angle between this projected vector and the world-space UP (+Y in SceneKit)
        // vector to get the angle we'll want to roll to make everything "aligned" as closely as possible.
        // It's worth noting that if the projected vector is really small, this might be a little insane.
        // That means that the plane around which we're rotating is nearly perfectly aligned with the
        // world's X-Z coordinate plane, and there's just no rotation that makes a difference. Fortunately, as
        // the value trends to 0, then the value of acos(θ) tends to 0 as well - so at least this is numerically stable.
        //
        // acos(1.0) => 0
        // acos(0.5) => 60° (1.0471976)
        // acos(0.0) => 90° (1.5707963)
        
        print("projected_vector • rotated_up_vector = \(simd_dot(projected_vector, rotated_up_vector))")
        let resulting_angle = acos(
            simd_dot(rotated_up_vector, projected_vector) /
            ( simd_length(projected_vector) * simd_length(rotated_up_vector) )
        )

        // I think I need to determine a +/- value to this rotation, as the angle isn't signed - it's not directional.
        print("And the resulting angle: \(resulting_angle) (\(Angle(radians: Double(resulting_angle)).degrees)°)")
        return resulting_angle
    }

}


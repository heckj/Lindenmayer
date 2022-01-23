//
//  TransformTests.swift
//
//  Created by Joseph Heck on 12/22/21.
//

import Lindenmayer
import SceneKit
import simd
import XCTest

final class TransformTests: XCTestCase {
    func testTranslationTransformMatchesSceneKit() throws {
        let node = SCNNode()
        let x = 1.5
        let y = 2.67
        let z = 3.81

        node.simdPosition = simd_float3(x: Float(x), y: Float(y), z: Float(z))

        let transform = SceneKitRenderer.translationTransform(x: Float(x), y: Float(y), z: Float(z))

        XCTAssertEqual(transform, node.simdTransform)
    }

    func testScalingTransformMatchesSceneKit() throws {
        let node = SCNNode()
        let x = 1.5
        let y = 2.67
        let z = 3.81

        node.simdScale = simd_float3(x: Float(x), y: Float(y), z: Float(z))

        let transform = SceneKitRenderer.scalingTransform(x: Float(x), y: Float(y), z: Float(z))

        XCTAssertEqual(transform, node.simdTransform)
    }

    func testRollTransformMatchesSceneKit() throws {
        let node = SCNNode()
        let angle = Angle(degrees: 30)
        // pitch, yaw, roll
        node.simdEulerAngles = simd_float3(x: 0, y: 0, z: Float(angle.radians))

        let transform = SceneKitRenderer.rotationAroundZAxisTransform(angle: angle)

        XCTAssertEqual(transform, node.simdTransform)
    }

    func testYawTransformMatchesSceneKit() throws {
        let node = SCNNode()
        let angle = Angle(degrees: 30)
        // pitch, yaw, roll
        node.simdEulerAngles = simd_float3(x: 0, y: Float(angle.radians), z: 0)

        let transform = SceneKitRenderer.rotationAroundYAxisTransform(angle: angle)

        XCTAssertEqual(transform, node.simdTransform)
    }

    func testPitchTransformMatchesSceneKit() throws {
        let node = SCNNode()
        let angle = Angle(degrees: 30)
        // pitch, yaw, roll
        node.simdEulerAngles = simd_float3(x: Float(angle.radians), y: 0, z: 0)

        let transform = SceneKitRenderer.rotationAroundXAxisTransform(angle: angle)

        XCTAssertEqual(transform, node.simdTransform)
    }
}

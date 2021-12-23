//
//  TransformTests.swift
//
//  Created by Joseph Heck on 12/22/21.
//

import Lindenmayer
import simd
import SceneKit
import XCTest

final class TransformTests: XCTestCase {

    func degreesToRadians(_ value: Double) -> Double {
        return value * .pi / 180.0
    }

    func testTranslationTransformMatchesSceneKit() throws {

        let node = SCNNode()
        let x = 1.5
        let y = 2.67
        let z = 3.81
        
        node.simdPosition = simd_float3(x: Float(x), y: Float(y), z: Float(z))
        
        let transform = translationTransform(x: Float(x), y:Float(y), z: Float(z))
        
        XCTAssertEqual(transform, node.simdTransform)
    }

    func testScalingTransformMatchesSceneKit() throws {

        let node = SCNNode()
        let x = 1.5
        let y = 2.67
        let z = 3.81
        
        node.simdScale = simd_float3(x: Float(x), y: Float(y), z: Float(z))
        
        let transform = scalingTransform(x: Float(x), y:Float(y), z: Float(z))
        
        XCTAssertEqual(transform, node.simdTransform)
    }

    func testRollTransformMatchesSceneKit() throws {

        let node = SCNNode()
        let angle = degreesToRadians(30)
        // pitch, yaw, roll
        node.simdEulerAngles = simd_float3(x: 0, y: 0, z: Float(angle))
        
        let transform = rotationAroundZAxisTransform(angle: Float(angle))
        
        XCTAssertEqual(transform, node.simdTransform)
    }

    func testYawTransformMatchesSceneKit() throws {

        let node = SCNNode()
        let angle = degreesToRadians(30)
        // pitch, yaw, roll
        node.simdEulerAngles = simd_float3(x: 0, y: Float(angle), z: 0)
        
        let transform = rotationAroundYAxisTransform(angle: Float(angle))
        
        XCTAssertEqual(transform, node.simdTransform)
    }

    func testPitchTransformMatchesSceneKit() throws {

        let node = SCNNode()
        let angle = degreesToRadians(30)
        // pitch, yaw, roll
        node.simdEulerAngles = simd_float3(x: Float(angle), y: 0, z: 0)
        
        let transform = rotationAroundXAxisTransform(angle: Float(angle))
        
        XCTAssertEqual(transform, node.simdTransform)
    }

}

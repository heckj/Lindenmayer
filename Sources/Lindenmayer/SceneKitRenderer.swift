//
//  SceneKitRenderer.swift
//
//
//  Created by Joseph Heck on 12/18/21.
//

import CoreGraphics
import SwiftUI // for `Angle`
import Foundation
import SceneKit
import simd

struct GrowthState {
    var transform: simd_float4x4
    var nodeRef: SCNNode

    init(node: SCNNode, transform: simd_float4x4) {
        self.transform = transform
        nodeRef = node
    }

    /// A convenience initializer that locates the growth state at the origin, and without a defined material.
    init(node: SCNNode) {
        self.init(node: node,
                  transform: matrix_identity_float4x4)
    }

    func applyingTransform(_ transform: simd_float4x4) -> GrowthState {
        let newTransform = matrix_multiply(self.transform, transform)
        return GrowthState(node: nodeRef, transform: newTransform)
    }

    func printEulerAngles() {
        let temp = SCNNode()
        temp.simdTransform = transform
        print(" - current Euler angles: \(temp.simdEulerAngles)")
        print("   pitch: \(temp.simdEulerAngles.x)")
        print("   yaw: \(temp.simdEulerAngles.y)")
        print("   roll: \(temp.simdEulerAngles.z)")
    }

    func simdEulerAngles() -> simd_float3 {
        let temp = SCNNode()
        temp.simdTransform = transform
        return temp.simdEulerAngles
    }
}

extension ColorRepresentation {
    var material: SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor(red: red, green: green, blue: blue, alpha: alpha)
        return material
    }
}

public struct SceneKitRenderer {
    public init() {}

    func material(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor(red: red, green: green, blue: blue, alpha: alpha)
        return material
    }

    func addDebugFlooring(_ scene: SCNScene, grid: Bool = true) {
        let flooring = SCNNode(geometry: SCNPlane(width: 10, height: 10))
        flooring.geometry?.materials = [material(red: 0.1, green: 0.7, blue: 0.1, alpha: 0.5)]
        flooring.simdEulerAngles = simd_float3(x: Float(Angle(degrees: -90).radians), y: 0, z: 0)

        let axisMaterials = [material(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)]

        let dot3D = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        dot3D.materials = axisMaterials

        let lowresCyl = SCNCylinder(radius: 0.01, height: 10)
        lowresCyl.radialSegmentCount = 8
        lowresCyl.heightSegmentCount = 1
        lowresCyl.materials = axisMaterials

        let zaxis = SCNNode(geometry: lowresCyl)
        flooring.addChildNode(zaxis)
        let xaxis = SCNNode(geometry: lowresCyl)
        xaxis.simdEulerAngles = simd_float3(x: 0, y: 0, z: Float(Angle(degrees: 90).radians))
        flooring.addChildNode(xaxis)
        let yaxis = SCNNode(geometry: lowresCyl)
        yaxis.simdEulerAngles = simd_float3(x: Float(Angle(degrees: 90).radians), y: 0, z: 0)
        flooring.addChildNode(yaxis)

        if grid {
            let loc: [Float] = [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5]
            for i in loc {
                for j in loc {
                    let dot = SCNNode(geometry: dot3D)
                    dot.simdPosition = simd_float3(x: Float(i), y: Float(j), z: 0)
                    flooring.addChildNode(dot)
                }
            }
        }

        scene.rootNode.addChildNode(flooring)
    }

    public func generateScene(lsystem: LSystem) -> SCNScene {
        generateScene(lsystem: lsystem).0
    }

    public func generateScene(lsystem: LSystem) -> (SCNScene, [matrix_float4x4]) {
        let scene = SCNScene()
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)

        // set up debug/sizing flooring
        addDebugFlooring(scene)

        var transformSequence: [matrix_float4x4] = []

        var currentState = GrowthState(node: scene.rootNode)
        var stateStack: [GrowthState] = []

        for (index, module) in lsystem.state.enumerated() {
            // process the 'module.render3D'
            let cmd = module.render3D
            switch cmd.name {
            case TurtleCodes.pitchUp.rawValue:
                // positive values pitch nose up (positive rotation around X axis)
                if let cmd = cmd as? RenderCommand.PitchUp {
                    let directionAngleInRadians = Float(cmd.angle.radians)
                    let pitchTransform = rotationAroundXAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(pitchTransform)
//                    print("Pitch (rotate around +X Axis) by \(cmd.angle)° -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.pitchDown.rawValue:
                // negative values pitch nose down (negative rotation around X axis)
                if let cmd = cmd as? RenderCommand.PitchDown {
                    let directionAngleInRadians = -1.0 * Float(cmd.angle.radians)
                    let pitchTransform = rotationAroundXAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(pitchTransform)
//                    print("Pitch (rotate around -X Axis) by \(cmd.angle)° -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.rollLeft.rawValue:
                if let cmd = cmd as? RenderCommand.RollLeft {
                    // negative values roll to the left (negative rotation around Y axis)
                    let directionAngleInRadians = -1.0 * Float(cmd.angle.radians)
                    let rollTransform = rotationAroundYAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(rollTransform)
//                    print("Roll (rotate around -Y Axis) by \(cmd.angle)° -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.rollRight.rawValue:
                if let cmd = cmd as? RenderCommand.RollRight {
                    // positive values roll to the right (positive rotation around Y axis)
                    let directionAngleInRadians = Float(cmd.angle.radians)
                    let rollTransform = rotationAroundYAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(rollTransform)
//                    print("Roll (rotate around +Y Axis) by \(cmd.angle)° -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.leftTurn.rawValue:
                if let cmd = cmd as? RenderCommand.TurnLeft {
                    // positive values turn to the left (positive rotation around Z axis)
                    let directionAngleInRadians = Float(cmd.angle.radians)
                    let yawTransform = rotationAroundZAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(yawTransform)
//                    print("Yaw (rotate around +Z Axis) by \(cmd.angle)° -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.rightTurn.rawValue:
                if let cmd = cmd as? RenderCommand.TurnRight {
                    // negative values turn to the right (negative rotation around Z axis)
                    let directionAngleInRadians = -1.0 * Float(cmd.angle.radians)
                    let yawTransform = rotationAroundZAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(yawTransform)
//                    print("Yaw (rotate around -Z Axis) by \(cmd.angle)° -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.rollToHorizontal.rawValue:
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
                //
                // We implement this by pulling out just the rotation portion of the transform from the
                // current world transform, inverting it, and applying that to the original "up" vector
                // to get the up vector of the current state projected back into world coordinates, so that
                // we know that the angle is on the X-Z plane.
                let inverse_rotation = currentState.transform.rotationTransform().inverse
                let original_heading_up_vector = simd_float3(x: 0, y: 0, z: 1)
                let rotated_up_vector = matrix_multiply(original_heading_up_vector, inverse_rotation)
                // should be length=1 already, but just in case...
                let normalized = simd_normalize(rotated_up_vector)
                // Then we calculate the between the "rotated up" vector and world-space UP (+Y in SceneKit)
                // to get the amount of angle we should roll. We're explicitly working with normalized vectors
                // here to make the calculation of cos-1( a • b / |a| * |b| ) easier. With unit vectors, this
                // collapses to acos(a • b).
                let calculated_rotation_angle = acos(simd_dot(simd_float3(0, 1, 0), normalized))
                // print(" +++ rotation angle to apply: \(calculated_rotation_angle)")
                // And finally, we apply that as an additional rotation transform to the current state.
                let rotationTransform = rotationAroundYAxisTransform(angle: calculated_rotation_angle)
                currentState = currentState.applyingTransform(rotationTransform)

            case TurtleCodes.move.rawValue:
                if let cmd = cmd as? RenderCommand.Move {
                    let moveTransform = translationTransform(x: 0, y: Float(cmd.length), z: 0)
                    currentState = currentState.applyingTransform(moveTransform)
//                    print("Moving forward by \(cmd.length) -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.branch.rawValue:
                stateStack.append(currentState)
//                print("Saving state: \(String(describing: currentState.transform))")

            case TurtleCodes.endBranch.rawValue:
                currentState = stateStack.removeLast()
//                print("Restored state to: \(String(describing: currentState.transform))")

            case TurtleCodes.cylinder.rawValue:
                if let cmd = cmd as? RenderCommand.Cylinder {
                    let node = SCNNode(geometry: SCNCylinder(radius: cmd.radius, height: cmd.length))
                    if let colorRep = cmd.color {
                        node.geometry?.materials = [colorRep.material]
                    }
                    node.name = "n\(index)"

                    // Nudge the cylinder "up" so that its bottom is at the "origin" of the transform.
                    let nudgeOriginTransform = translationTransform(x: 0, y: Float(cmd.length / 2.0), z: 0)
                    //                print(" - calc nudgeTransform: \(nudgeOriginTransform)")
                    node.simdTransform = matrix_multiply(currentState.transform, nudgeOriginTransform)

                    scene.rootNode.addChildNode(node)
                    currentState.nodeRef = node

                    // Move the origin of the where to put the next object at the "end" of this node.
                    let moveStateTransform = translationTransform(x: 0, y: Float(cmd.length), z: 0)
                    currentState = currentState.applyingTransform(moveStateTransform)

//                    print("Added cylinder (r=\(cmd.radius)) by \(cmd.length) at \(String(describing: node.simdTransform))")
                    //                print("Moving +y by \(cmd.length) -> \(String(describing: currentState.transform))")
                }
            case TurtleCodes.cone.rawValue:
                if let cmd = cmd as? RenderCommand.Cone {
                    let node = SCNNode(geometry: SCNCone(topRadius: cmd.radiusTop, bottomRadius: cmd.radiusBottom, height: cmd.length))
                    if let colorRep = cmd.color {
                        node.geometry?.materials = [colorRep.material]
                    }
                    node.name = "n\(index)"

                    // Nudge the cylinder "up" so that its bottom is at the "origin" of the transform.
                    let nudgeOriginTransform = translationTransform(x: 0, y: Float(cmd.length / 2.0), z: 0)
                    node.simdTransform = matrix_multiply(currentState.transform, nudgeOriginTransform)

                    scene.rootNode.addChildNode(node)
                    currentState.nodeRef = node

                    // Move the origin of the where to put the next object at the "end" of this node.
                    let moveStateTransform = translationTransform(x: 0, y: Float(cmd.length), z: 0)
                    currentState = currentState.applyingTransform(moveStateTransform)

//                    print("Added cone (tr=\(cmd.radiusTop), br=\(cmd.radiusBottom) by \(cmd.length) at \(String(describing: node.simdTransform))")
                    //                print("Moving +y by \(cmd.length) -> \(String(describing: currentState.transform))")
                }
            case TurtleCodes.sphere.rawValue:
                if let cmd = cmd as? RenderCommand.Sphere {
                    let node = SCNNode(geometry: SCNSphere(radius: cmd.radius))
                    if let colorRep = cmd.color {
                        node.geometry?.materials = [colorRep.material]
                    }
                    node.name = "n\(index)"

                    node.simdTransform = currentState.transform

                    scene.rootNode.addChildNode(node)
                    currentState.nodeRef = node

//                    print("Added sphere (r=\(cmd.radius)) at \(String(describing: node.simdTransform))")
                    //                print("Moving +y by \(radius) -> \(String(describing: currentState.transform))")
                }
            default: // ignore
                break
            } // switch cmd.name
            transformSequence.append(currentState.transform)
        } // for module in lsystem.state

        let (boundingMin, boundingMax) = scene.rootNode.boundingBox
        let distance = max(
            max(boundingMin.x, boundingMax.x),
            max(boundingMin.y, boundingMax.y),
            max(boundingMin.z, boundingMax.z)
        )
        // place the camera
        cameraNode.position = SCNVector3(x: distance, y: distance * 1.2, z: distance)
        cameraNode.simdLook(at: simd_float3(x: 0, y: Float(distance) / 2.0, z: 0))

        return (scene, transformSequence)
    }
}

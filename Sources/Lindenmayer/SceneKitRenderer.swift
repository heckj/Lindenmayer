//
//  SceneKitRenderer.swift
//
//
//  Created by Joseph Heck on 12/18/21.
//

import CoreGraphics
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
        flooring.simdEulerAngles = simd_float3(x: degreesToRadians(-90), y: 0, z: 0)

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
        xaxis.simdEulerAngles = simd_float3(x: 0, y: 0, z: degreesToRadians(90))
        flooring.addChildNode(xaxis)
        let yaxis = SCNNode(geometry: lowresCyl)
        yaxis.simdEulerAngles = simd_float3(x: degreesToRadians(90), y: 0, z: 0)
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
                    let directionAngleInRadians: Float = degreesToRadians(cmd.angle)
                    let pitchTransform = rotationAroundXAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(pitchTransform)
                    print("Pitch (rotate around +X Axis) by \(cmd.angle)° -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.pitchDown.rawValue:
                // negative values pitch nose down (negative rotation around X axis)
                if let cmd = cmd as? RenderCommand.PitchDown {
                    let directionAngleInRadians: Float = -1.0 * degreesToRadians(cmd.angle)
                    let pitchTransform = rotationAroundXAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(pitchTransform)
                    print("Pitch (rotate around -X Axis) by \(cmd.angle)° -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.rollLeft.rawValue:
                if let cmd = cmd as? RenderCommand.RollLeft {
                    // negative values roll to the left (negative rotation around Y axis)
                    let directionAngleInRadians: Float = -1.0 * degreesToRadians(cmd.angle)
                    let rollTransform = rotationAroundYAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(rollTransform)
                    print("Roll (rotate around -Y Axis) by \(cmd.angle)° -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.rollRight.rawValue:
                if let cmd = cmd as? RenderCommand.RollRight {
                    // positive values roll to the right (positive rotation around Y axis)
                    let directionAngleInRadians: Float = degreesToRadians(cmd.angle)
                    let rollTransform = rotationAroundYAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(rollTransform)
                    print("Roll (rotate around +Y Axis) by \(cmd.angle)° -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.leftTurn.rawValue:
                if let cmd = cmd as? RenderCommand.TurnLeft {
                    // positive values turn to the left (positive rotation around Z axis)
                    let directionAngleInRadians: Float = degreesToRadians(cmd.angle)
                    let yawTransform = rotationAroundZAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(yawTransform)
                    print("Yaw (rotate around +Z Axis) by \(cmd.angle)° -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.rightTurn.rawValue:
                if let cmd = cmd as? RenderCommand.TurnRight {
                    // negative values turn to the right (negative rotation around Z axis)
                    let directionAngleInRadians: Float = -1.0 * degreesToRadians(cmd.angle)
                    let yawTransform = rotationAroundZAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(yawTransform)
                    print("Yaw (rotate around -Z Axis) by \(cmd.angle)° -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.spinToHorizontal.rawValue:
                // Angle is the computed difference between the current heading and straight "up".
                let angle = currentState.transform.angleFromVertical()
                print("Leveling out from angle: \(angle) vs. \(Float.pi / 2)")
                if angle < (Float.pi / 2) {
                    print(" != No action needed - pointed above the horizon...")
                } else {
                    let current_rotation = simd_quatf(currentState.transform)
                    let northpole = simd_quatf(angle: 0, axis: simd_float3(x: 0, y: 1, z: 0))
//                        print("northpole quat: \(northpole) (angle: \(northpole.angle))")

//                        print(" - Interpolated to 0: \(simd_slerp(current, northpole, 0.0)) Θ=\(simd_slerp(current, northpole, 0.0).angle)")
//                        print(" - Interpolated to 0.1: \(simd_slerp(current, northpole, 0.1)) Θ=\(simd_slerp(current, northpole, 0.1).angle)")
//                        print(" - Interpolated to 0.2: \(simd_slerp(current, northpole, 0.2)) Θ=\(simd_slerp(current, northpole, 0.2).angle)")
//                        print(" - Interpolated to 0.3: \(simd_slerp(current, northpole, 0.3)) Θ=\(simd_slerp(current, northpole, 0.3).angle)")
//                        print(" - Interpolated to 0.4: \(simd_slerp(current, northpole, 0.4)) Θ=\(simd_slerp(current, northpole, 0.4).angle)")
//                        print(" - Interpolated to 0.5: \(simd_slerp(current, northpole, 0.5)) Θ=\(simd_slerp(current, northpole, 0.5).angle)")
//                        print(" - Interpolated to 0.6: \(simd_slerp(current, northpole, 0.6)) Θ=\(simd_slerp(current, northpole, 0.6).angle)")
//                        print(" - Interpolated to 0.7: \(simd_slerp(current, northpole, 0.7)) Θ=\(simd_slerp(current, northpole, 0.7).angle)")
//                        print(" - Interpolated to 0.8: \(simd_slerp(current, northpole, 0.8)) Θ=\(simd_slerp(current, northpole, 0.8).angle)")
//                        print(" - Interpolated to 0.9: \(simd_slerp(current, northpole, 0.9)) Θ=\(simd_slerp(current, northpole, 0.9).angle)")
//                        print(" - Interpolated to 1.0: \(simd_slerp(current, northpole, 1.0)) Θ=\(simd_slerp(current, northpole, 1.0).angle)")

                    let interpolation_percentage = .pi / 2.0 / angle
                    print(" - Est. interpolation percentage to get horizon: \(interpolation_percentage)")
                    let new_rotation = simd_slerp(current_rotation, northpole, interpolation_percentage)
//                        print(" interpolated quaternion: \(new_rotation), Θ=\(new_rotation.angle)")
                    // convert back to a rotation by creating a new SCNNode, applying the state's transform,
                    // and then updating the rotation on the SCNNode with the new_rotation we calculated
                    // through interpolation. Then apply that node's SCNTransform back over the current one to
                    // apply transform that reflects the updated rotation immediately.
                    let temp = SCNNode()
                    temp.simdTransform = currentState.transform
                    temp.simdOrientation = new_rotation
                    currentState.transform = temp.simdTransform
//                    print("Updated transform:")
//                    print(currentState.transform.prettyPrintString("  "))
                }

            case TurtleCodes.move.rawValue:
                if let cmd = cmd as? RenderCommand.Move {
                    let moveTransform = translationTransform(x: 0, y: Float(cmd.length), z: 0)
                    currentState = currentState.applyingTransform(moveTransform)
                    print("Moving forward by \(cmd.length) -> \(String(describing: currentState.transform))")
                }

            case TurtleCodes.branch.rawValue:
                stateStack.append(currentState)
                print("Saving state: \(String(describing: currentState.transform))")

            case TurtleCodes.endBranch.rawValue:
                currentState = stateStack.removeLast()
                print("Restored state to: \(String(describing: currentState.transform))")

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

                    print("Added cylinder (r=\(cmd.radius)) by \(cmd.length) at \(String(describing: node.simdTransform))")
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

                    print("Added cone (tr=\(cmd.radiusTop), br=\(cmd.radiusBottom) by \(cmd.length) at \(String(describing: node.simdTransform))")
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

                    print("Added sphere (r=\(cmd.radius)) at \(String(describing: node.simdTransform))")
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

    // MARK: - Internal

    func degreesToRadians(_ value: Double) -> Float {
        return Float(value * .pi / 180.0)
    }

    func degrees(radians: Float) -> Float {
        return radians / .pi * 180.0
    }
}

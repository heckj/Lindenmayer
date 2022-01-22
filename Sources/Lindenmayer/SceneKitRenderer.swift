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
import SwiftUI // for `Angle`

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
    /// Provides a SceneKit material based on the color representation values.
    var material: SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor(red: red, green: green, blue: blue, alpha: alpha)
        return material
    }
}

/// A renderer that generates a 3D graphical representation of an L-system using SceneKit.
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
    
    func rotateAroundHeadingToVertical(_ full_transform: simd_float4x4) -> Float {
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
        
        // Huge thank you (🎩-tip) to [DMGregory](https://twitter.com/D_M_Gregory) for his help this
        // (improved) solution.
        // https://gamedev.stackexchange.com/questions/198977/how-to-solve-for-the-angle-of-a-axis-angle-rotation-that-gets-me-closest-to-a-sp/199027#199027
        let heading = full_transform.headingVector()
        //print("heading vector of transform: \(heading), length: \(simd_length(heading))")
        let worldUp = simd_float3(x: 0, y: 1, z: 0)
        
        if (simd_dot(heading, worldUp) > 0.999999 || simd_dot(heading, worldUp) < -0.999999) {
            return 0
        }
        
        // Numerical explosion when heading is directly up or down in this case
        //print("Two vectors that represent the plane normal to the current heading:")
        let planeRight = simd_normalize(simd_cross(heading, worldUp));
        //print("  planeRight vector: \(planeRight), length: \(simd_length(planeRight))")
        let planeUp = simd_cross(planeRight, heading);
        //print("  planeUp vector: \(planeUp), length: \(simd_length(planeUp))")
                             
        let rotated_up_vector = matrix_multiply(full_transform.rotationTransform, simd_float3(x: 0, y: 0, z: 1))
        //print("the 'up' vector as rotated by the transform: \(rotated_up_vector), length: \(simd_length(rotated_up_vector))")
        // Numerically more stable version of the roll angle using the inverse tangent of the
        // dot products between the rotated up vector and the plane that represents the base
        // of the heading.
        // Think of the dot products as getting the X and Y coordinates of our current
        // vector on the rotated plane, and from that the two-argument arctangent gets us
        // the angle of the vector from the positive X-axis in that plane.
        let resulting_angle = atan2(simd_dot(rotated_up_vector, planeRight), simd_dot(rotated_up_vector, planeUp));
        //print("And the resulting angle: \(resulting_angle) (\(Angle(radians: Double(resulting_angle)).degrees)°)")
        return resulting_angle
    }

    /// Generates a SceneKit scene from the L-system that you provide.
    /// - Parameter lsystem: The L-system to render into a 3D scene.
    /// - Returns: A SceneKit scene rendered from the L-system.
    ///
    /// The scene includes a camera node identified as `camera`, and a plane to represent the floor and scale of the scene.
    public func generateScene(lsystem: LSystem) -> SCNScene {
        generateScene(lsystem: lsystem).0
    }

    /// Generates a SceneKit scene from the L-system that you provide.
    /// - Parameter lsystem: The L-system to render into a 3D scene.
    /// - Returns: A tuple of the rendered SceneKit scene and an array of transforms that represent each module's state transition while rendering the scene.
    ///
    /// The scene includes a camera node identified as `camera`, and a plane to represent the floor and scale of the scene.
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

            case TurtleCodes.rollUpToVertical.rawValue:
                let resulting_angle = rotateAroundHeadingToVertical(currentState.transform)
                let rotationTransform = rotationAroundYAxisTransform(angle: resulting_angle)
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

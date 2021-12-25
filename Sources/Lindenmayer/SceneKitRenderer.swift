//
//  SceneKitRenderer.swift
//  
//
//  Created by Joseph Heck on 12/18/21.
//

import Foundation
import CoreGraphics
import SceneKit

struct GrowthState {
    var transform: simd_float4x4
    var nodeRef: SCNNode
    
    init(node: SCNNode, transform: simd_float4x4) {
        self.transform = transform
        self.nodeRef = node
    }
    
    /// A convenience initializer that locates the growth state at the origin, and without a defined material.
    init(node: SCNNode) {
        self.init(node: node,
                  transform: matrix_identity_float4x4)
    }
    
    func applyingTransform(_ transform: simd_float4x4) -> GrowthState {
        let newTransform = matrix_multiply(self.transform, transform)
        return GrowthState(node: self.nodeRef, transform: newTransform)
    }
    
    func printEulerAngles() {
        let temp = SCNNode()
        temp.simdTransform = self.transform
        print(" - current Euler angles: \(temp.simdEulerAngles)")
        print("   pitch: \(temp.simdEulerAngles.x)")
        print("   yaw: \(temp.simdEulerAngles.y)")
        print("   roll: \(temp.simdEulerAngles.z)")
    }
    
    func simdEulerAngles() -> simd_float3 {
        let temp = SCNNode()
        temp.simdTransform = self.transform
        return temp.simdEulerAngles
    }
}

extension ColorRepresentation {
    var material: SCNMaterial {
        get {
            let material = SCNMaterial()
            material.diffuse.contents = CGColor(red: self.red, green: self.green, blue: self.blue, alpha: self.alpha)
            return material
        }
    }
}

public struct SceneKitRenderer {
    let lsystem: LSystem
    public init(_ lsystem: LSystem) {
        self.lsystem = lsystem
    }
    
    func material(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor(red: red, green: green, blue: blue, alpha: alpha)
        return material
    }
    
    func addDebugFlooring(_ scene: SCNScene, grid: Bool = true) {
        let flooring = SCNNode(geometry: SCNPlane(width: 10, height: 10))
        flooring.geometry?.materials = [material(red: 0.1,green: 0.7,blue: 0.1,alpha: 0.5)]
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
            let loc: [Float] = [-5,-4,-3,-2,-1,0,1,2,3,4,5]
            for i in loc {
                for j in loc {
                    print("\(i),\(j)")
                    let dot = SCNNode(geometry: dot3D)
                    dot.simdPosition = simd_float3(x: Float(i), y: Float(j), z: 0)
                    flooring.addChildNode(dot)
                }
            }
        }

        scene.rootNode.addChildNode(flooring)
    }
    
    public var scene: SCNScene {
        get {
            let scene = SCNScene()
            // create and add a camera to the scene
            let cameraNode = SCNNode()
            cameraNode.name = "camera"
            cameraNode.camera = SCNCamera()
            scene.rootNode.addChildNode(cameraNode)
            
            // place the camera
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
            cameraNode.simdLook(at: simd_float3(x: 0, y: 5, z: 0))
            
            // set up debug/sizing flooring
            addDebugFlooring(scene)
            
            var currentState = GrowthState(node: scene.rootNode)
            var stateStack: [GrowthState] = []

            for module in lsystem.state {
                // process the 'module.render3D'
                let cmd = module.render3D
                switch cmd {
                case let .pitch(direction, angle):
                    let directionAngleInRadians: Float
                    switch direction {
                    case .down:
                        // negative values pitch nose down
                        directionAngleInRadians = -1.0 * degreesToRadians(angle)
                    case .up:
                        // positive values pitch nose up
                        directionAngleInRadians = degreesToRadians(angle)
                    }
                    let yawTransform = rotationAroundZAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(yawTransform)
                    
                    print("Pitch (rotate around +X Axis) by \(angle)° -> \(String(describing: currentState.transform))")

                case let .roll(direction, angle):
                    let directionAngleInRadians: Float
                    switch direction {
                    case .right:
                        // negative values roll to the right
                        directionAngleInRadians = -1.0 * degreesToRadians(angle)
                    case .left:
                        // positive values roll to the left
                        directionAngleInRadians = degreesToRadians(angle)
                    }
                    let yawTransform = rotationAroundZAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(yawTransform)
                    
                    print("Roll (rotate around +Z Axis) by \(angle)° -> \(String(describing: currentState.transform))")

                case let .yaw(direction, angle):
                    let directionAngleInRadians: Float
                    switch direction {
                    case .right:
                        // negative values turn to the right
                        directionAngleInRadians = -1.0 * degreesToRadians(angle)
                    case .left:
                        // positive values turn to the left
                        directionAngleInRadians = degreesToRadians(angle)
                    }
                    let yawTransform = rotationAroundYAxisTransform(angle: directionAngleInRadians)
                    currentState = currentState.applyingTransform(yawTransform)
                    
                    print("Yaw (rotate around +Y Axis) by \(angle)° -> \(String(describing: currentState.transform))")

                case .levelOut:
                    print("Leveling out")
                    // Since I'm clearly not getting how to reverse Euler angles into the
                    // correct transforms, I'm using the capability embedded within SCNNode
                    // to update the current transform so that the Euler angles are leveled
                    // out. This leaves the yaw (rotation around the Y axis) at whatever state
                    // it was already at.
                    let temp = SCNNode()
                    temp.simdTransform = currentState.transform
                    
                    print("transform:")
                    print(temp.simdTransform.prettyPrintString())
                    print("euler angles pitch: \(degrees(radians: temp.simdEulerAngles.x))° yaw: \(degrees(radians: temp.simdEulerAngles.y))° roll: \(degrees(radians: temp.simdEulerAngles.z))°")
//                    temp.simdEulerAngles = simd_float3(x: 0, y: temp.simdEulerAngles.y, z: 0)
//                    currentState.transform = temp.simdTransform
                    print("  -> \(String(describing: currentState.transform))")
                    
                    // NOTE: this isn't working as @V was described in the original literature.
                    // It's intended to rotate the local frame such that things branch out horizontally,
                    // but instead I've changed the whole frame of reference so that it's "growing up" next,
                    // rather than maintaining it's previous heading.
                    // Everything done previously with transforms was entirely from a world frame of reference.

                case let .move(distance):
                    let moveTransform = translationTransform(x: 0, y: Float(distance), z: 0)
                    currentState = currentState.applyingTransform(moveTransform)
                    
                    print("Moving +y by \(distance) -> \(String(describing: currentState.transform))")
                    
                case let .cylinder(length, radius, colorRep):
                    let node = SCNNode(geometry: SCNCylinder(radius: radius, height: length))
                    if let colorRep = colorRep {
                        node.geometry?.materials = [colorRep.material]
                    }
                    
                    // Nudge the cylinder "up" so that its bottom is at the "origin" of the transform.
                    let nudgeOriginTransform = translationTransform(x: 0, y: Float(length/2.0), z: 0)
                    print(" - calc nudgeTransform: \(nudgeOriginTransform)")
                    node.simdTransform = matrix_multiply(currentState.transform, nudgeOriginTransform)
                    
                    scene.rootNode.addChildNode(node)
                    currentState.nodeRef = node

                    // Move the origin of the where to put the next object at the "end" of this node.
                    let moveStateTransform = translationTransform(x: 0, y: Float(length), z: 0)
                    currentState = currentState.applyingTransform(moveStateTransform)

                    print("Added cylinder (r=\(radius)) by \(length) at \(String(describing: node.simdTransform))")
                    print("Moving +y by \(length) -> \(String(describing: currentState.transform))")

                case let .cone(length, topRadius, bottomRadius, colorRep):
                    let node = SCNNode(geometry: SCNCone(topRadius: topRadius, bottomRadius: bottomRadius, height: length))
                    if let colorRep = colorRep {
                        node.geometry?.materials = [colorRep.material]
                    }

                    // Nudge the cylinder "up" so that its bottom is at the "origin" of the transform.
                    let nudgeOriginTransform = translationTransform(x: 0, y: Float(length/2.0), z: 0)
                    node.simdTransform = matrix_multiply(currentState.transform, nudgeOriginTransform)

                    scene.rootNode.addChildNode(node)
                    currentState.nodeRef = node

                    // Move the origin of the where to put the next object at the "end" of this node.
                    let moveStateTransform = translationTransform(x: 0, y: Float(length), z: 0)
                    currentState = currentState.applyingTransform(moveStateTransform)
                    
                    print("Added cone (tr=\(topRadius), br=\(bottomRadius) by \(length) at \(String(describing: node.simdTransform))")
                    print("Moving +y by \(length) -> \(String(describing: currentState.transform))")

                case let .sphere(radius, colorRep):
                    let node = SCNNode(geometry: SCNSphere(radius: radius))
                    if let colorRep = colorRep {
                        node.geometry?.materials = [colorRep.material]
                    }
                    node.simdTransform = currentState.transform

                    scene.rootNode.addChildNode(node)
                    currentState.nodeRef = node

                    // Move the origin of the where to put the next object at the "end" of this node.
                    let moveStateTransform = translationTransform(x: 0, y: Float(radius), z: 0)
                    currentState = currentState.applyingTransform(moveStateTransform)
                    
                    print("Added sphere (r=\(radius)) at \(String(describing: node.simdTransform))")
                    print("Moving +y by \(radius) -> \(String(describing: currentState.transform))")

                case .saveState:
                    stateStack.append(currentState)
                    print("Saving state: \(String(describing: currentState.transform))")
                    
                case .restoreState:
                    currentState = stateStack.removeLast()
                    print("Restored state to: \(String(describing: currentState.transform))")
                    
                case .ignore:
                    break
                    
                }
            }
            
            return scene
        }
    }
    
    // MARK: - Internal
    
    func degreesToRadians(_ value: Double) -> Float {
        return Float(value * .pi / 180.0)
    }
    
    func degrees(radians: Float) -> Float {
        return radians / .pi * 180.0
    }
}

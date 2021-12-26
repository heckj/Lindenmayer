//
//  LSystem3DView.swift
//  X5336
//
//  Created by Joseph Heck on 12/18/21.
//

import SwiftUI
import SceneKit
import Lindenmayer

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

func degreesToRadians(_ value: Double) -> Float {
    return Float(value * .pi / 180.0)
}

func degrees(radians: Float) -> Float {
    return radians / .pi * 180.0
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
                let dot = SCNNode(geometry: dot3D)
                dot.simdPosition = simd_float3(x: Float(i), y: Float(j), z: 0)
                flooring.addChildNode(dot)
            }
        }
    }

    scene.rootNode.addChildNode(flooring)
}

func addExampleNode(_ scene: SCNScene) {
    // .cylinder cmd from L-system generation
    let radius:CGFloat = 1
    let length:CGFloat = 5
    let node = SCNNode(geometry: SCNCone(topRadius: 0.25, bottomRadius: radius, height: length))
    //SCNCylinder(radius: radius, height: length))
    node.geometry?.materials = [material(red: 1.0, green: 0, blue: 0, alpha: 1)]
    
    let fin = SCNNode(geometry: SCNBox(width: 0.1, height: 4, length: 1, chamferRadius: 0))
    fin.geometry?.materials = [material(red: 1.0, green: 0, blue: 0, alpha: 1)]
    fin.simdPosition = simd_float3(x: 0, y: 0, z: 0.5)
    node.addChildNode(fin)
    
    // Nudge the cylinder "up" so that its bottom is at the "origin" of the transform.
    let nudgeOriginTransform = translationTransform(x: 0, y: Float(length/2.0), z: 0)
    print(" - calc nudgeTransform: \(nudgeOriginTransform)")
    node.simdTransform = matrix_multiply(matrix_identity_float4x4, nudgeOriginTransform)
    node.name = "example"
    scene.rootNode.addChildNode(node)
    print("Added cylinder (r=\(radius)) by \(length):")
    print(node.simdTransform.prettyPrintString("  "))

    let exampleTransform = matrix_float4x4([
        simd_float4(-0.5213338, -0.7071067, -0.47771442, 0.0),
        simd_float4(-0.5213338, 0.7071067, -0.47771442, 0.0),
        simd_float4(0.6755902, 0.0, -0.7372773, 0.0),
        simd_float4(0.6755902, 0.0, -0.7372773, 0.0),
        // euler angles pitch: -147.05904° yaw: 28.536234° roll: -126.40051°
    ])
    node.simdTransform = node.simdTransform * exampleTransform

    print("After applying transform")
    print(node.simdTransform.prettyPrintString("  "))
    scene.rootNode.addChildNode(node)
}

public struct NodeInfoView: View {
    let node: SCNNode?
    func positionString() -> String {
        var string = "position: "
        if let node = node {
            string += "[\(node.simdPosition.x), \(node.simdPosition.y), \(node.simdPosition.z)]"
        }
        return string
    }

    func anglesString() -> String {
        var string = "euler angles:"
        if let node = node {
            string += "\npitch: \(degrees(radians: node.simdEulerAngles.x))° (\(node.simdEulerAngles.x) rad)"
            string += "\nyaw: \(degrees(radians: node.simdEulerAngles.y))° (\(node.simdEulerAngles.y) rad)"
            string += "\nroll: \(degrees(radians: node.simdEulerAngles.z))° (\(node.simdEulerAngles.z) rad)"
        }
        return string
    }

    public var body: some View {
        VStack {
            Text("Node: \(node?.name ?? "No example node") ")
            if node != nil {
                Text(positionString())
                Text(anglesString())
                Text("")
                Text((node?.simdTransform.prettyPrintString())!)
            }
        }
    }
        
    public init(node: SCNNode?) {
        self.node = node
    }
}


public struct NodeAdjustmentView: View {
    let node: SCNNode?
    @State private var moreValue: Float = 0
    @State private var textField: String = ""
    @State private var anglesString: String = ""

    public var body: some View {
        VStack {
            TextField("Moar: ", text: $textField)
            HStack {
                Button("add pitch") {
                    if (!textField.isEmpty) {
                        if let value = Float(textField) {
                            moreValue = value
                        }
                    }
                    if let node = node {
                        node.simdTransform = node.simdTransform * rotationAroundXAxisTransform(angle: moreValue)
                        var string = "euler angles:"
                        string += "\npitch: \(degrees(radians: node.simdEulerAngles.x))° (\(node.simdEulerAngles.x) rad)"
                        string += "\nyaw: \(degrees(radians: node.simdEulerAngles.y))° (\(node.simdEulerAngles.y) rad)"
                        string += "\nroll: \(degrees(radians: node.simdEulerAngles.z))° (\(node.simdEulerAngles.z) rad)"
                        anglesString = string

                    }
                    
                }
                Button("add yaw") {
                    if (!textField.isEmpty) {
                        if let value = Float(textField) {
                            moreValue = value
                        }
                    }
                    if let node = node {
                        node.simdTransform = node.simdTransform * rotationAroundYAxisTransform(angle: moreValue)
                        var string = "euler angles:"
                        string += "\npitch: \(degrees(radians: node.simdEulerAngles.x))° (\(node.simdEulerAngles.x) rad)"
                        string += "\nyaw: \(degrees(radians: node.simdEulerAngles.y))° (\(node.simdEulerAngles.y) rad)"
                        string += "\nroll: \(degrees(radians: node.simdEulerAngles.z))° (\(node.simdEulerAngles.z) rad)"
                        anglesString = string

                    }

                }
                Button("add roll") {
                    if (!textField.isEmpty) {
                        if let value = Float(textField) {
                            moreValue = value
                        }
                    }
                    if let node = node {
                        node.simdTransform = node.simdTransform * rotationAroundZAxisTransform(angle: moreValue)
                    
                        var string = "euler angles:"
                        string += "\npitch: \(degrees(radians: node.simdEulerAngles.x))° (\(node.simdEulerAngles.x) rad)"
                        string += "\nyaw: \(degrees(radians: node.simdEulerAngles.y))° (\(node.simdEulerAngles.y) rad)"
                        string += "\nroll: \(degrees(radians: node.simdEulerAngles.z))° (\(node.simdEulerAngles.z) rad)"
                        anglesString = string
                    }
                }
            }
            Text("Added \(moreValue)")
            Text(anglesString)
        }
    }
        
    public init(node: SCNNode?) {
        self.node = node
    }
}
public struct Debug3DView: View {
    static func generateExampleScene() -> SCNScene {
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
        
        // add example node
        addExampleNode(scene)
        
        return scene
    }
    
    let scene: SCNScene
    
    public var body: some View {
        HStack {
            VStack {
                NodeInfoView(node: scene.rootNode.childNode(withName: "example", recursively: true))
                NodeAdjustmentView(node: scene.rootNode.childNode(withName: "example", recursively: true))
            }
            SceneView(
                scene: scene,
                options: [.allowsCameraControl, .autoenablesDefaultLighting]
            )
        }
    }
    
    public init() {
        scene = Debug3DView.generateExampleScene()
    }

}

struct Debug3DView_Previews: PreviewProvider {
    static var previews: some View {
        Debug3DView()
    }
}

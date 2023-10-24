//
//  RollToVerticalTestView.swift
//
//
//  Created by Joseph Heck on 1/18/22.
//

import Lindenmayer
import SceneKit
import SceneKitDebugTools
import simd
import SwiftUI

public struct RollToVerticalTestView: View {
    let scene: SCNScene
    let pointSphere0: SCNNode
//    let pointSphereY: SCNNode
    let pointSphereZ: SCNNode
    let cameraNode: SCNNode
    var selectedNode: SCNNode?
    @State var calculated_angle: Float = 0.0
    @State var rotated_vector: simd_float3 = .init(0, 0, 0)
    @State var aString: String = ""

    static var transform_119 = simd_float4x4(
        simd_float4(-1.1513867, -0.12829041, 2.2153668, 0.0),
        simd_float4(2.173691, 0.43699712, 1.155033, 0.0),
        simd_float4(-0.44651538, 2.458165, -0.08971556, 0.0),
        simd_float4(4.4409075, 13.833499, 8.220964, 1.0)
    )

    static func generatePointSphere() -> SCNNode {
        let sphereGeometry = SCNSphere(radius: 0.03)
        sphereGeometry.segmentCount = 12
        let m = SCNMaterial()
        m.diffuse.contents = CGColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        sphereGeometry.materials = [m]
        return SCNNode(geometry: sphereGeometry)
    }

    @discardableResult
    static func pointSphereAtLocation(scene: SCNScene, _ x: Float, _ y: Float, _ z: Float) -> SCNNode {
        let pointSphere = RollToVerticalTestView.generatePointSphere()
        pointSphere.simdPosition = simd_float3(x, y, z)
        pointSphere.simdTransform = matrix_multiply(pointSphere.simdTransform, RollToVerticalTestView.transform_119)
        scene.rootNode.addChildNode(pointSphere)
        return pointSphere
    }

    static func generateLineSegment() -> SCNNode {
        let linecyl = SCNCylinder(radius: 0.01, height: 1.0)
        linecyl.radialSegmentCount = 3
        let m = SCNMaterial()
        m.diffuse.contents = CGColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        linecyl.materials = [m]
        return SCNNode(geometry: linecyl)
    }

    static func generateExampleScene() -> (SCNScene, SCNNode) {
        let scene = SCNScene()
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)

        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 4, z: 5)
        cameraNode.simdLook(at: simd_float3(x: 0, y: 0, z: 0))

        // set up debug/sizing flooring
        scene.rootNode.addChildNode(DebugNodes.debugFlooring())

        return (scene, cameraNode)
    }

    func calculateThings() {
        if let selectedNode = selectedNode {
            // regenerate calculated angle
            let rotation_from_heading = selectedNode.simdTransform.rotationTransform
            let original_heading_up_vector = simd_float3(x: 0, y: 0, z: 1)
            rotated_vector = simd_normalize(matrix_multiply(original_heading_up_vector, rotation_from_heading))

            // Then we calculate the between the "rotated up" vector and world-space UP (+Y in SceneKit)
            // to get the amount of angle we should roll. We're explicitly working with normalized vectors
            // here to make the calculation of cos-1( a • b / |a| * |b| ) easier. With unit vectors, this
            // collapses to acos(a • b).
            calculated_angle = acos(simd_dot(rotated_vector, simd_normalize(simd_float3(0, 1, 0))))
        }
    }

    public var body: some View {
        VStack {
            HStack {
                Text("Angle: \(calculated_angle) ( \(SimpleAngle(radians: Double(calculated_angle)).degrees)° )")
                TextField("roll amount", text: $aString)
                Button {
                    if let selectedNode = selectedNode {
                        if let angle = Double(aString) {
                            print("before rotation")
                            print("\(pointSphereZ.simdTransform.prettyPrintString())")
                            let rotationTransform = SceneKitRenderer.rotationAroundYAxisTransform(angle: SimpleAngle(radians: angle))
                            selectedNode.simdTransform = matrix_multiply(selectedNode.simdTransform, rotationTransform)
                            pointSphere0.simdTransform = matrix_multiply(pointSphere0.simdTransform, rotationTransform)

                            pointSphereZ.simdTransform = matrix_multiply(pointSphereZ.simdTransform, rotationTransform)
//                            pointSphereY.simdTransform = matrix_multiply(pointSphereY.simdTransform, rotationTransform)
                            print("after rotation")
                            print("\(pointSphereZ.simdTransform.prettyPrintString())")
                        }
                    }
                    calculateThings()
                } label: {
                    Text("Apply Roll")
                }
            }
//            Text("world up vector: \(String(describing: selectedNode?.worldUp))")
//            Text("world right vector: \(String(describing: selectedNode?.worldRight))")
//            Text("world front vector: \(String(describing: selectedNode?.worldFront))")
            Text("rotated vector \(String(describing: rotated_vector))")
            DebugSceneView(scene: scene, node: selectedNode)
        }
        .onAppear {
            calculateThings()
        }
    }

    public init() {
        (scene, cameraNode) = RollToVerticalTestView.generateExampleScene()
        scene.rootNode.addChildNode(DebugNodes.axis(length: 4, labels: true))
        let heading = DebugNodes.headingIndicator()
        scene.rootNode.addChildNode(heading)
        heading.simdTransform = RollToVerticalTestView.transform_119
        selectedNode = heading
        cameraNode.simdLook(at: heading.simdPosition)

        let zLine = RollToVerticalTestView.generateLineSegment()
        zLine.simdPosition = simd_float3(0, 0, 0.5)
//        let zLineNudge = translationTransform(x: 0, y: 0, z: 0.5)
//        zLine.simdTransform = matrix_multiply(zLine.simdTransform, zLineNudge)
        let zLineRotation = SceneKitRenderer.rotationAroundXAxisTransform(angle: SimpleAngle(degrees: 90))
        zLine.simdTransform = matrix_multiply(zLine.simdTransform, zLineRotation)
//        zLine.simdTransform = matrix_multiply(zLine.simdTransform, RollToVerticalTestView.transform_119)
        scene.rootNode.addChildNode(zLine)

        pointSphere0 = RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0, 0.25)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0, 0.5)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0, 0.75)
        pointSphereZ = RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0, 1)

        // X axis points - rotated into place
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0.2, 0, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0.4, 0, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0.6, 0, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0.8, 0, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 1.0, 0, 0)

        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0.1, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0.2, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0.3, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0.4, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0.5, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0.6, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0.7, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0.8, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 0.9, 0)
        RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 1.0, 0)
//        pointSphereY = RollToVerticalTestView.pointSphereAtLocation(scene: scene, 0, 1, 0)

        scene.rootNode.addChildNode(pointSphere0)
        scene.rootNode.addChildNode(pointSphereZ)
//        scene.rootNode.addChildNode(pointSphereY)
    }
}

struct RollToVerticalTestView_Previews: PreviewProvider {
    static var previews: some View {
        RollToVerticalTestView()
    }
}

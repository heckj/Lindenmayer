//
//  SystemControlView.swift
//  X5336
//
//  Created by Joseph Heck on 1/8/22.
//

import Lindenmayer
import SceneKit
import SceneKitDebugTools
import SwiftUI

public struct LSystemControlView: View {
    var model: LSystemModel
    @State private var iterations = 1
    @State private var stateIndex = 0
    @State private var autoLookAt = true
    @State private var currentNode: SCNNode? = nil
    
    func lookAtNode(selectedNode: SCNNode, cameraNode: SCNNode, highlight: Bool) {
        SCNTransaction.begin()
        print("Looking at node \(selectedNode)")
        SCNTransaction.animationDuration = 0.2
        cameraNode.simdLook(at: selectedNode.simdWorldPosition)
        SCNTransaction.commit()
        if highlight {
            if let material = selectedNode.geometry?.firstMaterial {
                SCNTransaction.begin()
                // on completion, remove the highlight
                SCNTransaction.completionBlock = {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.5
#if os(OSX)
                    material.emission.contents = NSColor.black
#elseif os(iOS)
                    material.emission.contents = UIColor.black
#endif
                    SCNTransaction.commit()
                }
                // and when we start, highlight with red
                SCNTransaction.animationDuration = 0.5
#if os(OSX)
                material.emission.contents = NSColor.red
#elseif os(iOS)
                material.emission.contents = UIColor.red
#endif
                SCNTransaction.commit()
            } // if let material
        } // if highlight
    }
    
    public var body: some View {
        VStack {
            HStack {
                Stepper {
                    Text("Iterations: \(iterations)")
                } onIncrement: {
                    if iterations < 15 {
                        iterations += 1
                        model.iterations = iterations
                        stateIndex = 0
                        currentNode = nil
                    }
                } onDecrement: {
                    if iterations > 1 {
                        iterations -= 1
                        model.iterations = iterations
                        stateIndex = 0
                        currentNode = nil
                    }
                }
                Toggle(isOn: $autoLookAt) {
                    Text("Look At")
                }
                Button("camera up") {
                    if let cameraNode = model.scene.rootNode.childNode(withName: "camera", recursively: true) {
                        let moveUp = translationTransform(x: 0, y: 2, z: 0)
                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = 0.2
                        cameraNode.simdTransform = matrix_multiply(cameraNode.simdTransform, moveUp)
                        SCNTransaction.commit()
                    }
                }
                Button("camera down") {
                    if let cameraNode = model.scene.rootNode.childNode(withName: "camera", recursively: true) {
                        let moveDown = translationTransform(x: 0, y: -2, z: 0)
                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = 0.2
                        cameraNode.simdTransform = matrix_multiply(cameraNode.simdTransform, moveDown)
                        SCNTransaction.commit()
                    }
                }
                Spacer()
            }
            
            StateSelectorView(system: model.system, position: $stateIndex)
                .onChange(of: stateIndex) { newValue in
                    if autoLookAt {
                        print(newValue)
                        let lookupName = "n\(newValue)"
                        if let cameraNode = model.scene.rootNode.childNode(withName: "camera", recursively: true) {
                            if let headingIndicator = model.scene.rootNode.childNode(withName: "headingIndicator", recursively: true) {
                                if let selectedNode = model.scene.rootNode.childNode(withName: lookupName, recursively: true) {
                                    currentNode = selectedNode
                                    headingIndicator.opacity = 0
                                    headingIndicator.simdTransform = selectedNode.simdTransform
                                    lookAtNode(selectedNode: selectedNode, cameraNode: cameraNode, highlight: true)
                                } else {
                                    currentNode = nil
                                    let currentStateTransform = model.transformSequence[newValue]
                                    // print("Corresponding transform: \(currentStateTransform.prettyPrintString("  "))")
                                    SCNTransaction.begin()
                                    SCNTransaction.animationDuration = 0.2
                                    headingIndicator.opacity = 1
                                    let bigger = scalingTransform(x: 2.5, y: 2.5, z: 2.5)
                                    headingIndicator.simdTransform = matrix_multiply(currentStateTransform, bigger)
                                    lookAtNode(selectedNode: headingIndicator, cameraNode: cameraNode, highlight: false)
                                    SCNTransaction.commit()
                                    currentNode = headingIndicator
                                } // if let selectedNode (exists)/else
                            } // if let headingIndicator
                        } // if let cameraNode (should
                    } // if (autoLookAt)
                } // onChange
            
            DebugSceneView(scene: model.scene, node: currentNode)
        }
    }
}

struct LSystemControlView_Previews: PreviewProvider {
    static var previews: some View {
        LSystemControlView(model: LSystemModel())
    }
}

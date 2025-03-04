//
//  LSystem3DControlView.swift
//
//
//  Created by Joseph Heck on 1/8/22.
//

public import Lindenmayer
import SceneKit
import SceneKitDebugTools
import SwiftUI

/// A view that displays a 3D representation of an Lsystem, allowing the person viewing it to control the 3D visualization.
///
/// The controls within the view allow you to select the number of iterations for the L-system.
/// Within the resulting L-system's state, you can select each state of the L-system, which points the 3D camera at that node and highlights it.
/// The view is intended to provide a visualization with sufficient detail about the state and its representation for debugging how an L-system is represented in 3D.
@MainActor
public struct LSystem3DControlView: View {
    var model: LSystem3DModel
    @State private var iterations = 1
    @State private var stateIndex = 0
    @State private var autoLookAt = true
    @State private var currentNode: SCNNode? = nil

    /// Points the node for the camera towards another node you identify, and optionally highlights it temporarily.
    /// - Parameters:
    ///   - selectedNode: The node to look at.
    ///   - cameraNode: The camera node to manipulate.
    ///   - highlight: A Boolean value that indicates whether to highlight the node selected.
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

    /// Updates the SceneKit scene to point the camera to the node with the selected state, or present a directional indicator from the state if no node is visible.
    ///
    /// This method has the scenekit side effects when `autoLookAt` is `true`.
    /// - Parameter index: The index of the L-system state to inspect.
    func autolook(at index: Int) {
        precondition(index < model.transformSequence.count)
        if autoLookAt {
            let lookupName = "n\(index)"
            if let cameraNode = model.scene.rootNode.childNode(withName: "camera", recursively: true) {
                if let headingIndicator = model.scene.rootNode.childNode(withName: "headingIndicator", recursively: true) {
                    if let selectedNode = model.scene.rootNode.childNode(withName: lookupName, recursively: true) {
                        currentNode = selectedNode
                        headingIndicator.opacity = 0
                        headingIndicator.simdTransform = selectedNode.simdTransform
                        lookAtNode(selectedNode: selectedNode, cameraNode: cameraNode, highlight: true)
                    } else {
                        currentNode = nil
                        let currentStateTransform = model.transformSequence[index]
                        // print("Corresponding transform: \(currentStateTransform.prettyPrintString("  "))")
                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = 0.2
                        headingIndicator.opacity = 1
                        let bigger = SceneKitRenderer.scalingTransform(x: 2.5, y: 2.5, z: 2.5)
                        headingIndicator.simdTransform = matrix_multiply(currentStateTransform, bigger)
                        lookAtNode(selectedNode: headingIndicator, cameraNode: cameraNode, highlight: false)
                        SCNTransaction.commit()
                        currentNode = headingIndicator
                    } // if let selectedNode (exists)/else
                } // if let headingIndicator
            } // if let cameraNode (should
        } // if (autoLookAt)
    }

    public var body: some View {
        VStack {
            HStack {
                #if os(tvOS) || os(watchOS)
                    VStack {
                        Button {
                            if iterations < 15 {
                                iterations += 1
                                model.iterations = iterations
                                stateIndex = 0
                                currentNode = nil
                                autolook(at: stateIndex)
                            }
                        } label: {
                            Image(systemName: "plus.square")
                        }
                        Button {
                            if iterations > 1 {
                                iterations -= 1
                                model.iterations = iterations
                                stateIndex = 0
                                currentNode = nil
                                autolook(at: stateIndex)
                            }
                        } label: {
                            Image(systemName: "minus.square")
                        }
                    }.padding()
                #else
                    Stepper {
                        Text("Iterations: \(iterations)")
                    } onIncrement: {
                        if iterations < 15 {
                            iterations += 1
                            model.iterations = iterations
                            stateIndex = 0
                            currentNode = nil
                            autolook(at: stateIndex)
                        }
                    } onDecrement: {
                        if iterations > 1 {
                            iterations -= 1
                            model.iterations = iterations
                            stateIndex = 0
                            currentNode = nil
                            autolook(at: stateIndex)
                        }
                    }
                #endif
                Toggle(isOn: $autoLookAt) {
                    Text("Look At")
                }
                Button("camera up") {
                    if let cameraNode = model.scene.rootNode.childNode(withName: "camera", recursively: true) {
                        let moveUp = SceneKitRenderer.translationTransform(x: 0, y: 2, z: 0)
                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = 0.2
                        cameraNode.simdTransform = matrix_multiply(cameraNode.simdTransform, moveUp)
                        SCNTransaction.commit()
                    }
                }
                Button("camera down") {
                    if let cameraNode = model.scene.rootNode.childNode(withName: "camera", recursively: true) {
                        let moveDown = SceneKitRenderer.translationTransform(x: 0, y: -2, z: 0)
                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = 0.2
                        cameraNode.simdTransform = matrix_multiply(cameraNode.simdTransform, moveDown)
                        SCNTransaction.commit()
                    }
                }
                Spacer()
            }

            StateSelectorView(system: model.system, position: $stateIndex, withDetailView: true)
                .onChange(of: stateIndex) { newValue in
                    autolook(at: newValue)
                }

            DebugSceneView(scene: model.scene, node: currentNode)
        }
    }

    public init(model: LSystem3DModel) {
        self.model = model
    }
}

struct LSystemControlView_Previews: PreviewProvider {
    static var previews: some View {
        LSystem3DControlView(model: LSystem3DModel())
    }
}

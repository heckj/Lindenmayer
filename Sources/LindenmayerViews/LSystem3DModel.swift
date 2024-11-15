//
//  LSystem3DModel.swift
//
//
//  Created by Joseph Heck on 1/8/22.
//

@preconcurrency public import Combine
import Foundation
public import Lindenmayer
public import SceneKit
import SceneKitDebugTools
import SwiftUI
/// A class that provides an observable model around a base L-system.
///
/// The module manages the number of evolutions of an L-system, and provides updated 3D SceneKit scenes as you change the number of evolutions.
/// The model emits `ObservableObject` change notifications when the number of iterations is changed.
@MainActor
public class LSystem3DModel: ObservableObject {
    @Published public var system: any LindenmayerSystem
    let renderer = SceneKitRenderer()
    let _baseSystem = Examples3D.sympodialTree

    var _scene: SCNScene
    var _transformSequence: [matrix_float4x4]

    nonisolated public let objectWillChange: ObservableObjectPublisher

    public var scene: SCNScene {
        _scene
    }

    public var transformSequence: [matrix_float4x4] {
        _transformSequence
    }

    func evolveBy(iterations: Int) async {
        system = await _baseSystem.evolved(iterations: iterations)
        _iterations = iterations
        objectWillChange.send()
        (_scene, _transformSequence) = renderer.generateScene(lsystem: system)
        let headingIndicator = DebugNodes.headingIndicator()
        headingIndicator.opacity = 0
        let bigger = SceneKitRenderer.scalingTransform(x: 2.5, y: 2.5, z: 2.5)
        headingIndicator.simdTransform = matrix_multiply(headingIndicator.simdTransform, bigger)
        _scene.rootNode.addChildNode(headingIndicator)
    }

    var _iterations = 1
    public var iterations: Int {
        get {
            _iterations
        }
        set {
            precondition(newValue > 0 && newValue < 20)
            _iterations = newValue
            Task {
                await self.evolveBy(iterations: _iterations)
            }
        }
    }

    /// Creates a new L-System model with the L-System you provide.
    /// - Parameter system: The L-System to expose and control with the model.
    public init(system: any LindenmayerSystem) {
        self.system = system
        objectWillChange = ObservableObjectPublisher()
        (_scene, _transformSequence) = renderer.generateScene(lsystem: _baseSystem)
        let headingIndicator = DebugNodes.headingIndicator()
        _scene.rootNode.addChildNode(headingIndicator)
    }

    /// Creates a default L-System model using the sympodial tree example.
    public init() {
        system = _baseSystem
        objectWillChange = ObservableObjectPublisher()
        (_scene, _transformSequence) = renderer.generateScene(lsystem: _baseSystem)
        let headingIndicator = DebugNodes.headingIndicator()
        _scene.rootNode.addChildNode(headingIndicator)
    }
}

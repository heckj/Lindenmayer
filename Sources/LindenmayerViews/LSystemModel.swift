//
//  LSystemModels.swift
//  X5336
//
//  Created by Joseph Heck on 1/8/22.
//

import Combine
import Foundation
import Lindenmayer
import SceneKit
import SceneKitDebugTools
import SwiftUI

public class LSystemModel: ObservableObject {
    @Published public var system: LSystem
    let renderer = SceneKitRenderer()
    let _baseSystem = Detailed3DExamples.sympodialTree

    var _scene: SCNScene
    var _transformSequence: [matrix_float4x4]

    public var objectWillChange = Combine.ObservableObjectPublisher()

    public var scene: SCNScene {
        _scene
    }

    public var transformSequence: [matrix_float4x4] {
        _transformSequence
    }

    var _iterations = 1
    public var iterations: Int {
        get {
            _iterations
        }
        set {
            precondition(newValue > 0 && newValue < 20)
            _iterations = newValue
            objectWillChange.send()
            system = _baseSystem.evolved(iterations: _iterations)
            (_scene, _transformSequence) = renderer.generateScene(lsystem: system)
            let headingIndicator = headingIndicator()
            headingIndicator.opacity = 0
            let bigger = scalingTransform(x: 2.5, y: 2.5, z: 2.5)
            headingIndicator.simdTransform = matrix_multiply(headingIndicator.simdTransform, bigger)
            _scene.rootNode.addChildNode(headingIndicator)
        }
    }

    public init() {
        system = _baseSystem
        (_scene, _transformSequence) = renderer.generateScene(lsystem: _baseSystem)
        let headingIndicator = headingIndicator()
        _scene.rootNode.addChildNode(headingIndicator)
    }
}

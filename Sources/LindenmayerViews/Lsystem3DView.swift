//
//  LSystem3DView.swift
//  X5336
//
//  Created by Joseph Heck on 12/18/21.
//

import Lindenmayer
import SceneKit
import SwiftUI

public struct Lsystem3DView: View {
    let system: LSystemProtocol
    func generateScene() -> SCNScene {
        let x = SceneKitRenderer(system)
        return x.scene
    }

    public var body: some View {
        VStack {
            LSystemMetrics(system: system)
            /* Declaration:
             /// Creates an instance with the given `scene`
             ///
             /// - Parameters:
             ///     - scene: SCNScene to present
             ///     - pointOfView: The point of view to use to render the scene.
             ///     - options: Various options (see above) to configure the receiver.
             ///     - preferredFramesPerSecond: sets fps to define the desired rate for current SceneView.
             ///     Actual rate maybe limited by hardware or other software
             ///     - antialiasingMode: desired level of antialiasing. Defaults to 4X.
             ///     - delegate: The delegate of the receiver
             ///     - technique: Specifies a custom post process
             init(scene: SCNScene? = nil, pointOfView: SCNNode? = nil, options: SceneView.Options = [], preferredFramesPerSecond: Int = 60, antialiasingMode: SCNAntialiasingMode = .multisampling4X, delegate: SCNSceneRendererDelegate? = nil, technique: SCNTechnique? = nil)
             */
            SceneView(
                scene: generateScene(),
                // pointOfView: generateScene().rootNode.childNode(withName: "camera", recursively: false),
                options: [.allowsCameraControl, .autoenablesDefaultLighting]
            )
            // Options available I didn't use:
            /// Specifies whether the receiver should jitter the rendered scene to reduce aliasing artifacts.
            /// The default is false.
            // - static let jitteringEnabled: SceneView.Options

            /// Toggles whether the view renders continuously at the desired frame rate.
            /// If set to false the view will redraw only when necessary.
            /// Defaults to false.
            // - static let rendersContinuously: SceneView.Options

            /// Specifies whether the receiver should reduce aliasing artifacts in real time based on temporal coherency.
            /// The default is false.
            // - static let temporalAntialiasingEnabled: SceneView.Options

            // These don't appear to be exposed into SwiftUI view land...
            //    scnView.showsStatistics = true
            //    scnView.backgroundColor = .white
        }
    }

    public init(system: LSystemProtocol) {
        self.system = system
    }
}

struct Lsystem3DView_Previews: PreviewProvider {
    static var previews: some View {
        Lsystem3DView(system: Lindenmayer.Examples3D.algae3D.evolved(iterations: 3))
    }
}

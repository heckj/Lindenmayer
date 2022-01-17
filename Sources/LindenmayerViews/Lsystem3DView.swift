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
    let system: LSystem
    func generateScene() -> SCNScene {
        let x = SceneKitRenderer()
        return x.generateScene(lsystem: system).0
    }

    public var body: some View {
        VStack {
            LSystemMetrics(system: system)
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

    public init(system: LSystem) {
        self.system = system
    }
}

struct Lsystem3DView_Previews: PreviewProvider {
    static var previews: some View {
        Lsystem3DView(system: Examples3D.algae3D.lsystem.evolved(iterations: 3))
    }
}

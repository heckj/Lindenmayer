//
//  Monopodial4Examples.swift
//
//
//  Created by Joseph Heck on 1/17/22.
//

import Lindenmayer
import SceneKit
import SwiftUI

/// A view that presents the 4 SceneKit scenes that include example trees with a monopodial structure built in to Lindenmayer.
///
/// The set of trees match the examples of figure 2.6 in [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf) on page 56.
public struct Monopodial4Examples: View {
    let system1: LindenmayerSystem
    let system2: LindenmayerSystem
    let system3: LindenmayerSystem
    let system4: LindenmayerSystem
    let renderer = SceneKitRenderer()
    public var body: some View {
        VStack {
            HStack {
                Lsystem3DView(system: system1)
                Lsystem3DView(system: system2)
            }
            HStack {
                Lsystem3DView(system: system3)
                Lsystem3DView(system: system4)
            }
        }
    }

    public init() {
        system1 = Examples3D.monopodialTree
            .setParameters(params: Examples3D.figure2_6A)
            .evolved(iterations: 10)
        system2 = Examples3D.monopodialTree
            .setParameters(params: Examples3D.figure2_6B)
            .evolved(iterations: 10)
        system3 = Examples3D.monopodialTree
            .setParameters(params: Examples3D.figure2_6C)
            .evolved(iterations: 10)
        system4 = Examples3D.monopodialTree
            .setParameters(params: Examples3D.figure2_6D)
            .evolved(iterations: 10)
    }
}

struct Monopodial4Examples_Previews: PreviewProvider {
    static var previews: some View {
        Monopodial4Examples()
    }
}

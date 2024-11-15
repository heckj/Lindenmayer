//
//  Sympodial4Examples.swift
//
//
//  Created by Joseph Heck on 1/17/22.
//

import Lindenmayer
import SceneKit
public import SwiftUI

/// A view that presents the 4 SceneKit scenes that include example trees with a sympodial structure built in to Lindenmayer.
///
/// The set of trees match the example in figure 2.7 of [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf) on page 59.
public struct Sympodial4Examples: View {
    @State var system1: any LindenmayerSystem
    @State var system2: any LindenmayerSystem
    @State var system3: any LindenmayerSystem
    @State var system4: any LindenmayerSystem
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
        }.task {
            system1 = await system1.evolved(iterations: 10)
            system2 = await system2.evolved(iterations: 10)
            system3 = await system3.evolved(iterations: 10)
            system4 = await system4.evolved(iterations: 10)
        }
    }

    public init() {
        system1 = Examples3D.sympodialTree
            .setParameters(params: Examples3D.figure2_7A)
        system2 = Examples3D.sympodialTree
            .setParameters(params: Examples3D.figure2_7B)
        system3 = Examples3D.sympodialTree
            .setParameters(params: Examples3D.figure2_7C)
        system4 = Examples3D.sympodialTree
            .setParameters(params: Examples3D.figure2_7D)
    }
}

struct Sympodial4Examples_Previews: PreviewProvider {
    static var previews: some View {
        Sympodial4Examples()
    }
}

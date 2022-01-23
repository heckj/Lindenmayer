//
//  Sympodial4Examples.swift
//
//
//  Created by Joseph Heck on 1/17/22.
//

import Lindenmayer
import SceneKit
import SwiftUI

/// A view that presents the 4 SceneKit scenes that include example trees with a sympodial structure built in to Lindenmayer.
///
/// The set of trees match the example in figure 2.7 of [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf) on page 59.
public struct Sympodial4Examples: View {
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
        system1 = Detailed3DExamples.sympodialTree
            .setParameters(params: Detailed3DExamples.figure2_7A)
            .evolved(iterations: 10)
        system2 = Detailed3DExamples.sympodialTree
            .setParameters(params: Detailed3DExamples.figure2_7B)
            .evolved(iterations: 10)
        system3 = Detailed3DExamples.sympodialTree
            .setParameters(params: Detailed3DExamples.figure2_7C)
            .evolved(iterations: 10)
        system4 = Detailed3DExamples.sympodialTree
            .setParameters(params: Detailed3DExamples.figure2_7D)
            .evolved(iterations: 10)
    }
}

struct Sympodial4Examples_Previews: PreviewProvider {
    static var previews: some View {
        Sympodial4Examples()
    }
}

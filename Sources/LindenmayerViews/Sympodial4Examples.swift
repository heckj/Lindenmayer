//
//  Sympodial4Examples.swift
//
//
//  Created by Joseph Heck on 1/17/22.
//

import Lindenmayer
import SceneKit
import SwiftUI

public struct Sympodial4Examples: View {
    let system1: LSystem
    let system2: LSystem
    let system3: LSystem
    let system4: LSystem
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

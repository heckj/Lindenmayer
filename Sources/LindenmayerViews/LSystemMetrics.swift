//
//  LSystemMetrics.swift
//
//
//  Created by Joseph Heck on 12/16/21.
//

import Lindenmayer
import SwiftUI

/// A view that provides the size of the state of an L-system and a textual representation of that state.
public struct LSystemMetrics: View {
    let system: LSystem
    public var body: some View {
        VStack {
            Text("State size: \(system.state.count)")
            Text("\(String(describing: system.state))")
                .font(.caption)
                .lineLimit(3)
                .padding(.horizontal)
        }
    }

    public init(system: LSystem) {
        self.system = system
    }
}

struct LSystemMetrics_Previews: PreviewProvider {
    static var previews: some View {
        LSystemMetrics(system: Examples3D.monopodialTree.lsystem.evolved(iterations: 4))
    }
}

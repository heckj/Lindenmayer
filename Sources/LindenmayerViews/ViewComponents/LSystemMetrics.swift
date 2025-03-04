//
//  LSystemMetrics.swift
//
//
//  Created by Joseph Heck on 12/16/21.
//

public import Lindenmayer
import SwiftUI

/// A view that provides the size of the state of an L-system and a textual representation of that state.
public struct LSystemMetrics: View {
    @State var system: any LindenmayerSystem
    public var body: some View {
        VStack {
            Text("State size: \(system.state.count)")
            Text("\(String(describing: system.state))")
                .font(.caption)
                .lineLimit(3)
                .padding(.horizontal)
        }.task {
            system = await system.evolved(iterations: 4)
        }
    }

    public init(system: any LindenmayerSystem) {
        self.system = system
    }
}

struct LSystemMetrics_Previews: PreviewProvider {
    static var previews: some View {
        LSystemMetrics(system: Examples3D.monopodialTree)
    }
}

//
//  LSystemMetrics.swift
//  X5336
//
//  Created by Joseph Heck on 12/16/21.
//

import SwiftUI
import Lindenmayer

public struct LSystemMetrics: View {
    let system: LSystem
    public var body: some View {
        VStack {
            Text("# Rules: \(system.rules.count), State size: \(system.state.count)")
            Text("\(String(describing: system.state))")
                .font(.caption)
                .lineLimit(5)
                .padding(.horizontal)
        }
    }
    public init(system: LSystem) {
        self.system = system
    }

}

struct LSystemMetrics_Previews: PreviewProvider {
    static var previews: some View {
        LSystemMetrics(system: Lindenmayer.Examples2D.barnsleyFern.lsystem)
    }
}

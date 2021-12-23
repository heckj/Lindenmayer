//
//  Lsystem2DView.swift
//  X5336
//
//  Created by Joseph Heck on 12/12/21.
//

import Lindenmayer
import SwiftUI

public struct Lsystem2DView: View {
    let system: LSystem
    let renderer = GraphicsContextRenderer()
    public var body: some View {
        VStack {
            LSystemMetrics(system: system)
            Canvas { context, size in
                renderer.draw(system, into: &context, ofSize: size)
            }
        }
    }
    
    public init(system: LSystem) {
        self.system = system
    }
}

struct Lsystem2DView_Previews: PreviewProvider {
    static var previews: some View {
        Lsystem2DView(system: Examples2D.barnsleyFern.evolved(iterations: 4))
    }
}

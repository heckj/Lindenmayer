//
//  Lsystem2DView.swift
//
//
//  Created by Joseph Heck on 12/12/21.
//

public import Lindenmayer
import SwiftUI

/// A view that provides a 2D rendering of the L-system provide, and optionally metrics associated with the L-system.
@available(macOS 12.0, iOS 15.0, *)
@MainActor
public struct Lsystem2DView: View {
    let iterations: Int
    let displayMetrics: Bool
    @State var system: any LindenmayerSystem
    let renderer = GraphicsContextRenderer()
    public var body: some View {
        VStack {
            if displayMetrics {
                LSystemMetrics(system: system)
            }
            Canvas { context, size in
                renderer.draw(system, into: &context, ofSize: size)
            }
        }.task {
            system = await system.evolved(iterations: iterations)
        }
    }

    public init(system: any LindenmayerSystem, iterations: Int, displayMetrics: Bool = false) {
        self.system = system
        self.iterations = iterations
        self.displayMetrics = displayMetrics
    }
}

@available(macOS 12.0, iOS 15.0, *)
struct Lsystem2DView_Previews: PreviewProvider {
    static var previews: some View {
        Lsystem2DView(system: Examples2D.barnsleyFern, iterations: 4,
                      displayMetrics: true)
    }
}

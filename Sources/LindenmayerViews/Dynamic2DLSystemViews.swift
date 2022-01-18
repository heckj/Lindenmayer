//
//  Dynamic2DLSystemViews.swift
//
//
//  Created by Joseph Heck on 12/15/21.
//

import Lindenmayer
import SwiftUI

/// A view that allows you to choose from a collection of the built-in 2D L-systems and display the 2D representation of the L-system at the number of iterations that you select in the view.
@available(macOS 12.0, iOS 15.0, *)
public struct Dynamic2DLSystemViews: View {
    @State private var evolutions: Double = 0
    @State private var selectedSystem = Examples2D.fractalTree
    public var body: some View {
        VStack {
            Picker("L-System", selection: $selectedSystem) {
                Text("Fractal Tree").tag(Examples2D.fractalTree)
                Text("Koch Curve").tag(Examples2D.kochCurve)
                Text("Sierpinski Triangle").tag(Examples2D.sierpinskiTriangle)
                Text("Dragon Curve").tag(Examples2D.dragonCurve)
                Text("Barnsley Fern").tag(Examples2D.barnsleyFern)
            }
            .padding()
            HStack {
                Text("Evolutions:")
                Slider(value: $evolutions, in: 0 ... 10.0, step: 1.0) {
                    Text("Evolutions")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("10")
                }
            }
            .padding()
            Lsystem2DView(system: selectedSystem.lsystem.evolved(iterations: Int(evolutions)),
                          displayMetrics: false)
        }
    }
}

@available(macOS 12.0, iOS 15.0, *)
struct Dynamic2DLSystemViews_Previews: PreviewProvider {
    static var previews: some View {
        Dynamic2DLSystemViews()
    }
}

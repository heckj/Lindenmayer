//
//  Dynamic2DLSystemViews.swift
//
//
//  Created by Joseph Heck on 12/15/21.
//

import Lindenmayer
import SwiftUI


public enum TwoDExamples: String, CaseIterable, Identifiable {
    case algae
    case sierpinskiTriangle
    case kochCurve
    case dragonCurve
    case fractalTree
    case barnsleyFern
    public var id: String { rawValue }
    /// The example seed L-system
    public var lsystem: LindenmayerSystem {
        switch self {
        case .algae:
            return Examples2D.algae
        case .sierpinskiTriangle:
            return Examples2D.sierpinskiTriangle
        case .kochCurve:
            return Examples2D.kochCurve
        case .dragonCurve:
            return Examples2D.dragonCurve
        case .fractalTree:
            return Examples2D.fractalTree
        case .barnsleyFern:
            return Examples2D.barnsleyFern
        }
    }
}

/// A view that allows you to choose from a collection of the built-in 2D L-systems and display the 2D representation of the L-system at the number of iterations that you select in the view.
@available(macOS 12.0, iOS 15.0, *)
public struct Dynamic2DLSystemViews: View {
    @State private var evolutions: Double = 0
    @State private var selectedSystem = TwoDExamples.fractalTree
    public var body: some View {
        VStack {
            Picker("L-System", selection: $selectedSystem) {
                Text("Fractal Tree").tag(TwoDExamples.fractalTree)
                Text("Koch Curve").tag(TwoDExamples.kochCurve)
                Text("Sierpinski Triangle").tag(TwoDExamples.sierpinskiTriangle)
                Text("Dragon Curve").tag(TwoDExamples.dragonCurve)
                Text("Barnsley Fern").tag(TwoDExamples.barnsleyFern)
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

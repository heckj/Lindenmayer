//
//  SwiftUIView.swift
//
//
//  Created by Joseph Heck on 1/10/22.
//

import Lindenmayer
import SwiftUI

@available(macOS 12.0, iOS 15.0, *)
struct WindowedSmallModuleView: View {
    let size: SummarySizes
    let system: LSystem
    let position: Int
    let windowSize: Int

    var body: some View {
        // precondition(position in 0..<system.state)
        HStack(spacing: 1) {
            if windowSize > 7 {
                if position - 4 >= 0 {
                    TinyModuleSummaryView(size: size, module: system.state(at: position - 4))
                        .scaleEffect(x: 0.8, y: 0.8)
                } else {
                    EmptyModuleSummaryView(size: size)
                        .scaleEffect(x: 0.8, y: 0.8)
                }
            }
            if windowSize > 5 {
                if position - 3 >= 0 {
                    TinyModuleSummaryView(size: size, module: system.state(at: position - 3))
                        .scaleEffect(x: 0.8, y: 0.8)
                } else {
                    EmptyModuleSummaryView(size: size)
                        .scaleEffect(x: 0.8, y: 0.8)
                }
            }
            if windowSize > 3 {
                if position - 2 >= 0 {
                    TinyModuleSummaryView(size: size, module: system.state(at: position - 2))
                        .scaleEffect(x: 0.8, y: 0.8)
                } else {
                    EmptyModuleSummaryView(size: size)
                        .scaleEffect(x: 0.8, y: 0.8)
                }
            }
            if windowSize > 1 {
                if position - 1 >= 0 {
                    TinyModuleSummaryView(size: size, module: system.state(at: position - 1))
                        .scaleEffect(x: 0.9, y: 0.9)
                } else {
                    EmptyModuleSummaryView(size: size)
                        .scaleEffect(x: 0.9, y: 0.9)
                }
            }
            TinyModuleSummaryView(size: size, module: system.state(at: position))
            if windowSize > 1 {
                if position + 1 < system.state.count {
                    TinyModuleSummaryView(size: size, module: system.state(at: position + 1))
                        .scaleEffect(x: 0.9, y: 0.9)
                } else {
                    EmptyModuleSummaryView(size: size)
                        .scaleEffect(x: 0.9, y: 0.9)
                }
            }
            if windowSize > 3 {
                if position + 2 < system.state.count {
                    TinyModuleSummaryView(size: size, module: system.state(at: position + 2))
                        .scaleEffect(x: 0.8, y: 0.8)
                } else {
                    EmptyModuleSummaryView(size: size)
                        .scaleEffect(x: 0.8, y: 0.8)
                }
            }
            if windowSize > 5 {
                if position + 3 < system.state.count {
                    TinyModuleSummaryView(size: size, module: system.state(at: position + 3))
                        .scaleEffect(x: 0.8, y: 0.8)
                } else {
                    EmptyModuleSummaryView(size: size)
                        .scaleEffect(x: 0.8, y: 0.8)
                }
            }
            if windowSize > 7 {
                if position + 4 < system.state.count {
                    TinyModuleSummaryView(size: size, module: system.state(at: position + 4))
                        .scaleEffect(x: 0.8, y: 0.8)
                } else {
                    EmptyModuleSummaryView(size: size)
                        .scaleEffect(x: 0.8, y: 0.8)
                }
            }
        }
    }

    public init(size: SummarySizes, system: LSystem, position: Int, windowSize: Int = 9) {
        self.size = size
        self.system = system
        self.position = position
        if windowSize > 9 {
            self.windowSize = 9
        } else if windowSize < 1 {
            self.windowSize = 1
        } else {
            self.windowSize = windowSize
        }

        precondition(position >= 0 && position < system.state.count)
    }
}

@available(macOS 12.0, iOS 15.0, *)
struct WindowedSmallModuleView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(SummarySizes.allCases, id: \.self) { sizeChoice in
            WindowedSmallModuleView(
                size: sizeChoice,
                system: Examples3D.monopodialTree.lsystem.evolved(iterations: 4),
                position: 13
            )
        }
        ForEach([0, 3, 5, 7, 11], id: \.self) { windowSizeChoice in
            WindowedSmallModuleView(size: .medium, system: Examples3D.monopodialTree.lsystem.evolved(iterations: 4), position: 13, windowSize: windowSizeChoice)
        }
    }
}

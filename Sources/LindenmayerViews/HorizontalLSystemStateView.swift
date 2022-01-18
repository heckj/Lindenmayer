//
//  HorizontalLSystemStateView.swift
//
//
//  Created by Joseph Heck on 1/11/22.
//

import Lindenmayer
import SwiftUI

/// A view that displays a horizontal collection of summary of the modules of an Lsystem at the size choice you provide.
@available(macOS 12.0, iOS 15.0, *)
public struct HorizontalLSystemStateView: View {
    let size: SummarySizes
    let system: LSystem
    public var body: some View {
        HStack(alignment: .top, spacing: 1) {
            ForEach(0 ..< system.state.count, id: \.self) {
                ModuleSummaryView(size: size, module: system.state(at: $0))
                    .id($0)
            }
        }
    }

    public init(size: SummarySizes, system: LSystem) {
        self.size = size
        self.system = system
    }
}

@available(macOS 12.0, iOS 15.0, *)
struct HorizontalLSystemStateView_Previews: PreviewProvider {
    static var previews: some View {
        let system = Examples3D.monopodialTree.lsystem.evolved(iterations: 4)
        ForEach(SummarySizes.allCases, id: \.self) { sizeChoice in
            HorizontalLSystemStateView(size: sizeChoice, system: system)
        }
    }
}

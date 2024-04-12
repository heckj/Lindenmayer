//
//  ModuleSummaryView.swift
//
//
//  Created by Joseph Heck on 1/10/22.
//
import Lindenmayer
import SwiftUI

/// A view that represents a summary view of a single debug module from an L-system at the size you choose.
@available(macOS 12.0, iOS 15.0, *)
public struct ModuleSummaryView: View {
    let size: SummarySizes
    let module: DebugModule
    public var body: some View {
        switch size {
        case .medium:
            Rectangle()
                .strokeBorder(module.new ? Color.green : Color.gray, lineWidth: 2)
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
                .background {
                    Text(module.module.name)
                        .font(.caption)
                }
                .background(module.new ? Color.green : Color.gray)
        case .large:
            Rectangle()
                .strokeBorder(module.new ? Color.green : Color.gray, lineWidth: 2)
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
                .background {
                    Text(module.module.name)
                }
                .background(module.new ? Color.green : Color.gray)
        case .touchable:
            Rectangle()
                .strokeBorder(module.new ? Color.green : Color.gray, lineWidth: 2)
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
                .background {
                    Text(module.module.name)
                        .font(.title)
                }
                .background(module.new ? Color.green : Color.gray)
        default:
            Rectangle()
                .strokeBorder(module.new ? Color.green : Color.gray, lineWidth: 2)
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
                .background(module.new ? Color.green : Color.gray)
        }
    }

    public init(size: SummarySizes, module: DebugModule) {
        self.size = size
        self.module = module
    }
}

@available(macOS 12.0, iOS 15.0, *)
struct ModuleSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        @State var system = Examples3D.monopodialTree
        ForEach(SummarySizes.allCases, id: \.self) { sizeChoice in
            HStack(alignment: .top, spacing: 1) {
                ForEach(system.identifiableModules()) {
                    ModuleSummaryView(size: sizeChoice, module: $0)
                }
            }
        }.task {
            system = await system.evolved(iterations: 4)
        }
    }
}

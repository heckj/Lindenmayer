//
//  NewModuleSummaryView.swift
//  
//
//  Created by Joseph Heck on 1/10/22.
//
import Lindenmayer
import SwiftUI

public enum SummarySizes: Double, CaseIterable {
    case tiny = 4
    case small = 8
    case medium = 16
    case large = 32
    case touchable = 44
}

@available(macOS 12.0, *)
struct TinyModuleSummaryView: View {
    let size: SummarySizes
    let module: DebugModule
    var body: some View {
        switch size {
        case .medium:
            Rectangle()
                .strokeBorder(module.new ? Color.green : Color.gray, lineWidth: 2)
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
                .background {
                    Text(module.module.name)
                        .font(.caption)
                }
        case .large:
            Rectangle()
                .strokeBorder(module.new ? Color.green : Color.gray, lineWidth: 2)
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
                .background {
                    Text(module.module.name)
                }
        case .touchable:
            Rectangle()
                .strokeBorder(module.new ? Color.green : Color.gray, lineWidth: 2)
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
                .background {
                    Text(module.module.name)
                        .font(.title)
                }
        default:
            Rectangle()
                .strokeBorder(module.new ? Color.green : Color.gray, lineWidth: 2)
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
        }
        
    }
}

@available(macOS 12.0, *)
struct TinyModuleSummaryView_Previews: PreviewProvider {
    static func provideModule() -> DebugModule {
        Examples3D.monopodialTree.lsystem.evolved(iterations: 4).state(at: 13)
    }
    static var previews: some View {
        TinyModuleSummaryView(size: .tiny, module: provideModule())
    }
}

@available(macOS 12.0, *)
struct NewModuleSummaryView: View {
    let size: SummarySizes
    let system: LSystem
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(alignment: .top, spacing: 1) {
                ForEach(0..<system.state.count) {
                    TinyModuleSummaryView(size: size, module: system.state(at:$0))
                }
            }
        }
    }
}

@available(macOS 12.0, *)
struct NewModuleSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        
        ForEach(SummarySizes.allCases, id: \.self) { sizeChoice in
            NewModuleSummaryView(size: sizeChoice,
                                 system: Examples3D.monopodialTree.lsystem.evolved(iterations: 4))
            
        }
    }
}
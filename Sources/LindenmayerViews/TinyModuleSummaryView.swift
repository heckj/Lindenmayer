//
//  TinyModuleSummaryView.swift
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

public struct EmptyModuleSummaryView: View {
    let size: SummarySizes
    public var body: some View {
        switch size {
        case .medium:
            Color.clear
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
        case .large:
            Color.clear
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
        case .touchable:
            Color.clear
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
        default:
            Color.clear
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
        }
    }

    public init(size: SummarySizes) {
        self.size = size
    }
}

@available(macOS 12.0, iOS 15.0, *)
public struct TinyModuleSummaryView: View {
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
struct TinyModuleSummaryView_Previews: PreviewProvider {
    static func provideModule() -> DebugModule {
        Examples3D.monopodialTree.lsystem.evolved(iterations: 4).state(at: 13)
    }

    static var previews: some View {
        let system = Examples3D.monopodialTree.lsystem.evolved(iterations: 4)
        ForEach(SummarySizes.allCases, id: \.self) { sizeChoice in
            HStack(alignment: .top, spacing: 1) {
                ForEach(0 ..< system.state.count) {
                    TinyModuleSummaryView(size: sizeChoice, module: system.state(at: $0))
                }
            }
        }
    }
}

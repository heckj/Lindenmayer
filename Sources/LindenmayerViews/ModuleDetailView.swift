//
//  ModuleDetailView.swift
//
//
//  Created by Joseph Heck on 1/10/22.
//
import Lindenmayer
import SwiftUI

/// A view that provides a detailed view of a module.
///
/// The parameters (if any) of the module, and their values, as displayed above a string representation of the 3D rendering command associated with the module.
public struct ModuleDetailView: View {
    let module: DebugModule
    public var body: some View {
        VStack {
            //            Text("\(module.module.name)")
            //                .font(.title)
            if module.mirroredProperties.count > 0 {
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 10, maximum: 150), spacing: 5, alignment: .trailing),
                    GridItem(.flexible(minimum: 10, maximum: 50), spacing: 5, alignment: .leading),
                ]) {
                    ForEach(module.mirroredProperties, id: \.self) { key in
                        Text("\(key):")
                        Text(module.valueOf(key) ?? "")
                    }
                }
            }

            Text("render: \(String(describing: module.module.render3D))")
        }
        .frame(minWidth: 100, maxWidth: 300, minHeight: 50, maxHeight: 50)
        .padding(4)
        // .background(module.new ? Color.green : Color.gray)
    }

    public init(module: DebugModule) {
        self.module = module
    }
}

struct ModuleDetailView_Previews: PreviewProvider {
    static func provideModule() -> DebugModule {
        Examples3D.monopodialTree.lsystem.evolved(iterations: 4).state(at: 3)
    }

    static var previews: some View {
        ModuleDetailView(module: provideModule())
    }
}

//
//  SwiftUIView.swift
//
//
//  Created by Joseph Heck on 1/10/22.
//
import Lindenmayer
import SwiftUI

public struct ModuleDetailView: View {
    let module: DebugModule
    public var body: some View {
        VStack {
//            Text("\(module.module.name)")
//                .font(.title)
            if module.mirroredProperties.count > 0 {
                VStack(alignment: .leading) {
                    ForEach(module.mirroredProperties, id: \.self) { key in
                        HStack {
                            Text("\(key):")
                            Text(module.valueOf(key) ?? "")
                        }
                    }
                }
            }
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

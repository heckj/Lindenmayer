//
//  SwiftUIView.swift
//
//
//  Created by Joseph Heck on 1/10/22.
//
import Lindenmayer
import SwiftUI

public struct SmallModuleView: View {
    let module: DebugModule
    public var body: some View {
        VStack {
            Text("\(module.module.name)")
                .font(.title)
        }
        .padding(2)
        .frame(width: 44, height: 44, alignment: .center)
        .background(module.new ? Color.green : Color.gray)
        .border(.black)
        .padding(1)
    }

    public init(module: DebugModule) {
        self.module = module
    }
}

struct SmallModuleView_Previews: PreviewProvider {
    static func provideModule() -> DebugModule {
        Examples3D.monopodialTree.lsystem.evolved(iterations: 4).state(at: 13)
    }

    static var previews: some View {
        SmallModuleView(module: provideModule())
    }
}

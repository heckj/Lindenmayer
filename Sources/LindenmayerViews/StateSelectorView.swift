//
//  StateSelectorView.swift
//  
//
//  Created by Joseph Heck on 1/10/22.
//

import Lindenmayer
import SwiftUI

@available(macOS 12.0, *)
struct StateSelectorView: View {
    let system: LSystem
    @State private var indexPosition: Int = 0
    @State private var sliderPosition: Double = 0
    @State private var activelyMovingSlider: Bool = false
    
    var body: some View {
        VStack {
            Text("Position: \(Int(sliderPosition)) of \(system.state.count - 1)")
                .foregroundColor(activelyMovingSlider ? .red : .blue)
            Slider(value: $sliderPosition,
                   in: 0...Double(system.state.count - 1),
                   step: 1,
                   onEditingChanged: { activelyEditing in
                activelyMovingSlider = activelyEditing
                if !activelyEditing {
                    indexPosition = Int(sliderPosition)
                }
            })
            SmallModuleView(module: system.state(at: indexPosition))
            NewModuleSummaryView(size: .small, system: system)
        }
        
    }
    
    public init(system: LSystem) {
        self.system = system
    }
}

@available(macOS 12.0, *)
struct StateSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        StateSelectorView(system: Examples3D.monopodialTree.lsystem.evolved(iterations: 4))
    }
}

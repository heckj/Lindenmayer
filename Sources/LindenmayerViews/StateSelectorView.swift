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
    // state for the related views that show stuff
    @State private var indexPosition: Int = 0
    // state for the slider
    @State private var sliderPosition: Double = 0
    @State private var activelyMovingSlider: Bool = false
    // state for the forward and reverse buttons, and long-press capability
    @State private var isLongPressingReverse: Bool = false
    @State private var reverseTimer: Timer?
    @State private var isLongPressingForward: Bool = false
    @State private var forwardTimer: Timer?

    var body: some View {
        VStack {
            NewModuleSummaryView(size: .small, system: system)
            Slider(value: $sliderPosition,
                   in: 0 ... Double(system.state.count - 1),
                   step: 1,
                   onEditingChanged: { _ in
                       indexPosition = Int(sliderPosition)
                   })
            Text("Position: \(Int(sliderPosition)) of \(system.state.count - 1)")
            HStack {
                Button {
                    // ending the long press
                    if self.isLongPressingReverse {
                        self.isLongPressingReverse.toggle()
                        self.reverseTimer?.invalidate()
                    } else {
                        if sliderPosition >= 1.0 {
                            sliderPosition -= 1
                            indexPosition -= 1
                        }
                    }
                } label: {
                    Image(systemName: "chevron.backward.square")
                        .font(.title)
                }
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                    // start the long press reverse
                    self.isLongPressingReverse = true
                    self.isLongPressingForward = false
                    self.forwardTimer?.invalidate()
                    // or fastforward has started to start the timer
                    self.reverseTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                        if sliderPosition >= 1.0 {
                            sliderPosition -= 1
                            indexPosition -= 1
                        }
                    })
                })
                Spacer()
                WindowedSmallModuleView(size: .touchable, system: system, position: indexPosition, windowSize: 7)
//                SmallModuleView(module: system.state(at: indexPosition))
                Spacer()
                Button {
                    if sliderPosition < Double(system.state.count - 1) {
                        // ending the long press forward
                        if self.isLongPressingForward {
                            self.isLongPressingForward.toggle()
                            self.forwardTimer?.invalidate()
                        } else {
                            if sliderPosition <= Double(system.state.count - 1) {
                                sliderPosition += 1
                                indexPosition += 1
                            }
                        }
                    }
                } label: {
                    Image(systemName: "chevron.forward.square")
                        .font(.title)
                }
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                    // start the long press forward
                    self.isLongPressingForward = true
                    self.isLongPressingReverse = false
                    self.reverseTimer?.invalidate()
                    // or fastforward has started to start the timer
                    self.forwardTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                        if sliderPosition <= Double(system.state.count - 1) {
                            sliderPosition += 1
                            indexPosition += 1
                        }
                    })
                })
            }
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

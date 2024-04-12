//
//  StateSelectorView.swift
//
//
//  Created by Joseph Heck on 1/10/22.
//

import Lindenmayer
import SwiftUI

/// A view that provides a visual representation of the states of an L-system and allows the person viewing it to select an index position from that L-system's state.
@available(macOS 12.0, iOS 15.0, *)
public struct StateSelectorView: View {
    @State var system: LindenmayerSystem
    let _withDetailView: Bool
    // state for the related views that show stuff
    @Binding var indexPosition: Int
    // state for the slider
    @State private var sliderPosition: Double = 0
    @State private var activelyMovingSlider: Bool = false
    // state for the forward and reverse buttons, and long-press capability
    @State private var isLongPressingReverse: Bool = false
    @State private var reverseTimer: Timer?
    @State private var isLongPressingForward: Bool = false
    @State private var forwardTimer: Timer?

    public var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: true) {
                    HorizontalLSystemStateView(size: .medium, system: system)
                }
                #if os(tvOS)
                    VStack {
                        Button {
                            if indexPosition < system.state.count - 1 {
                                indexPosition += 1
                                proxy.scrollTo(indexPosition)
                            }
                        } label: {
                            Image(systemName: "plus.square")
                        }
                        Button {
                            if indexPosition > 1 {
                                indexPosition -= 1
                                proxy.scrollTo(indexPosition)
                            }
                        } label: {
                            Image(systemName: "minus.square")
                        }
                    }.padding()
                #else
                    if system.state.count > 1 {
                        // a slider can't be 0 ... 0 - "max stride must be positive"
                        Slider(value: $sliderPosition,
                               in: 0 ... Double(system.state.count - 1),
                               step: 1,
                               onEditingChanged: { _ in
                                   indexPosition = Int(sliderPosition)
                                   proxy.scrollTo(indexPosition)
                               })
                               .onChange(of: indexPosition) { newValue in
                                   sliderPosition = Double(newValue)
                               }
                    }
                #endif
                Text("Position: \(Int(sliderPosition)) of \(system.state.count - 1)")
                HStack {
                    #if os(tvOS) || os(watchOS)
                        Button {
                            // ending the long press
                            if isLongPressingReverse {
                                isLongPressingReverse.toggle()
                                reverseTimer?.invalidate()
                            } else {
                                if sliderPosition >= 1.0 {
                                    sliderPosition -= 1
                                    indexPosition -= 1
                                    proxy.scrollTo(indexPosition)
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.backward.square")
                        }
                    #else
                        Button {
                            // ending the long press
                            if isLongPressingReverse {
                                isLongPressingReverse.toggle()
                                reverseTimer?.invalidate()
                            } else {
                                if sliderPosition >= 1.0 {
                                    sliderPosition -= 1
                                    indexPosition -= 1
                                    proxy.scrollTo(indexPosition)
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.backward.square")
                            #if os(iOS)
                                .font(.title)
                            #endif
                        }
                        .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                            // start the long press reverse
                            isLongPressingReverse = true
                            isLongPressingForward = false
                            forwardTimer?.invalidate()
                            // or fastforward has started to start the timer
                            reverseTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                if sliderPosition >= 1.0 {
                                    sliderPosition -= 1
                                    indexPosition -= 1
                                    proxy.scrollTo(indexPosition)
                                }
                            })
                        })
                        .keyboardShortcut(KeyboardShortcut(.leftArrow))
                    #endif
                    Spacer()
                    WindowedSmallModuleView(size: .touchable, system: system, position: indexPosition, windowSize: 7)
                    Spacer()
                    #if os(tvOS) || os(watchOS)
                        Button {
                            // ending the long press forward
                            if isLongPressingForward {
                                isLongPressingForward.toggle()
                                forwardTimer?.invalidate()
                            } else {
                                if sliderPosition < Double(system.state.count - 1) {
                                    sliderPosition += 1
                                    indexPosition += 1
                                    proxy.scrollTo(indexPosition)
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.forward.square")
                        }
                    #else
                        Button {
                            // ending the long press forward
                            if isLongPressingForward {
                                isLongPressingForward.toggle()
                                forwardTimer?.invalidate()
                            } else {
                                if sliderPosition < Double(system.state.count - 1) {
                                    sliderPosition += 1
                                    indexPosition += 1
                                    proxy.scrollTo(indexPosition)
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.forward.square")
                            #if os(iOS)
                                .font(.title)
                            #endif
                        }
                        .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                            // start the long press forward
                            isLongPressingForward = true
                            isLongPressingReverse = false
                            reverseTimer?.invalidate()
                            // or fastforward has started to start the timer
                            forwardTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                if sliderPosition < Double(system.state.count - 1) {
                                    sliderPosition += 1
                                    indexPosition += 1
                                    proxy.scrollTo(indexPosition)
                                }
                            })
                        })
                        .keyboardShortcut(KeyboardShortcut(.rightArrow))
                    #endif
                }
                if _withDetailView {
                    ModuleDetailView(module: system.state(at: indexPosition))
                }
            }
        }
    }

    public init(system: LindenmayerSystem, position: Binding<Int>, withDetailView: Bool = false) {
        self.system = system
        _withDetailView = withDetailView
        _indexPosition = position
    }
}

@available(macOS 12.0, iOS 15.0, *)
struct StateSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        @State var system = Examples3D.monopodialTree
        Group {
            StateSelectorView(system: system, position: .constant(13))
            StateSelectorView(system: system, position: .constant(13), withDetailView: true)
        }.task {
            system = await system.evolved(iterations: 4)
        }
    }
}

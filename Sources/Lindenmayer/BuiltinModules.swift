//
//  BuiltinModules.swift
//  X5336
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation

/// A collection of built-in modules for use in LSystems
public enum Modules {}

public extension Modules {
    // MARK: - EXAMPLE MODULE -

    struct Internode: Module {
        // This is the kind of thing that I want external developers using the library to be able to create to represent elements within their L-system.
        public var name = "I"
        public var render2D: [TwoDRenderCmd] = [RenderCommand.Draw(length: 10)] // draws a line 10 units long
    }

    static var internode = Internode()

}

//
//  Module.swift
//  X5336
//
//  Created by Joseph Heck on 12/9/21.
//
import Foundation

/// A module represents an element in an L-system state array, and its parameters, if any.
public protocol Module: CustomStringConvertible {
    /// The name of the module.
    ///
    /// Use a single character or very short string for the name, as it's used in textual descriptions of the state of an L-system.
    var name: String { get }

    /// Returns a sequence of render commands to display the content in 2-dimensionals.
    var render2D: [TwoDRenderCommand] { get }
    /// Returns a sequence of render commands to display the content in 3-dimensionals.
    var render3D: ThreeDRenderCommand { get }
}

public extension Module {
    // MARK: - CustomStringConvertible default implementation

    /// Returns a string description for this module.
    var description: String {
        let resovledName: String
        if name != "" {
            resovledName = name
        } else {
            resovledName = String(describing: type(of: self))
        }
        return resovledName
    }
}

public extension Module {
    // MARK: - Default render command implementations

    /// The 2D rendering commands to use when a renderer represents this module visually.
    ///
    /// The default value is a single ``TwoDRenderCommand/ignore`` command, which provides no visual representation.
    /// Provide your own variable that returns a list of render commands that the 2D renderer supports to define your own visual representation.
    var render2D: [TwoDRenderCommand] {
        return [.ignore]
    }

    /// The 3D rendering commands to use when a renderer represents this module visually.
    ///
    /// The default value is a single ``ThreeDRenderCommand/ignore`` command, which provides no visual representation.
    /// Provide your own variable that returns a list of render commands that the 3D renderer supports to define your own visual representation.
    var render3D: ThreeDRenderCommand {
        return .ignore
    }
}

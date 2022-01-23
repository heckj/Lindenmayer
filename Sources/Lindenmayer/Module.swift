//
//  Module.swift
//
//
//  Created by Joseph Heck on 12/9/21.
//
import Foundation

/// A module that represents a state element in an L-system state array and its parameters, if any.
///
/// The modules include 2D and 3D representations that can be interpretted by the provided ``GraphicsContextRenderer`` to draw into a SwiftUI canvas, or ``SceneKitRenderer`` to generate and SceneKit 3D scene.
public protocol Module: CustomStringConvertible {
    /// The name of the module.
    ///
    /// Use a single character or very short string for the name, as it's used in textual descriptions of the state of an L-system.
    var name: String { get }
    /// Returns a sequence of render commands to display the content in 2-dimensionals.
    var render2D: [TwoDRenderCmd] { get }
    /// Returns a sequence of render commands to display the content in 3-dimensionals.
    var render3D: ThreeDRenderCmd { get }
}

// MARK: - Default Implementations of computed properties for 2D and 3D rendering commands of a module.

public extension Module {
    /// The sequence of two-dimensional oriented rendering commands that you use to represent the module.
    var render2D: [TwoDRenderCmd] {
        return []
    }

    /// The three-dimensional oriented rendering command that you use to represent the module.
    var render3D: ThreeDRenderCmd {
        return RenderCommand.Ignore()
    }
}

// MARK: - CustomStringConvertible default implementation

public extension Module {
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
    /// Returns the name of the type of the instance conforming to the module protocol.
    func namedType() -> String {
        let mirror = Mirror(reflecting: self)
        return "\(mirror.subjectType)"
    }

    /// Returns a dictionary of strings that provide the properties and associated values for the instance.
    func children() -> [String: String] {
        let mirror = Mirror(reflecting: self)
        var propertyDict: [String: String] = [:]
        for child in mirror.children {
            if let label = child.label {
                propertyDict[label] = "\(child.value)"
            }
        }
        return propertyDict
    }
}

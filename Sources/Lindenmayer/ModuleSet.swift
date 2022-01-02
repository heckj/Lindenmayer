//
//  ModuleSet.swift
//
//
//  Created by Joseph Heck on 12/28/21.
//

import Foundation

/// The set of modules found in sequence while processing the state of an L-system.
///
/// The set is made up of the current module, and its left and right neighbors, if available; otherwise, `nil`.
public struct ModuleSet {
    /// The module to the left (earlier) in the L-systems's state sequence.
    var leftInstance: Module?
    /// The type of the module to the left.
    var leftInstanceType: Module.Type?

    /// The module instance.
    let directInstance: Module
    /// The type of the module instance.
    let directInstanceType: Module.Type

    /// The module to the right (later) in the L-system's state sequence.
    var rightInstance: Module?
    /// The type of the module to the right.
    var rightInstanceType: Module.Type?

    /// Creates a new module set with a module.
    /// - Parameters:
    ///   - directInstance: The module instance.
    ///   - directInstanceType: The type of the module.
    public init(directInstance: Module) {
        self.directInstance = directInstance
        directInstanceType = type(of: directInstance)
    }

    /// Creates a new module set with a module and its left and right neighbors.
    /// - Parameters:
    ///   - leftInstance: The module to the left (earlier) in the L-system's state sequence.
    ///   - leftInstanceType: The type of the module to the left.
    ///   - directInstance: The module instance.
    ///   - directInstanceType: The type of the module.
    ///   - rightInstance: The module to the right (later) in the L-system's state sequence.
    ///   - rightInstanceType: The type fo the module to the right.
    public init(leftInstance: Module?, directInstance: Module, rightInstance: Module?) {
        if let leftInstance = leftInstance {
            self.leftInstance = leftInstance
            leftInstanceType = type(of: leftInstance)
        }

        self.directInstance = directInstance
        directInstanceType = type(of: directInstance)

        if let rightInstance = rightInstance {
            self.rightInstance = rightInstance
            rightInstanceType = type(of: rightInstance)
        }
    }
}

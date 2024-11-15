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
///
/// ## Topics
///
/// ### Creating a ModuleSet
///
/// - ``ModuleSet/init(directInstance:)``
/// - ``ModuleSet/init(leftInstance:directInstance:rightInstance:)``
///
public struct ModuleSet {
    /// The module to the left (earlier) in the L-systems's state sequence.
    let leftInstance: (any Module)?
    /// The type of the module to the left.
    let leftInstanceType: (any Module.Type)?

    /// The module instance.
    let directInstance: any Module
    /// The type of the module instance.
    let directInstanceType: any Module.Type

    /// The module to the right (later) in the L-system's state sequence.
    let rightInstance: (any Module)?
    /// The type of the module to the right.
    let rightInstanceType: (any Module.Type)?

    /// Creates a new module set with a module.
    /// - Parameters:
    ///   - directInstance: The module instance.
    ///   - directInstanceType: The type of the module.
    public init(directInstance: some Module) {
        self.directInstance = directInstance
        directInstanceType = type(of: directInstance)
        leftInstance = nil
        leftInstanceType = nil
        rightInstance = nil
        rightInstanceType = nil
    }

    /// Creates a new module set with a module and its left and right neighbors.
    /// - Parameters:
    ///   - leftInstance: The module to the left (earlier) in the L-system's state sequence.
    ///   - leftInstanceType: The type of the module to the left.
    ///   - directInstance: The module instance.
    ///   - directInstanceType: The type of the module.
    ///   - rightInstance: The module to the right (later) in the L-system's state sequence.
    ///   - rightInstanceType: The type fo the module to the right.
    public init(leftInstance: (any Module)?, directInstance: any Module, rightInstance: (any Module)?) {
        if let left = leftInstance {
            self.leftInstance = left
            leftInstanceType = type(of: left)
        } else {
            self.leftInstance = nil
            leftInstanceType = nil
        }

        self.directInstance = directInstance
        directInstanceType = type(of: directInstance)

        if let right = rightInstance {
            self.rightInstance = right
            rightInstanceType = type(of: right)
        } else {
            self.rightInstance = nil
            rightInstanceType = nil
        }
    }
}

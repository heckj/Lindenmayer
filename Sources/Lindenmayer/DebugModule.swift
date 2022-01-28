//
//  DebugModule.swift
//
//
//  Created by Joseph Heck on 1/10/22.
//

import Foundation

/// A class that wraps an abstract Module and provides access to its internal state as formatted strings.
///
/// The class provides an `Identifiable` reference based on the location within an existing ``LindenmayerSystem``.
/// The internal state of the underlying ``Module`` instance is exposed using `Mirror`.
///
/// Retrieve an instance of a `DebugModule` by calling ``LindenmayerSystem/state(at:)``:
/// ```
/// let system = Examples2D.barnsleyFern.evolved(iterations: 4)
/// let debugModuleInstance = system.state(at: 14)
/// print("ID: \(debugModuleInstance.id), name: \(debugModuleInstance.module.name)")
///
/// // ID: 14, name: F
/// ```
///
/// ## Topics
///
/// ### Inspecting a DebugModule
///
/// - ``DebugModule/new``
/// - ``DebugModule/module``
/// - ``DebugModule/id-6ifq9``
///
/// ### Retrieving the Underlying Module Properties
///
/// - ``DebugModule/mirroredProperties``
/// - ``DebugModule/valueOf(_:)``
///
public class DebugModule: Identifiable {
    /// The abstract, underlying module instance with which you initialized the wrapper.
    public let module: Module
    /// A Boolean value that indicates whether the module was newly added in the last evolution of the L-System.
    public let new: Bool
    /// The location of the module within an L-system's state.
    ///
    /// Don't use this value to identify modules from multiple L-systems.
    /// The identifiable capabilities are only valid for a single L-system.
    public let id: Int
    private let _filteredAndSortedKeys: [String]
    /// An array that contains the string values for each of the properties within the wrapped module.
    public var mirroredProperties: [String] {
        _filteredAndSortedKeys
    }

    /// Returns the value of the property you identify from the wrapped Module  as a String.
    /// - Parameter propertyKey: The property to return.
    /// - Returns: A string that represents the property, or `nil` if that property doesn't exist.
    public func valueOf(_ propertyKey: String) -> String? {
        if module.children().keys.contains(propertyKey) {
            if let value = module.children()[propertyKey] {
                // if we can convert this over into a Double (pretty common), then reformat it down
                // to a notably shorter string for display purposes.
                if let asDouble = Double(value) {
                    return asDouble.formatted(.number.precision(
                        .integerAndFractionLength(integerLimits: 1 ... 2, fractionLimits: 0 ... 3))
                    )
                }
            }
            return module.children()[propertyKey]
        }
        return nil
    }

    /// Creates a new debug module.
    /// - Parameters:
    ///   - m: The module to use to initialize the debug module.
    ///   - at: The location within the state of an L-system.
    ///   - isNew: A Boolean value that indicates the module was created in the last evolution.
    init(_ m: Module, at: Int, isNew: Bool = false) {
        id = at
        module = m
        new = isNew
        _filteredAndSortedKeys = module.children().keys
            .filter { $0 != "name" }
            .sorted()
    }
}

extension DebugModule: Equatable {
    /// Compares two debug modules based on their location within an L-system and their name.
    /// - Returns: A Boolean value that indicates whether the two values are equal.
    ///
    /// Do not use this method to compare two debug modules from different L-systems.
    public static func == (lhs: DebugModule, rhs: DebugModule) -> Bool {
        lhs.id == rhs.id && lhs.module.name == rhs.module.name
    }
}

public extension LindenmayerSystem {
    /// Returns a debug module wrapping the module at the state position you provide.
    /// - Parameter at: The location of the state within the L-systems state array.
    /// - Returns: A ``DebugModule`` initialized with the state at the location you provide.
    ///
    /// This method crashes (using `precondition`) if you attempt to access state outside the bounds of the L-system's state array.
    func state(at: Int) -> DebugModule {
        precondition(at >= 0 && at < state.count && at < newStateIndicators.count)
        return DebugModule(state[at], at: at, isNew: newStateIndicators[at])
    }
}

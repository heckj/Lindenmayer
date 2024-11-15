//
//  LindenmayerSystem.swift
//
//
//  Created by Joseph Heck on 12/28/21.
//

import Foundation

/// A type that represents a Lindenmayer system and how it evolves.
///
/// For more information on the background of Lindenmayer systems, see [Wikipedia's L-System](https://en.wikipedia.org/wiki/L-system).
///
/// ## Topics
///
/// ### Inspecting L-systems
///
/// - ``Lindenmayer/LindenmayerSystem/state``
/// - ``Lindenmayer/LindenmayerSystem/newStateIndicators``
/// - ``Lindenmayer/LindenmayerSystem/rules``
/// - ``Lindenmayer/LindenmayerSystem/modules(atIndex:)-1v113``
/// - ``Lindenmayer/LindenmayerSystem/modules(atIndex:)-7jg4t``
///
/// ### Inspecting L-system state
///
/// - ``Lindenmayer/LindenmayerSystem/state(at:)``
/// - ``Lindenmayer/LindenmayerSystem/identifiableModules()``
///
/// ### Evolving L-Systems
///
/// - ``Lindenmayer/LindenmayerSystem/evolve()-9uqn7``
/// - ``Lindenmayer/LindenmayerSystem/evolve()-3md66``
/// - ``Lindenmayer/LindenmayerSystem/evolved(iterations:)-3x4ko``
/// - ``Lindenmayer/LindenmayerSystem/evolved(iterations:)-679jh``
/// - ``Lindenmayer/LindenmayerSystem/updatedLSystem(with:newItemIndicators:)``
///
/// ### Resetting L-systems
///
/// - ``Lindenmayer/LindenmayerSystem/reset()``
public protocol LindenmayerSystem: Sendable {
    /// The sequence of modules that represents the current state of the L-system.
    var state: [any Module] { get }

    /// An array of Boolean values that indicate if the state in the L-system was newly created in the evolution.
    ///
    /// This array is primarily used for debugging purposes
    var newStateIndicators: [Bool] { get }

    /// The sequence of rules that the L-system uses to process and evolve its state.
    var rules: [any Rule] { get }

    /// The L-system evolved by a number of iterations you provide.
    /// - Parameter iterations: The number of times to evolve the L-system.
    /// - Returns: The updated L-system from the number of evolutions you provided.
    func evolved(iterations: Int) async -> Self

    /// Returns a new L-system after processing the current state against the rules to generate a new state sequence.
    func evolve() async -> Self

    /// Returns a new L-system reset to its original state.
    func reset() async -> Self

    /// Returns a set of modules around the index location you provide.
    /// - Parameter atIndex: The index location of the state of the current L-system.
    /// - Returns: a set of three modules representing the module at the index, and to the left and right.
    /// If any modules aren't available, they are `nil`.
    func modules(atIndex: Int) -> ModuleSet

    /// Returns a new L-system with the provided state.
    /// - Parameter state: The sequence of modules that represent the new state.
    /// - Returns: A new L-system with the updated state that has the same rules.
    ///
    /// This function is called from the common ``LindenmayerSystem`` protocol's default implementation to generate an updated
    /// L-system with a set of new modules.
    func updatedLSystem(with state: [any Module], newItemIndicators: [Bool]) -> Self
}

// MARK: - default implementations

public extension LindenmayerSystem {
    /// Returns a set of modules around the index location you provide.
    /// - Parameter atIndex: The index location of the state of the current L-system.
    /// - Returns: a set of three modules representing the module at the index, and to the left and right.
    /// If any modules aren't available, they are `nil`.
    func modules(atIndex: Int) -> ModuleSet {
        let strict = state[atIndex]

        var leftInstance: (any Module)? = nil
        if atIndex - 1 > 0 {
            leftInstance = state[atIndex - 1]
        }

        var rightInstance: (any Module)? = nil
        if state.count > atIndex + 1 {
            rightInstance = state[atIndex + 1]
        }

        return ModuleSet(leftInstance: leftInstance, directInstance: strict, rightInstance: rightInstance)
    }

    /// Processes the current state against its rules to provide an updated L-system
    ///
    /// The Lindermayer system iterates through the rules provided, applying the first rule that matches the state from the rule to the current state of the system.
    /// When applying the rule, the element that matched is replaced with what the rule returns from ``Rule/produce(_:)``.
    /// - Returns: An updated Lindenmayer system.
    func evolve() async -> Self {
        // Performance is O(n)(z) with the (n) number of atoms in the state and (z) number of rules to apply.
        // TODO(heckj): revisit this with async methods in mind, creating tasks for each iteration
        // in order to run the whole suite of the state in parallel for a new result. Await the whole
        // kit for a final resolution.
        var newState: [any Module] = []
        var newStateIndicatorArray: [Bool] = []
        var newStateIndexLocation = 0
        for index in 0 ..< state.count {
            let moduleSet = modules(atIndex: index)
            // Iterate through the rules, finding the first rule to match
            // based on calling 'evaluate' on each of the rules in sequence.

            let maybeRule: (any Rule)? = rules.first(where: { $0.evaluate(moduleSet) })
            if let foundRule = maybeRule {
                // If a rule was found, then use it to generate the modules that
                // replace this element in the sequence.
                let newModules = await foundRule.produce(moduleSet)
                newState.append(contentsOf: newModules)
                for _ in newModules {
                    newStateIndicatorArray.append(true)
                    newStateIndexLocation += 1
                }
            } else {
                // If no rule was identified, we pass along the 'Module' as an
                // ignored module for later evaluation - for example to be used
                // to represent the final visual state externally.
                newState.append(moduleSet.directInstance)
                newStateIndicatorArray.append(false)
                newStateIndexLocation += 1
            }
        }
        return updatedLSystem(with: newState, newItemIndicators: newStateIndicatorArray)
    }

    /// The L-system evolved by a number of iterations you provide.
    /// - Parameter iterations: The number of times to evolve the L-system.
    /// - Returns: The updated L-system from the number of evolutions you provided.
    func evolved(iterations: Int = 1) async -> Self {
        var lsys: Self = self
        for _ in 0 ..< iterations {
            lsys = await lsys.evolve()
        }
        return lsys
    }
}

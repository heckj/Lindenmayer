//
//  LSystem.swift
//
//
//  Created by Joseph Heck on 12/28/21.
//

import Foundation

/// A type that represents a Lindenmayer system and how it evolves.
///
/// For more information on the background of Lindenmayer systems, see [Wikipedia's L-System](https://en.wikipedia.org/wiki/L-system).
public protocol LSystem {
    /// The sequence of modules that represents the current state of the L-system.
    var state: [Module] { get }

    /// The sequence of rules that the L-system uses to process and evolve its state.
    var rules: [Rule] { get }

    /// Returns a new L-system that is evolved by the number of iterations you provide.
    func evolve(iterations: Int) throws -> LSystem

    /// Returns a new L-system after processing the current state against the rules to generate a new state sequence.
    func evolve() throws -> LSystem

    /// Returns a set of modules around the index location you provide.
    /// - Parameter atIndex: The index location of the state of the current L-system.
    /// - Returns: a set of three modules representing the module at the index, and to the left and right.
    /// If any modules aren't available, they are `nil`.
    func modules(atIndex: Int) -> ModuleSet

    /// Returns a new L-system with the provided state.
    func updatedLSystem(with state: [Module]) -> LSystem
}

public extension LSystem {
    /// Returns a set of modules around the index location you provide.
    /// - Parameter atIndex: The index location of the state of the current L-system.
    /// - Returns: a set of three modules representing the module at the index, and to the left and right.
    /// If any modules aren't available, they are `nil`.
    func modules(atIndex: Int) -> ModuleSet {
        let strict = state[atIndex]

        var moduleSet = ModuleSet(directInstance: strict)

        if atIndex - 1 > 0 {
            let leftInstance = state[atIndex - 1]
            moduleSet.leftInstance = leftInstance
            moduleSet.leftInstanceType = type(of: leftInstance)
        }

        if state.count > atIndex + 1 {
            let rightInstance = state[atIndex + 1]
            moduleSet.rightInstance = rightInstance
            moduleSet.rightInstanceType = type(of: rightInstance)
        }
        return moduleSet
    }

    /// Processes the current state against its rules to provide an updated L-system
    ///
    /// The Lindermayer system iterates through the rules provided, applying the first rule that matches the state from the rule to the current state of the system.
    /// When applying the rule, the element that matched is replaced with what the rule returns from ``Rule/produce(_:)``.
    /// The types of errors that may be thrown is defined by any errors referenced and thrown within the set of rules you provide.
    /// - Returns: An updated Lindenmayer system.
    func evolve() throws -> LSystem {
        // Performance is O(n)(z) with the (n) number of atoms in the state and (z) number of rules to apply.
        // TODO(heckj): revisit this with async methods in mind, creating tasks for each iteration
        // in order to run the whole suite of the state in parallel for a new result. Await the whole
        // kit for a final resolution.
        var newState: [Module] = []
        for index in 0 ..< state.count {
            let moduleSet = modules(atIndex: index)
            // Iterate through the rules, finding the first rule to match
            // based on calling 'evaluate' on each of the rules in sequence.
            
            let maybeRule: Rule? = rules.first(where: { $0.evaluate(moduleSet) })
            if let foundRule = maybeRule {
                // If a rule was found, then use it to generate the modules that
                // replace this element in the sequence.
                newState.append(contentsOf: foundRule.produce(moduleSet))
            } else {
                // If no rule was identified, we pass along the 'Module' as an
                // ignored module for later evaluation - for example to be used
                // to represent the final visual state externally.
                newState.append(moduleSet.directInstance)
            }
        }
        return updatedLSystem(with: newState)
    }

    /// Updates the state of the Lindenmayer system by the number of iterations you provide.
    func evolve(iterations: Int = 1) throws -> LSystem {
        var lsys: LSystem = self
        for _ in 0 ..< iterations {
            lsys = try lsys.evolve()
        }
        return lsys
    }
}

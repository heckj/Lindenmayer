//
//  LSystemProtocol.swift
//  
//
//  Created by Joseph Heck on 12/28/21.
//

import Foundation

public protocol LSystem {
    var state: [Module] { get }
    var rules: [Rule] { get }
    func evolve(iterations: Int) throws -> LSystem
    func evolve() throws -> LSystem
    func modules(atIndex: Int) -> ModuleSet
    func updatedLSystem(with state: [Module]) -> LSystem
}

extension LSystem {
    public func modules(atIndex: Int) -> ModuleSet {
        let strict = state[atIndex]
        
        var moduleSet = ModuleSet(directInstance: strict, directInstanceType: type(of: strict))
        
        if atIndex - 1 > 0 {
            let leftInstance = state[atIndex - 1]
            moduleSet.leftInstance = leftInstance
            moduleSet.leftInstanceType = type(of: leftInstance)
        }
        
        if self.state.count > atIndex + 1 {
            let rightInstance = state[atIndex + 1]
            moduleSet.rightInstance = rightInstance
            moduleSet.rightInstanceType = type(of: rightInstance)
        }
        return moduleSet
    }
    
    /// Processes the current state against its rules to provide an updated L-system
    ///
    /// The Lindermayer system iterates through the rules provided, applying the first rule that matches the state from the rule to the current state of the system.
    /// When applying the rule, the element that matched is replaced with what the rule returns from ``Rule/produce``.
    /// The types of errors that may be thrown is defined by any errors referenced and thrown within the set of rules you provide.
    /// - Returns: An updated Lindenmayer system.
    public func evolve() throws -> LSystem {
        // Performance is O(n)(z) with the (n) number of atoms in the state and (z) number of rules to apply.
        // TODO(heckj): revisit this with async methods in mind, creating tasks for each iteration
        // in order to run the whole suite of the state in parallel for a new result. Await the whole
        // kit for a final resolution.
        var newState: [Module] = []
        for index in 0 ..< state.count {
            let moduleSet = modules(atIndex: index)
            // Iterate through the rules, finding the first rule to match
            // based on calling 'evaluate' on each of the rules in sequence.
            let maybeRule: Rule? = self.rules.first(where: { $0.evaluate(moduleSet.leftInstanceType, moduleSet.directInstanceType, moduleSet.rightInstanceType) })
            if let foundRule = maybeRule {
                // If a rule was found, then use it to generate the modules that
                // replace this element in the sequence.
                newState.append(contentsOf: try foundRule.produce(moduleSet))
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
    public func evolve(iterations: Int = 1) throws -> LSystem {
        var lsys: LSystem = self
        for _ in 0 ..< iterations {
            lsys = try lsys.evolve()
        }
        return lsys
    }
}

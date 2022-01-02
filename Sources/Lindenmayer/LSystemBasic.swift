//
//  LSystemBasic.swift
//
//
//  Created by Joseph Heck on 1/1/22.
//

import Foundation

/// A basic Lindenmayer system.
public struct LSystemBasic: LSystem {
    /// The sequence of modules that represents the current state of the L-system.
    public let state: [Module]

    /// The sequence of rules that the L-system uses to process and evolve its state.
    public var rules: [Rule]

    /// Creates a new Lindenmayer system from an initial state sequence and rules you provide.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - prng: A psuedo-random number generator to use for stochastic rule productions.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(_ axiom: [Module],
                rules: [Rule] = [])
    {
        state = axiom
        self.rules = rules
    }

    /// Returns a new L-system with the provided state.
    /// - Parameter state: The sequence of modules that represent the new state.
    /// - Returns: A new L-system with the updated state that has the same rules.
    public func updatedLSystem(with state: [Module]) -> LSystem {
        return LSystemBasic(state, rules: rules)
    }
    
}

extension LSystemBasic {
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<DC>(_ direct: DC.Type,
                            where evalClosure: (@escaping (ModuleSet) -> Bool),
                            produces produceClosure: @escaping (Module) throws -> [Module]) -> Self where DC: Module {
        let newRule = RewriteRuleDirect(direct: direct, where: evalClosure, produce: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemBasic(state, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<DC>(_ direct: DC.Type,
                            produces produceClosure: @escaping (Module) throws -> [Module]) -> Self where DC: Module {
        let newRule = RewriteRuleDirect(direct: direct, where: nil, produce: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemBasic(state, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<LC, DC>(leftContext: LC.Type, directContext: DC.Type,
                            where evalClosure: (@escaping (ModuleSet) -> Bool),
                                produces produceClosure: @escaping (LC, DC) throws -> [Module]) -> Self where LC: Module, DC: Module {
        let newRule = RewriteRuleLeftDirect(leftType: leftContext, directType: directContext, where: evalClosure, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemBasic(state, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<LC, DC>(leftContext: LC.Type, directContext: DC.Type,
                                produces produceClosure: @escaping (LC, DC) throws -> [Module]) -> Self where LC: Module, DC: Module {
        let newRule = RewriteRuleLeftDirect(leftType: leftContext, directType: directContext, where: nil, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemBasic(state, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<DC, RC>(directContext: DC.Type, rightContext: RC.Type,
                            where evalClosure: (@escaping (ModuleSet) -> Bool),
                                produces produceClosure: @escaping (DC, RC) throws -> [Module]) -> Self where DC: Module, RC: Module {
        let newRule = RewriteRuleDirectRight(directType: directContext, rightType: rightContext, where: evalClosure, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemBasic(state, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<DC, RC>(directContext: DC.Type, rightContext: RC.Type,
                                produces produceClosure: @escaping (DC, RC) throws -> [Module]) -> Self where DC: Module, RC: Module {
        let newRule = RewriteRuleDirectRight(directType: directContext, rightType: rightContext, where: nil, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemBasic(state, rules: newRuleSet)
    }
    
    
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<LC, DC, RC>(leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
                            where evalClosure: (@escaping (ModuleSet) -> Bool),
                                    produces produceClosure: @escaping (LC, DC, RC) throws -> [Module]) -> Self where LC: Module, DC: Module, RC: Module {
        let newRule = RewriteRuleLeftDirectRight(leftType: leftContext, directType: directContext, rightType: rightContext, where: evalClosure, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemBasic(state, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<LC, DC, RC>(leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
                                    produces produceClosure: @escaping (LC, DC, RC) throws -> [Module]) -> Self where LC: Module, DC: Module, RC: Module {
        let newRule = RewriteRuleLeftDirectRight(leftType: leftContext, directType: directContext, rightType: rightContext, where: nil, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemBasic(state, rules: newRuleSet)
    }
}

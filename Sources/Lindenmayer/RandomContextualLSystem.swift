//
//  NonParametericLSystem.swift
//
//
//  Created by Joseph Heck on 12/28/21.
//

import Foundation
import Squirrel3

/// A stochastic Lindenmayer system.
///
/// A stochastic Lindenmayer system uses a seed-able random number generator and exposes it to the rules you create, but doesn't use external parameters.
/// If you want to create an L-system doesn't use uses a seed-able random number generator, use ``ContextualLSystem``.
/// If you want to create an L-system that uses a set of external parameters and a seed-able random number generator, use ``ParameterizedRandonContextualLSystem``.
///
/// For more information on the background of Lindenmayer systems, see [Wikipedia's L-System](https://en.wikipedia.org/wiki/L-system).
public struct RandomContextualLSystem<PRNG>: LindenmayerSystem where PRNG: SeededRandomNumberGenerator {
    let axiom: [Module]

    /// The sequence of modules that represents the current state of the L-system.
    public let state: [Module]
    public var newStateIndicators: [Bool]

    var prng: RNGWrapper<PRNG>

    /// The sequence of rules that the L-system uses to process and evolve its state.
    public var rules: [Rule]

    /// Creates a new Lindenmayer system from an initial state sequence and rules you provide.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - prng: A psuedo-random number generator to use for stochastic rule productions.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(axiom: [Module],
                state: [Module]?,
                newStateIndicators: [Bool]?,
                prng: RNGWrapper<PRNG>,
                rules: [Rule] = [])
    {
        self.axiom = axiom
        if let state = state {
            self.state = state
        } else {
            self.state = axiom
        }
        if let newStateIndicators = newStateIndicators {
            self.newStateIndicators = newStateIndicators
        } else {
            self.newStateIndicators = []
            for _ in axiom {
                self.newStateIndicators.append(true)
            }
        }
        self.prng = prng
        self.rules = rules
    }

    /// Returns a new L-system with the provided state.
    /// - Parameter state: The sequence of modules that represent the new state.
    /// - Returns: A new L-system with the updated state that has the same rules.
    ///
    /// This function is called from the common ``LindenmayerSystem`` protocol's default implementation to generate an updated
    /// L-system with a set of new modules.
    public func updatedLSystem(with state: [Module], newItemIndicators: [Bool]) -> Self {
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newItemIndicators, prng: prng, rules: rules)
    }

    public func reset() -> Self {
        prng.resetRNG(seed: prng.seed)
        return RandomContextualLSystem(axiom: axiom, state: nil, newStateIndicators: nil, prng: prng, rules: rules)
    }

    public func evolve(with seed: UInt64) -> Self {
        prng.resetRNG(seed: seed)
        return evolve()
    }
}

// - MARK: Rewrite rules including PRNG from the LSystem

public extension RandomContextualLSystem {
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithRNG<LC, DC, RC>(
        leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
        where evalClosure: @escaping (LC, DC, RC) -> Bool,
        produces produceClosure: @escaping (LC, DC, RC, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where LC: Module, DC: Module, RC: Module, PRNG: RandomNumberGenerator
    {
        let rule = RewriteRuleLeftDirectRightRNG(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            prng: prng,
            where: evalClosure,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithRNG<LC, DC, RC>(
        leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
        produces produceClosure: @escaping (LC, DC, RC, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where LC: Module, DC: Module, RC: Module, PRNG: RandomNumberGenerator
    {
        let rule = RewriteRuleLeftDirectRightRNG(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            prng: prng,
            where: nil,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithRNG<LC, DC>(
        leftContext: LC.Type, directContext: DC.Type,
        where evalClosure: @escaping (LC, DC) -> Bool,
        produces produceClosure: @escaping (LC, DC, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where LC: Module, DC: Module
    {
        let rule = RewriteRuleLeftDirectRNG(
            leftType: leftContext, directType: directContext,
            prng: prng,
            where: evalClosure,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithRNG<LC, DC>(
        leftContext: LC.Type, directContext: DC.Type,
        produces produceClosure: @escaping (LC, DC, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where LC: Module, DC: Module
    {
        let rule = RewriteRuleLeftDirectRNG(
            leftType: leftContext, directType: directContext,
            prng: prng,
            where: nil,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithRNG<DC, RC>(
        directContext: DC.Type, rightContext: RC.Type,
        where evalClosure: @escaping (DC, RC) -> Bool,
        produces produceClosure: @escaping (DC, RC, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where DC: Module, RC: Module
    {
        let rule = RewriteRuleDirectRightRNG(
            directType: directContext, rightType: rightContext,
            prng: prng,
            where: evalClosure,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithRNG<DC, RC>(
        directContext: DC.Type, rightContext: RC.Type,
        produces produceClosure: @escaping (DC, RC, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where DC: Module, RC: Module
    {
        let rule = RewriteRuleDirectRightRNG(
            directType: directContext, rightType: rightContext,
            prng: prng,
            where: nil,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithRNG<DC>(
        directContext: DC.Type,
        where evalClosure: @escaping (DC) -> Bool,
        produces produceClosure: @escaping (DC, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where DC: Module
    {
        let rule = RewriteRuleDirectRNG(
            directType: directContext,
            prng: prng,
            where: evalClosure,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithRNG<DC>(
        directContext: DC.Type,
        produces produceClosure: @escaping (DC, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where DC: Module
    {
        let rule = RewriteRuleDirectRNG(
            directType: directContext,
            prng: prng,
            where: nil,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }
}

// - MARK: Rewrite rules for the LSystem

public extension RandomContextualLSystem {
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<DC>(_ direct: DC.Type,
                     where evalClosure: @escaping (DC) -> Bool,
                     produces produceClosure: @escaping (DC) -> [Module]) -> Self where DC: Module
    {
        let newRule = RewriteRuleDirect(direct: direct, where: evalClosure, produce: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<DC>(_ direct: DC.Type,
                     produces produceClosure: @escaping (DC) -> [Module]) -> Self where DC: Module
    {
        let newRule = RewriteRuleDirect(direct: direct, where: nil, produce: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<LC, DC>(leftContext: LC.Type, directContext: DC.Type,
                         where evalClosure: @escaping (LC, DC) -> Bool,
                         produces produceClosure: @escaping (LC, DC) -> [Module]) -> Self where LC: Module, DC: Module
    {
        let newRule = RewriteRuleLeftDirect(leftType: leftContext, directType: directContext, where: evalClosure, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<LC, DC>(leftContext: LC.Type, directContext: DC.Type,
                         produces produceClosure: @escaping (LC, DC) -> [Module]) -> Self where LC: Module, DC: Module
    {
        let newRule = RewriteRuleLeftDirect(leftType: leftContext, directType: directContext, where: nil, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<DC, RC>(directContext: DC.Type, rightContext: RC.Type,
                         where evalClosure: @escaping (DC, RC) -> Bool,
                         produces produceClosure: @escaping (DC, RC) -> [Module]) -> Self where DC: Module, RC: Module
    {
        let newRule = RewriteRuleDirectRight(directType: directContext, rightType: rightContext, where: evalClosure, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<DC, RC>(directContext: DC.Type, rightContext: RC.Type,
                         produces produceClosure: @escaping (DC, RC) -> [Module]) -> Self where DC: Module, RC: Module
    {
        let newRule = RewriteRuleDirectRight(directType: directContext, rightType: rightContext, where: nil, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<LC, DC, RC>(leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
                             where evalClosure: @escaping (LC, DC, RC) -> Bool,
                             produces produceClosure: @escaping (LC, DC, RC) -> [Module]) -> Self where LC: Module, DC: Module, RC: Module
    {
        let newRule = RewriteRuleLeftDirectRight(leftType: leftContext, directType: directContext, rightType: rightContext, where: evalClosure, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<LC, DC, RC>(leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
                             produces produceClosure: @escaping (LC, DC, RC) -> [Module]) -> Self where LC: Module, DC: Module, RC: Module
    {
        let newRule = RewriteRuleLeftDirectRight(leftType: leftContext, directType: directContext, rightType: rightContext, where: nil, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return RandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, prng: prng, rules: newRuleSet)
    }
}

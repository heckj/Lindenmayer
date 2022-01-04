//
//  ParametericLSystem.swift
//  X5336
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation
import Squirrel3

/// A parameterized, stochastic Lindenmayer system.
///
/// For more information on the background of Lindenmayer systems, see [Wikipedia's L-System](https://en.wikipedia.org/wiki/L-system).
public struct LSystemDefinesRNG<PType, PRNG>: LSystem where PRNG: SeededRandomNumberGenerator, PType: AnyObject {
    /// The sequence of rules that the L-system uses to process and evolve its state.
    public let rules: [Rule]

    /// The parameters to provide to rules for evaluation and production.
    public var parameters: PType

    /// The current state of the LSystem, expressed as a sequence of elements that conform to Module.
    public let state: [Module]
    let axiom: [Module]

    var prng: RNGWrapper<PRNG>

    /// Creates a new Lindenmayer system from an initial state sequence and rules you provide.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - prng: A psuedo-random number generator to use for stochastic rule productions.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(axiom: [Module],
                state: [Module]?,
                parameters: PType,
                prng: RNGWrapper<PRNG>,
                rules: [Rule] = [])
    {
        // Using [axiom] instead of [] ensures that we always have a state
        // environment that can be evolved based on the rules available.
        self.axiom = axiom
        if let state = state {
            self.state = state
        } else {
            self.state = axiom
        }
        self.parameters = parameters
        self.prng = prng
        self.rules = rules
    }

    /// Returns a new L-system with the provided state.
    /// - Parameter state: The sequence of modules that represent the new state.
    /// - Returns: A new L-system with the updated state that has the same rules and parameters.
    public func updatedLSystem(with state: [Module]) -> Self {
        return LSystemDefinesRNG<PType, PRNG>(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: rules)
    }

    public func reset() -> Self {
        prng.resetRNG(seed: prng.seed)
        return LSystemDefinesRNG<PType, PRNG>(axiom: axiom, state: nil, parameters: parameters, prng: prng, rules: rules)
    }

    public func setSeed(seed: UInt64) {
        prng.resetRNG(seed: seed)
    }

    public mutating func setParameters(params: PType) {
        parameters = params
    }

    public mutating func set(seed: UInt64, params: PType) {
        prng.resetRNG(seed: seed)
        parameters = params
    }

    /// Processes the current state against its rules to provide an updated L-system
    ///
    /// The Lindermayer system iterates through the rules provided, applying the first rule that matches the state from the rule to the current state of the system.
    /// When applying the rule, the element that matched is replaced with what the rule returns from ``Rule/produce(_:)``.
    /// The types of errors that may be thrown is defined by any errors referenced and thrown within the set of rules you provide.
    /// - Returns: An updated Lindenmayer system.
    public func evolve() -> LSystem {
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
}

// - MARK: Rewrite rules including RNG and Parameters from the LSystem

public extension LSystemDefinesRNG {
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithAll<LC, DC, RC>(
        leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
        where evalClosure: @escaping (LC, DC, RC, PType) -> Bool,
        produces produceClosure: @escaping (LC, DC, RC, PType, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where LC: Module, DC: Module, RC: Module, PRNG: RandomNumberGenerator
    {
        let rule = RewriteRuleLeftDirectRightDefinesRNG(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            parameters: parameters,
            prng: prng,
            where: evalClosure,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithAll<LC, DC, RC>(
        leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
        produces produceClosure: @escaping (LC, DC, RC, PType, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where LC: Module, DC: Module, RC: Module, PRNG: RandomNumberGenerator
    {
        let rule = RewriteRuleLeftDirectRightDefinesRNG(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            parameters: parameters,
            prng: prng,
            where: nil,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithAll<LC, DC>(
        leftContext: LC.Type, directContext: DC.Type,
        where evalClosure: @escaping (LC, DC, PType) -> Bool,
        produces produceClosure: @escaping (LC, DC, PType, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where LC: Module, DC: Module
    {
        let rule = RewriteRuleLeftDirectDefinesRNG(
            leftType: leftContext, directType: directContext,
            parameters: parameters,
            prng: prng,
            where: evalClosure,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithAll<LC, DC>(
        leftContext: LC.Type, directContext: DC.Type,
        produces produceClosure: @escaping (LC, DC, PType, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where LC: Module, DC: Module
    {
        let rule = RewriteRuleLeftDirectDefinesRNG(
            leftType: leftContext, directType: directContext,
            parameters: parameters,
            prng: prng,
            where: nil,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithAll<DC, RC>(
        directContext: DC.Type, rightContext: RC.Type,
        where evalClosure: @escaping (DC, RC, PType) -> Bool,
        produces produceClosure: @escaping (DC, RC, PType, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where DC: Module, RC: Module, PRNG: RandomNumberGenerator
    {
        let rule = RewriteRuleDirectRightDefinesRNG(
            directType: directContext, rightType: rightContext,
            parameters: parameters,
            prng: prng,
            where: evalClosure,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithAll<DC, RC>(
        directContext: DC.Type, rightContext: RC.Type,
        produces produceClosure: @escaping (DC, RC, PType, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where DC: Module, RC: Module
    {
        let rule = RewriteRuleDirectRightDefinesRNG(
            directType: directContext, rightType: rightContext,
            parameters: parameters,
            prng: prng,
            where: nil,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithAll<DC>(
        directContext: DC.Type,
        where evalClosure: @escaping (DC, PType) -> Bool,
        produces produceClosure: @escaping (DC, PType, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where DC: Module
    {
        let rule = RewriteRuleDirectDefinesRNG(
            directType: directContext,
            parameters: parameters,
            prng: prng,
            where: evalClosure,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithAll<DC>(
        directContext: DC.Type,
        produces produceClosure: @escaping (DC, PType, RNGWrapper<PRNG>) -> [Module]
    ) -> Self
        where DC: Module
    {
        let rule = RewriteRuleDirectDefinesRNG(
            directType: directContext,
            parameters: parameters,
            prng: prng,
            where: nil,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
}

// - MARK: Rewrite rules including Parameters from the LSystem

public extension LSystemDefinesRNG {
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithParams<LC, DC, RC>(
        leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
        where evalClosure: @escaping (LC, DC, RC, PType) -> Bool,
        produces produceClosure: @escaping (LC, DC, RC, PType) -> [Module]
    ) -> Self
        where LC: Module, DC: Module, RC: Module
    {
        let rule = RewriteRuleLeftDirectRightDefines(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            parameters: parameters,
            where: evalClosure,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithParams<LC, DC, RC>(
        leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
        produces produceClosure: @escaping (LC, DC, RC, PType) -> [Module]
    ) -> Self
        where LC: Module, DC: Module, RC: Module
    {
        let rule = RewriteRuleLeftDirectRightDefines(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            parameters: parameters,
            where: nil,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithParams<LC, DC>(
        leftContext: LC.Type, directContext: DC.Type,
        where evalClosure: @escaping (LC, DC, PType) -> Bool,
        produces produceClosure: @escaping (LC, DC, PType) -> [Module]
    ) -> Self
        where LC: Module, DC: Module
    {
        let rule = RewriteRuleLeftDirectDefines(
            leftType: leftContext, directType: directContext,
            parameters: parameters,
            where: evalClosure,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithParams<LC, DC>(
        leftContext: LC.Type, directContext: DC.Type,
        produces produceClosure: @escaping (LC, DC, PType) -> [Module]
    ) -> Self
        where LC: Module, DC: Module
    {
        let rule = RewriteRuleLeftDirectDefines(
            leftType: leftContext, directType: directContext,
            parameters: parameters,
            where: nil,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithParams<DC, RC>(
        directContext: DC.Type, rightContext: RC.Type,
        where evalClosure: @escaping (DC, RC, PType) -> Bool,
        produces produceClosure: @escaping (DC, RC, PType) -> [Module]
    ) -> Self
        where DC: Module, RC: Module
    {
        let rule = RewriteRuleDirectRightDefines(
            directType: directContext, rightType: rightContext,
            parameters: parameters,
            where: evalClosure,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithParams<DC, RC>(
        directContext: DC.Type, rightContext: RC.Type,
        produces produceClosure: @escaping (DC, RC, PType) -> [Module]
    ) -> Self
        where DC: Module, RC: Module
    {
        let rule = RewriteRuleDirectRightDefines(
            directType: directContext, rightType: rightContext,
            parameters: parameters,
            where: nil,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithParams<DC>(
        directContext: DC.Type,
        where evalClosure: @escaping (DC, PType) -> Bool,
        produces produceClosure: @escaping (DC, PType) -> [Module]
    ) -> Self
        where DC: Module
    {
        let rule = RewriteRuleDirectDefines(
            directType: directContext,
            parameters: parameters,
            where: evalClosure,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    func rewriteWithParams<DC>(
        directContext: DC.Type,
        produces produceClosure: @escaping (DC, PType) -> [Module]
    ) -> Self
        where DC: Module
    {
        let rule = RewriteRuleDirectDefines(
            directType: directContext,
            parameters: parameters,
            where: nil,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
}

// - MARK: Rewrite rules including PRNG from the LSystem

public extension LSystemDefinesRNG {
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
}

public extension LSystemDefinesRNG {
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return LSystemDefinesRNG(axiom: axiom, state: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
}

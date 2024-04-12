//
//  ParameterizedRandomContextualLSystem.swift
//
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation

/// A parameterized, stochastic Lindenmayer system.
///
/// A parameterized, stochastic Lindenmayer system uses both external parameters and a seed-able random number generator, exposing both to the rules you create.
/// If you want to create an L-system doesn't use parameters or a seed-able random number generator, use ``ContextualLSystem``.
/// If you want to create an L-system that doesn't use a set of external parameters, but does include a seed-able random number generator, use ``RandomContextualLSystem``.
///
/// For more information on the background of Lindenmayer systems, see [Wikipedia's L-System](https://en.wikipedia.org/wiki/L-system).
///
/// ## Topics
///
/// ### Creating and Updating L-systems
///
/// - ``ParameterizedRandomContextualLSystem/init(axiom:state:newStateIndicators:parameters:prng:rules:)``
/// - ``ParameterizedRandomContextualLSystem/updatedLSystem(with:newItemIndicators:)``
///
/// ### Inspecting L-systems
///
/// - ``ParameterizedRandomContextualLSystem/state``
/// - ``ParameterizedRandomContextualLSystem/state(at:)``
/// - ``ParameterizedRandomContextualLSystem/newStateIndicators``
///
/// ### Adding Rules to an L-system
///
/// - ``ParameterizedRandomContextualLSystem/rewrite(_:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewrite(_:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithRNG(directContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithRNG(directContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithParams(directContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithParams(directContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithAll(directContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithAll(directContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rules``
///
/// ### Adding Contextual Rules to an L-system
///
/// - ``ParameterizedRandomContextualLSystem/rewrite(leftContext:directContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewrite(directContext:rightContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewrite(leftContext:directContext:rightContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithRNG(leftContext:directContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithRNG(directContext:rightContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithRNG(leftContext:directContext:rightContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithParams(leftContext:directContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithParams(directContext:rightContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithParams(leftContext:directContext:rightContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithAll(leftContext:directContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithAll(directContext:rightContext:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithAll(leftContext:directContext:rightContext:produces:)``
///
/// ### Adding Contextual Rules with an evaluation closure to an L-system
///
/// - ``ParameterizedRandomContextualLSystem/rewrite(leftContext:directContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewrite(directContext:rightContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewrite(leftContext:directContext:rightContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithRNG(leftContext:directContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithRNG(directContext:rightContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithRNG(leftContext:directContext:rightContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithParams(leftContext:directContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithParams(directContext:rightContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithParams(leftContext:directContext:rightContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithAll(leftContext:directContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithAll(directContext:rightContext:where:produces:)``
/// - ``ParameterizedRandomContextualLSystem/rewriteWithAll(leftContext:directContext:rightContext:where:produces:)``
///
/// ### Updating the L-system
///
/// - ``ParameterizedRandomContextualLSystem/setSeed(seed:)``
/// - ``ParameterizedRandomContextualLSystem/setParameters(params:)``
/// - ``ParameterizedRandomContextualLSystem/set(seed:params:)``
///
/// ### Evolving the L-system
///
/// - ``ParameterizedRandomContextualLSystem/evolve()``
/// - ``ParameterizedRandomContextualLSystem/evolved(iterations:)``
///
/// ### Resetting L-systems to their initial state
///
/// - ``ParameterizedRandomContextualLSystem/reset()``
///
public struct ParameterizedRandomContextualLSystem<PType, PRNG>: LindenmayerSystem where PRNG: SeededRandomNumberGenerator, PType: Sendable {
    let axiom: [Module]

    /// The current state of the L-system, expressed as a sequence of elements that conform to Module.
    public let state: [Module]

    /// An array of Boolean values that indicate if the state in the L-system was newly created in the evolution.
    ///
    /// This array is primarily used for debugging purposes
    public let newStateIndicators: [Bool]

    /// The parameters to provide to rules for evaluation and production.
    let parameters: PType
    let initialParameters: PType

    let prng: RNGWrapper<PRNG>

    /// The sequence of rules that the L-system uses to process and evolve its state.
    public let rules: [Rule]

    /// Creates a new Lindenmayer system from an initial state sequence and rules you provide.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - prng: A psuedo-random number generator to use for stochastic rule productions.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    ///
    /// Convenient initializers for creating contextual L-systems uses ``LSystem``, calling ``Lindenmayer/LSystem/create(_:with:using:)-1nce9``, or ``Lindenmayer/LSystem/create(_:with:using:)-2nwqc``
    public init(axiom: [Module],
                state: [Module]?,
                newStateIndicators: [Bool]?,
                parameters: PType,
                prng: RNGWrapper<PRNG>,
                rules: [Rule] = [])
    {
        // Using [axiom] instead of [] ensures that we always have a state
        // environment that can be evolved based on the rules available.
        initialParameters = parameters
        self.axiom = axiom
        if let state {
            self.state = state
        } else {
            self.state = axiom
        }
        if let newStateIndicators {
            self.newStateIndicators = newStateIndicators
        } else {
            var stateIndicators: [Bool] = []
            for _ in axiom {
                stateIndicators.append(true)
            }
            self.newStateIndicators = stateIndicators
        }
        self.parameters = parameters
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
        ParameterizedRandomContextualLSystem<PType, PRNG>(axiom: axiom, state: state, newStateIndicators: newItemIndicators, parameters: parameters, prng: prng, rules: rules)
    }

    public func reset() -> Self {
        prng.resetRNG(seed: prng.seed)
        return ParameterizedRandomContextualLSystem<PType, PRNG>(axiom: axiom, state: nil, newStateIndicators: nil, parameters: parameters, prng: prng, rules: rules)
    }

    /// Sets the seed for the pseudo-random number generator to the value you provide.
    /// - Parameter seed: The seed value to set within the pseudo-random generator.
    /// - Returns: The L-system with the seed value updated.
    @discardableResult
    public func setSeed(seed: UInt64) -> Self {
        prng.resetRNG(seed: seed)
        return self
    }

    /// Sets the parameters for the L-system to the value you provide.
    /// - Parameter params: The updated value for the parameter type of the L-system.
    /// - Returns: The L-system with the parameters value updated.
    @discardableResult
    public func setParameters(params: PType) -> Self {
        Self(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: params, prng: prng, rules: rules)
    }

    /// Sets the seed for the pseudo-random number generator and the parameters for the L-system to the value you provide.
    /// - Parameters:
    ///   - seed: The seed value to set within the pseudo-random generator.
    ///   - params: The updated value for the parameter type of the L-system.
    /// - Returns: The L-system with the seed value and parameters value updated.
    @discardableResult
    public func set(seed: UInt64) -> Self {
        prng.resetRNG(seed: seed)
        return self
    }
}

// - MARK: Rewrite rules including RNG and Parameters from the LSystem

public extension ParameterizedRandomContextualLSystem {
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
        where LC: Module, DC: Module, RC: Module
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        where LC: Module, DC: Module, RC: Module
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        where DC: Module, RC: Module
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
    }
}

// - MARK: Rewrite rules including Parameters from the LSystem

public extension ParameterizedRandomContextualLSystem {
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
    }
}

// - MARK: Rewrite rules including PRNG from the LSystem

public extension ParameterizedRandomContextualLSystem {
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
        where LC: Module, DC: Module, RC: Module
    {
        let rule = RewriteRuleLeftDirectRightRNG(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            prng: prng,
            where: evalClosure,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        where LC: Module, DC: Module, RC: Module
    {
        let rule = RewriteRuleLeftDirectRightRNG(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            prng: prng,
            where: nil,
            produces: produceClosure
        )
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
    }
}

public extension ParameterizedRandomContextualLSystem {
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
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
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: state, newStateIndicators: newStateIndicators, parameters: parameters, prng: prng, rules: newRuleSet)
    }
}

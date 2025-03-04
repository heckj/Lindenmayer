//
//  ContextualLSystem.swift
//
//
//  Created by Joseph Heck on 1/1/22.
//

import Foundation

/// A basic Lindenmayer system.
///
/// The basic Lindenmayer system doesn't use external parameters or a seed-able random number generator within its rules.
/// If you want to create an L-system that uses a seed-able random number generator, use ``RandomContextualLSystem``.
/// If you want to create an L-system that uses a set of external parameters and a seed-able random number generator, use ``ParameterizedRandomContextualLSystem``.
///
/// For more information on the background of Lindenmayer systems, see [Wikipedia's L-System](https://en.wikipedia.org/wiki/L-system).
///
/// ## Topics
///
/// ### Creating and Updating L-systems
///
/// - ``ContextualLSystem/init(_:state:newStateIndicators:rules:)``
/// - ``ContextualLSystem/updatedLSystem(with:newItemIndicators:)``
///
/// ### Inspecting L-systems
///
/// - ``ContextualLSystem/state``
/// - ``ContextualLSystem/state(at:)``
/// - ``ContextualLSystem/newStateIndicators``
///
/// ### Adding Rules to an L-system
///
/// - ``ContextualLSystem/rewrite(_:produces:)``
/// - ``ContextualLSystem/rewrite(_:where:produces:)``
/// - ``ContextualLSystem/rules``
///
/// ### Adding Contextual Rules to an L-system
///
/// - ``ContextualLSystem/rewrite(leftContext:directContext:produces:)``
/// - ``ContextualLSystem/rewrite(directContext:rightContext:produces:)``
/// - ``ContextualLSystem/rewrite(leftContext:directContext:rightContext:produces:)``
///
/// ### Adding Contextual Rules with an evaluation closure to an L-system
///
/// - ``ContextualLSystem/rewrite(leftContext:directContext:where:produces:)``
/// - ``ContextualLSystem/rewrite(directContext:rightContext:where:produces:)``
/// - ``ContextualLSystem/rewrite(leftContext:directContext:rightContext:where:produces:)``
///
/// ### Evolving the L-system
///
/// - ``ContextualLSystem/evolve()``
/// - ``ContextualLSystem/evolved(iterations:)``
///
/// ### Resetting L-systems to their initial state
///
/// - ``ContextualLSystem/reset()``
public struct ContextualLSystem: LindenmayerSystem {
    let axiom: [any Module]

    /// The sequence of modules that represents the current state of the L-system.
    public let state: [any Module]

    /// An array of Boolean values that indicate if the state in the L-system was newly created in the evolution.
    ///
    /// This array is primarily used for debugging purposes
    public let newStateIndicators: [Bool]

    /// The sequence of rules that the L-system uses to process and evolve its state.
    public let rules: [any Rule]

    /// Creates a new Lindenmayer system from an initial state sequence and rules you provide.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - prng: A psuedo-random number generator to use for stochastic rule productions.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    ///
    /// Convenient initializers for creating contextual L-systems uses ``LSystem``, calling ``LSystem/create(_:)-632a3``, or ``LSystem/create(_:)-12ubu``.
    /// For example:
    /// ```
    /// struct A: Module {
    ///     public var name = "A"
    /// }
    ///
    /// let algae = Lsystem.create(A())
    /// ```
    public init(_ axiom: [any Module],
                state: [any Module]?,
                newStateIndicators: [Bool]?,
                rules: [any Rule] = [])
    {
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
        self.rules = rules
    }

    /// Returns a new L-system with the provided state.
    /// - Parameter state: The sequence of modules that represent the new state.
    /// - Returns: A new L-system with the updated state that has the same rules.
    ///
    /// This function is called from the common ``LindenmayerSystem`` protocol's default implementation to generate an updated
    /// L-system with a set of new modules.
    public func updatedLSystem(with state: [any Module], newItemIndicators: [Bool]) -> Self {
        ContextualLSystem(axiom, state: state, newStateIndicators: newItemIndicators, rules: rules)
    }

    /// Resets the L-system to it's initial state, wiping out an existing state while keeping the rules.
    /// - Returns: A new L-system with it's state reset to the initial state you set when you created the L-system.
    public func reset() -> Self {
        ContextualLSystem(axiom, state: nil, newStateIndicators: newStateIndicators, rules: rules)
    }
}

public extension ContextualLSystem {
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<DC>(_ direct: DC.Type,
                     where evalClosure: @Sendable @escaping (DC) -> Bool,
                     produces produceClosure: @Sendable @escaping (DC) -> [any Module]) -> Self where DC: Module
    {
        let newRule = RewriteRuleDirect(direct: direct, where: evalClosure, produce: produceClosure)
        var newRuleSet: [any Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return ContextualLSystem(axiom, state: state, newStateIndicators: newStateIndicators, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<DC>(_ direct: DC.Type,
                     produces produceClosure: @Sendable @escaping (DC) -> [any Module]) -> Self where DC: Module
    {
        let newRule = RewriteRuleDirect(direct: direct, where: nil, produce: produceClosure)
        var newRuleSet: [any Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return ContextualLSystem(axiom, state: state, newStateIndicators: newStateIndicators, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<LC, DC>(leftContext: LC.Type, directContext: DC.Type,
                         where evalClosure: @Sendable @escaping (LC, DC) -> Bool,
                         produces produceClosure: @Sendable @escaping (LC, DC) -> [any Module]) -> Self where LC: Module, DC: Module
    {
        let newRule = RewriteRuleLeftDirect(leftType: leftContext, directType: directContext, where: evalClosure, produces: produceClosure)
        var newRuleSet: [any Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return ContextualLSystem(axiom, state: state, newStateIndicators: newStateIndicators, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<LC, DC>(leftContext: LC.Type, directContext: DC.Type,
                         produces produceClosure: @Sendable @escaping (LC, DC) -> [any Module]) -> Self where LC: Module, DC: Module
    {
        let newRule = RewriteRuleLeftDirect(leftType: leftContext, directType: directContext, where: nil, produces: produceClosure)
        var newRuleSet: [any Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return ContextualLSystem(axiom, state: state, newStateIndicators: newStateIndicators, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<DC, RC>(directContext: DC.Type, rightContext: RC.Type,
                         where evalClosure: @Sendable @escaping (DC, RC) -> Bool,
                         produces produceClosure: @Sendable @escaping (DC, RC) -> [any Module]) -> Self where DC: Module, RC: Module
    {
        let newRule = RewriteRuleDirectRight(directType: directContext, rightType: rightContext, where: evalClosure, produces: produceClosure)
        var newRuleSet: [any Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return ContextualLSystem(axiom, state: state, newStateIndicators: newStateIndicators, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<DC, RC>(directContext: DC.Type, rightContext: RC.Type,
                         produces produceClosure: @Sendable @escaping (DC, RC) -> [any Module]) -> Self where DC: Module, RC: Module
    {
        let newRule = RewriteRuleDirectRight(directType: directContext, rightType: rightContext, where: nil, produces: produceClosure)
        var newRuleSet: [any Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return ContextualLSystem(axiom, state: state, newStateIndicators: newStateIndicators, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<LC, DC, RC>(leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
                             where evalClosure: @Sendable @escaping (LC, DC, RC) -> Bool,
                             produces produceClosure: @Sendable @escaping (LC, DC, RC) -> [any Module]) -> Self where LC: Module, DC: Module, RC: Module
    {
        let newRule = RewriteRuleLeftDirectRight(leftType: leftContext, directType: directContext, rightType: rightContext, where: evalClosure, produces: produceClosure)
        var newRuleSet: [any Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return ContextualLSystem(axiom, state: state, newStateIndicators: newStateIndicators, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    func rewrite<LC, DC, RC>(leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
                             produces produceClosure: @Sendable @escaping (LC, DC, RC) -> [any Module]) -> Self where LC: Module, DC: Module, RC: Module
    {
        let newRule = RewriteRuleLeftDirectRight(leftType: leftContext, directType: directContext, rightType: rightContext, where: nil, produces: produceClosure)
        var newRuleSet: [any Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return ContextualLSystem(axiom, state: state, newStateIndicators: newStateIndicators, rules: newRuleSet)
    }
}

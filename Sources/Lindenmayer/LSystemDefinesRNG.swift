//
//  ParametericLSystem.swift
//  X5336
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation

/// A parameterized, stochastic Lindenmayer system.
///
/// For more information on the background of Lindenmayer systems, see [Wikipedia's L-System](https://en.wikipedia.org/wiki/L-system).
public struct LSystemDefinesRNG<PType, PRNG>: LSystem where PRNG: RandomNumberGenerator {
    
    /// The sequence of rules that the L-system uses to process and evolve its state.
    public let rules: [Rule]

    /// The parameters to provide to rules for evaluation and production.
    public let parameters: PType

    /// The current state of the LSystem, expressed as a sequence of elements that conform to Module.
    public let state: [Module]

    var prng: PRNG

    /// Creates a new Lindenmayer system from an initial state sequence and rules you provide.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - prng: A psuedo-random number generator to use for stochastic rule productions.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(axiom: [Module],
                parameters: PType,
                prng: PRNG,
                rules: [Rule] = [])
    {
        // Using [axiom] instead of [] ensures that we always have a state
        // environment that can be evolved based on the rules available.
        state = axiom
        self.parameters = parameters
        self.prng = prng
        self.rules = rules
    }

    /// Returns a new L-system with the provided state.
    /// - Parameter state: The sequence of modules that represent the new state.
    /// - Returns: A new L-system with the updated state that has the same rules and parameters.
    public func updatedLSystem(with state: [Module]) -> LSystem {
        return LSystemDefinesRNG<PType, PRNG>(axiom: state, parameters: parameters, prng: prng, rules: rules)
    }
    
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - singleModuleProduce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithAll(_ direct: Module.Type, _ singleModuleProduce: @escaping (Module, PType, Chaos<PRNG>) throws -> [Module]) -> Self {
        let newRule = BasicRuleDefinesRNG(direct, params: self.parameters, prng: self.prng, singleModuleProduce)
        var newRuleSet: [Rule] = self.rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: self.state, parameters: self.parameters, prng: self.prng, rules: newRuleSet)
    }
    
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithAll(_ left: Module.Type?, _ direct: Module.Type, _ right: Module.Type?, _ produce: @escaping (Module?, Module, Module?, PType, Chaos<PRNG>) throws -> [Module]) -> Self {
        let newRule = BasicRuleDefinesRNG(left, direct, right, params: self.parameters, prng: self.prng, produce)
        var newRuleSet: [Rule] = self.rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: self.state, parameters: self.parameters, prng: self.prng, rules: newRuleSet)
    }

    public func rewriteWithParams(_ direct: Module.Type, _ produce: @escaping (Module?, Module, Module?, PType) throws -> [Module]) -> Self {
        let newRule = BasicRuleDefines(nil, direct, nil, params: self.parameters, produce)
        var newRuleSet: [Rule] = self.rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: self.state, parameters: self.parameters, prng: self.prng, rules: newRuleSet)
    }

    public func rewriteWithParams(_ left: Module.Type?, _ direct: Module.Type, _ right: Module.Type?, _ produce: @escaping (Module?, Module, Module?, PType) throws -> [Module]) -> Self {
        let newRule = BasicRuleDefines(left, direct, right, params: self.parameters, produce)
        var newRuleSet: [Rule] = self.rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: self.state, parameters: self.parameters, prng: self.prng, rules: newRuleSet)
    }


    public func rewriteWithRNG(_ left: Module.Type?, _ direct: Module.Type, _ right: Module.Type?, _ produce: @escaping (Module?, Module, Module?, Chaos<PRNG>) throws -> [Module]) -> Self {
        let newRule = BasicRuleRNG(left, direct, right, prng: self.prng, produce)
        var newRuleSet: [Rule] = self.rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: self.state, parameters: self.parameters, prng: self.prng, rules: newRuleSet)
    }

    public func rewriteWithRNG(_ direct: Module.Type, _ produce: @escaping (Module, Chaos<PRNG>) throws -> [Module]) -> Self {
        let newRule = BasicRuleRNG(direct, prng: self.prng, produce)
        var newRuleSet: [Rule] = self.rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: self.state, parameters: self.parameters, prng: self.prng, rules: newRuleSet)
    }

    public func rewrite(_ direct: Module.Type, _ produce: @escaping (Module) throws -> [Module]) -> Self {
        let newRule = BasicRule(direct, produce)
        var newRuleSet: [Rule] = self.rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: self.state, parameters: self.parameters, prng: self.prng, rules: newRuleSet)
    }

    public func rewrite(_ left: Module.Type?, _ direct: Module.Type, _ right: Module.Type?, _ produce: @escaping (Module?, Module, Module?) throws -> [Module]) -> Self {
        let newRule = BasicRule(left, direct, right, produce)
        var newRuleSet: [Rule] = self.rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: self.state, parameters: self.parameters, prng: self.prng, rules: newRuleSet)
    }
}

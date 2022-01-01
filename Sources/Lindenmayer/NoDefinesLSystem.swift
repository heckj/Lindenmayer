//
//  NonParametericLSystem.swift
//
//
//  Created by Joseph Heck on 12/28/21.
//

import Foundation

/// A stochastic Lindenmayer system.
///
/// For more information on the background of Lindenmayer systems, see [Wikipedia's L-System](https://en.wikipedia.org/wiki/L-system).
public struct NoDefinesLSystem<PRNG>: LSystem where PRNG: RandomNumberGenerator {
    /// The sequence of modules that represents the current state of the L-system.
    public let state: [Module]

    var prng: Chaos<PRNG>

    /// The sequence of rules that the L-system uses to process and evolve its state.
    public var rules: [Rule]

    /// Creates a new Lindenmayer system from an initial state and rules you provide.
    /// - Parameters:
    ///   - axiom: A module that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - prng: A psuedo-random number generator to use for stochastic rule productions.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(_ axiom: Module,
                prng: PRNG = HasherPRNG(seed: 42) as! PRNG,
                rules: [Rule] = [])
    {
        state = [axiom]
        self.prng = Chaos(prng)
        self.rules = rules
    }

    /// Creates a new Lindenmayer system from an initial state sequence and rules you provide.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - prng: A psuedo-random number generator to use for stochastic rule productions.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(_ axiom: [Module],
                prng: PRNG = HasherPRNG(seed: 42) as! PRNG,
                rules: [Rule] = [])
    {
        state = axiom
        self.prng = Chaos(prng)
        self.rules = rules
    }

    /// Returns a new L-system with the provided state.
    /// - Parameter state: The sequence of modules that represent the new state.
    /// - Returns: A new L-system with the updated state that has the same rules.
    public func updatedLSystem(with state: [Module]) -> LSystem {
        return NoDefinesLSystem(state, rules: rules)
    }
    
    public func rewrite(_ direct: Module.Type, _ singleModuleProduce: @escaping (Module, Chaos<PRNG>) throws -> [Module]) -> Self {
        let newRule = NoDefinesRule(direct, prng: self.prng, singleModuleProduce)
        var newRuleSet: [Rule] = self.rules
        newRuleSet.append(contentsOf: [newRule])
        return NoDefinesLSystem(self.state, prng: self.prng._prng, rules: newRuleSet)
    }

    public func rewrite(_ left: Module.Type?, _ direct: Module.Type, _ right: Module.Type?, _ multiModuleProduce: @escaping (Module?, Module, Module?, Chaos<PRNG>) throws -> [Module]) -> Self {
        let newRule = NoDefinesRule(left, direct, right, prng: self.prng, multiModuleProduce)
        var newRuleSet: [Rule] = self.rules
        newRuleSet.append(contentsOf: [newRule])
        return NoDefinesLSystem(self.state, prng: self.prng._prng, rules: newRuleSet)
    }

}

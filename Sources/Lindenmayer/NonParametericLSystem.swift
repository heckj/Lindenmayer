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
public struct NonParametericLSystem: LSystem {
    /// The sequence of modules that represents the current state of the L-system.
    public let state: [Module]

    var prng: SeededPsuedoRandomNumberGenerator

    /// The sequence of rules that the L-system uses to process and evolve its state.
    public let rules: [Rule]

    /// Creates a new Lindenmayer system from an initial state and rules you provide.
    /// - Parameters:
    ///   - axiom: A module that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - prng: A psuedo-random number generator to use for stochastic rule productions.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(_ axiom: Module,
                prng: SeededPsuedoRandomNumberGenerator = HasherPRNG(seed: 42),
                rules: [Rule] = [])
    {
        state = [axiom]
        self.prng = prng
        self.rules = rules
    }

    /// Creates a new Lindenmayer system from an initial state sequence and rules you provide.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - prng: A psuedo-random number generator to use for stochastic rule productions.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(_ axiom: [Module],
                prng: SeededPsuedoRandomNumberGenerator = HasherPRNG(seed: 42),
                rules: [Rule] = [])
    {
        state = axiom
        self.prng = prng
        self.rules = rules
    }

    /// Returns a new L-system with the provided state.
    /// - Parameter state: The sequence of modules that represent the new state.
    /// - Returns: A new L-system with the updated state that has the same rules.
    public func updatedLSystem(with state: [Module]) -> LSystem {
        return NonParametericLSystem(state, rules: rules)
    }
}

//
//  LSystem.swift
//  X5336
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation

/// An instance of a parameterized, stochastic Lindenmayer system.
///
/// For more information on the background of Lindenmayer systems, see [Wikipedia's L-System](https://en.wikipedia.org/wiki/L-system).
public struct ParameterizedLSystem<PType>: LSystem {
    /// The sequence of rules that the L-system uses to process and evolve its state.
    public let rules: [Rule]

    /// The parameters to provide to rules for evaluation and production.
    public let parameters: PType

    /// The current state of the LSystem, expressed as a sequence of elements that conform to Module.
    public let state: [Module]

    var prng: SeededPsuedoRandomNumberGenerator

    /// Creates a new Lindenmayer system from an initial state and rules you provide.
    /// - Parameters:
    ///   - axiom: A module that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - prng: A psuedo-random number generator to use for stochastic rule productions.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(axiom: Module,
                parameters: PType,
                prng: SeededPsuedoRandomNumberGenerator = HasherPRNG(seed: 42),
                rules: [Rule] = [])
    {
        // Using [axiom] instead of [] ensures that we always have a state
        // environment that can be evolved based on the rules available.
        state = [axiom]
        self.parameters = parameters
        self.prng = prng
        self.rules = rules
    }

    /// Creates a new Lindenmayer system from an initial state sequence and rules you provide.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - prng: A psuedo-random number generator to use for stochastic rule productions.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(axiom: [Module],
                parameters: PType,
                prng: SeededPsuedoRandomNumberGenerator = HasherPRNG(seed: 42),
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
        return ParameterizedLSystem<PType>(axiom: state, parameters: parameters, prng: prng, rules: rules)
    }
}

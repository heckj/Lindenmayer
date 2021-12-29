//
//  LSystem.swift
//  X5336
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation

// - likewise here in LSystem it feels like I could really use a factory method here to hide the specific types
// that I'm creating to allow for easier construction of the lsystems as I'm creating new Lsystems...

/// An instance of a parameterized, stochastic Lindenmayer system.
///
/// For more information on the background of Lindenmayer systems, see [Wikipedia's L-System](https://en.wikipedia.org/wiki/L-system).
public struct ParameterizedLSystem<PType>: LSystemProtocol {
    public let rules: [Rule]

    public let parameters: AltParams<PType>

    /// The current state of the LSystem, expressed as a sequence of elements that conform to Module.
    public let state: [Module]

    /// Creates a new Lindenmayer system from an initial state and rules you provide.
    /// - Parameters:
    ///   - axiom: A module that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(_ axiom: Module, parameters: AltParams<PType>, rules: [Rule] = []) {
        // Using [axiom] instead of [] ensures that we always have a state
        // environment that can be evolved based on the rules available.
        state = [axiom]
        self.rules = rules
        self.parameters = parameters
    }

    /// Creates a new Lindenmayer system from an initial state sequence and rules you provide.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(_ axiom: [Module], parameters: AltParams<PType>, rules: [Rule] = []) {
        // Using [axiom] instead of [] ensures that we always have a state
        // environment that can be evolved based on the rules available.
        state = axiom
        self.rules = rules
        self.parameters = parameters
    }

    public func produceFromRule(_ rule: ParameterizedRule<PType>, from moduleSet: ModuleSet) throws -> [Module] {
        return try rule.produce(moduleSet)
    }
    
    public func updatedLSystem(with state: [Module]) -> LSystemProtocol {
        return ParameterizedLSystem<PType>(state, parameters: self.parameters, rules: self.rules)
    }

}

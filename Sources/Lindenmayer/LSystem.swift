//
//  LSystem.swift
//
//
//  Created by Joseph Heck on 1/1/22.
//

import Foundation
import Squirrel3

/// A type that provides convenient initializers for L-systems.
///
/// The basic L-system is a ``ContextualLSystem``, which you create with a starting point made up of one or more instances of a type that conforms to ``Module``.
///
/// The type ``RandomContextualLSystem`` includes a seed-able random number generator, to support including randomness in the rule rewriting.
/// The and seed-able nature of the random number generator allows the L-system to be explicitly deterministic.
/// To create an L-system that includes a random number generator, call `create(_:with:)` with an instance of a seed-able random number generator.
/// If you pass `nil`, the L-system will be created with a pseudo-random number generator using the [`Squirrel3`](https://github.com/heckj/Squirrel3) swift package.
///
/// The type ``ParameterizedRandomContextualLSystem`` includes a seed-able random number generator as well as a type that you provide that gets provided to the closures you write when defining rules.
/// This type can contain any number of parameters that you can use when within the closures for your rules, and makes a convenient container for common values used in multiple rules.
public enum LSystem {
    /// Creates a new Lindenmayer system from an initial state.
    /// - Parameters:
    ///   - axiom: An initial module that represents the initial state of the Lindenmayer system..
    public static func create(_ axiom: Module) -> ContextualLSystem {
        return ContextualLSystem([axiom], state: nil, newStateIndicators: nil)
    }

    /// Creates a new Lindenmayer system from an initial state.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    public static func create(_ axiom: [Module]) -> ContextualLSystem {
        return ContextualLSystem(axiom, state: nil, newStateIndicators: nil)
    }

    /// Creates a new Lindenmayer system from an initial state and using the random number generator you provide.
    /// - Parameters:
    ///   - axiom: An initial module that represents the initial state of the Lindenmayer system..
    ///   - prng: An optional psuedo-random number generator to use for randomness in rule productions.
    public static func create<RNGType>(_ axiom: Module, with prng: RNGType?) -> RandomContextualLSystem<RNGType> {
        if let prng = prng {
            return RandomContextualLSystem(axiom: [axiom], state: nil, newStateIndicators: nil, prng: RNGWrapper(prng))
        }
        return RandomContextualLSystem(axiom: [axiom], state: nil, newStateIndicators: nil, prng: RNGWrapper(PRNG(seed: 42) as! RNGType))
    }

    /// Creates a new Lindenmayer system from an initial state and using the random number generator you provide..
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - prng: An optional psuedo-random number generator to use for for randomness in rule productions.
    public static func create<RNGType>(_ axiom: [Module], with prng: RNGType?) -> RandomContextualLSystem<RNGType> {
        if let prng = prng {
            return RandomContextualLSystem(axiom: axiom, state: nil, newStateIndicators: nil, prng: RNGWrapper(prng))
        }
        return RandomContextualLSystem(axiom: axiom, state: nil, newStateIndicators: nil, prng: RNGWrapper(PRNG(seed: 42) as! RNGType))
    }

    /// Creates a new Lindenmayer system from an initial state, using the random number generator and parameter instance that you provide.
    /// - Parameters:
    ///   - axiom: An initial module that represents the initial state of the Lindenmayer system.
    ///   - prng: An optional psuedo-random number generator to use for for randomness in rule productions.
    ///   - parameters: An instance of type you provide that the L-system provides to the rules you create for use as parameters.
    public static func create<PType, RNGType>(_ axiom: Module, with prng: RNGType?, using parameters: PType) -> ParameterizedRandomContextualLSystem<PType, RNGType> {
        if let prng = prng {
            return ParameterizedRandomContextualLSystem(axiom: [axiom], state: nil, newStateIndicators: nil, parameters: ParametersWrapper(parameters), prng: RNGWrapper(prng), rules: [])
        }
        return ParameterizedRandomContextualLSystem(axiom: [axiom], state: nil, newStateIndicators: nil, parameters: ParametersWrapper(parameters), prng: RNGWrapper(PRNG(seed: 42) as! RNGType), rules: [])
    }

    /// Creates a new Lindenmayer system from an initial state, using the random number generator and parameter instance that you provide.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - prng: An optional psuedo-random number generator to use for for randomness in rule productions.
    ///   - parameters: An instance of type you provide that the L-system provides to the rules you create for use as parameters.
    public static func create<PType, RNGType>(_ axiom: [Module], with prng: RNGType?, using parameters: PType) -> ParameterizedRandomContextualLSystem<PType, RNGType> {
        if let prng = prng {
            return ParameterizedRandomContextualLSystem(axiom: axiom, state: nil, newStateIndicators: nil, parameters: ParametersWrapper(parameters), prng: RNGWrapper(prng), rules: [])
        }
        return ParameterizedRandomContextualLSystem(axiom: axiom, state: nil, newStateIndicators: nil, parameters: ParametersWrapper(parameters), prng: RNGWrapper(PRNG(seed: 42) as! RNGType), rules: [])
    }
}

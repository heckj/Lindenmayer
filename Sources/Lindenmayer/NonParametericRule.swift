//
//  NonParametericRule.swift
//
//
//  Created by Joseph Heck on 12/28/21.
//

import Foundation

/// A rule represents a potential re-writing match to elements within the L-systems state and the closure that provides the elements to be used for the new state elements.
public struct NonParametericRule: Rule {
    /// The signature of the produce closure that provides a set of up to three modules and expects a sequence of modules.
    public typealias multiMatchProducesModuleList = (Module?, Module, Module?) throws -> [Module]
    /// The signature of the produce closure that provides a module and expects a sequence of modules.
    public typealias singleMatchProducesList = (Module) throws -> [Module]

    /// The closure that provides the L-system state for the current, previous, and next nodes in the state sequence and expects an array of state elements with which to replace the current state.
    public let produceClosure: multiMatchProducesModuleList

    /// The L-system uses the types of these modules to determine is this rule should be applied and re-write the current state.
    public let matchset: (Module.Type?, Module.Type, Module.Type?)

    /// A psuedo-random number generator to use for stochastic rule productions.
    var prng: SeededPsuedoRandomNumberGenerator = HasherPRNG(seed: 42)

    /// Creates a new rule with the extended context and closures you provide that result in a list of state elements.
    /// - Parameters:
    ///   - left: The type of the L-system state element prior to the current element that the rule evaluates.
    ///   - direct: The type of the L-system state element that the rule evaluates.
    ///   - right: The type of the L-system state element following the current element that the rule evaluates.
    ///   - prng: An optional psuedo-random number generator to use for stochastic rule productions.
    ///   - produceClosure: A closure that produces an array of L-system state elements to use in place of the current element.
    public init(_ left: Module.Type?, _ direct: Module.Type, _ right: Module.Type?,
                prng: SeededPsuedoRandomNumberGenerator? = nil,
                _ produceClosure: @escaping multiMatchProducesModuleList)
    {
        matchset = (left, direct, right)
        if let prng = prng {
            self.prng = prng
        }
        self.produceClosure = produceClosure
    }

    /// Creates a new rule to match the state element you provide along with a closures that results in a list of state elements.
    /// - Parameters:
    ///   - direct: The type of the L-system state element that the rule evaluates.
    ///   - prng: An optional psuedo-random number generator to use for stochastic rule productions.
    ///   - singleModuleProduce: A closure that produces an array of L-system state elements to use in place of the current element.
    public init(_ direct: Module.Type,
                prng: SeededPsuedoRandomNumberGenerator? = nil,
                _ singleModuleProduce: @escaping singleMatchProducesList)
    {
        matchset = (nil, direct, nil)
        if let prng = prng {
            self.prng = prng
        }
        produceClosure = { _, direct, _ -> [Module] in
            try singleModuleProduce(direct)
        }
    }

    /// Invokes the rule's produce closure with the modules provided.
    /// - Parameter matchSet: The module instances to pass to the produce closure.
    /// - Returns: A sequence of modules that the produce closure returns.
    public func produce(_ matchSet: ModuleSet) throws -> [Module] {
        try produceClosure(matchSet.leftInstance, matchSet.directInstance, matchSet.rightInstance)
    }
}

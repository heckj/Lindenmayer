//
//  ParametericRule.swift
//  X5336
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation

/// A rule represents a potential re-writing match to elements within the L-systems state and the closure that provides the elements to be used for the new state elements.
public struct ParametericRule<PType>: Rule {
    /// The signature of the produce closure that provides up to three modules and a set of parameters and expects a sequence of modules.
    public typealias multiMatchProducesModuleList = (Module?, Module, Module?, PType, Chaos<HasherPRNG>) throws -> [Module]
    /// The signature of the produce closure that provides a module and a set of parameters and expects a sequence of modules.
    public typealias singleMatchProducesList = (Module, PType, Chaos<HasherPRNG>) throws -> [Module]

    /// The set of parameters provided by the L-system for rule evaluation and production.
    var parameters: PType

    /// A psuedo-random number generator to use for stochastic rule productions.
    var prng: Chaos = .init(HasherPRNG(seed: 42))

    /// The closure that provides the L-system state for the current, previous, and next nodes in the state sequence and expects an array of state elements with which to replace the current state.
    public let produceClosure: multiMatchProducesModuleList

    /// The L-system uses the types of these modules to determine is this rule should be applied and re-write the current state.
    public let matchset: (Module.Type?, Module.Type, Module.Type?)

    /// Creates a new rule with the extended context and closures you provide that result in a list of state elements.
    /// - Parameters:
    ///   - left: The type of the L-system state element prior to the current element that the rule evaluates.
    ///   - direct: The type of the L-system state element that the rule evaluates.
    ///   - right: The type of the L-system state element following the current element that the rule evaluates.
    ///   - params: The parameters to pass to the production and evaluation closures.
    ///   - prng: An optional psuedo-random number generator to use for stochastic rule productions.
    ///   - produceClosure: A closure that produces an array of L-system state elements to use in place of the current element.
    public init(_ left: Module.Type?, _ direct: Module.Type, _ right: Module.Type?,
                params: PType,
                prng: Chaos<HasherPRNG>? = nil,
                _ produceClosure: @escaping multiMatchProducesModuleList)
    {
        matchset = (left, direct, right)
        parameters = params
        if let prng = prng {
            self.prng = prng
        }
        self.produceClosure = produceClosure
    }

    /// Creates a new rule to match the state element you provide along with a closures that results in a list of state elements.
    /// - Parameters:
    ///   - direct: The type of the L-system state element that the rule evaluates.
    ///   - params: The parameters to pass to the production and evaluation closures.
    ///   - prng: An optional psuedo-random number generator to use for stochastic rule productions.
    ///   - singleModuleProduce: A closure that produces an array of L-system state elements to use in place of the current element.
    public init(_ direct: Module.Type,
                params: PType,
                prng: Chaos<HasherPRNG>? = nil,
                _ singleModuleProduce: @escaping singleMatchProducesList)
    {
        matchset = (nil, direct, nil)
        parameters = params
        if let prng = prng {
            self.prng = prng
        }
        produceClosure = { _, direct, _, params, chaos -> [Module] in
            try singleModuleProduce(direct, params, chaos)
        }
    }

    /// Invokes the rule's produce closure with the modules provided and any parameters available.
    /// - Parameter matchSet: The module instances to pass to the produce closure.
    /// - Returns: A sequence of modules that the produce closure returns.
    public func produce(_ matchSet: ModuleSet) throws -> [Module] {
        try produceClosure(matchSet.leftInstance, matchSet.directInstance, matchSet.rightInstance, parameters, prng)
    }
}

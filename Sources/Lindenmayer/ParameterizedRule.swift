//
//  Rule.swift
//  X5336
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation

// - feels like I could really use a factory method here to hide the specific types that I'm creating, and allow for
// easier construction of a rule, with its associated production, and maybe evaluation, methods.

/// A rule represents a potential re-writing match to elements within the L-systems state and the closure that provides the elements to be used for the new state elements.
public struct ParameterizedRule<PType>: Rule {
    public typealias multiMatchProducesModuleList = (Module?, Module, Module?, AltParams<PType>) throws -> [Module]
    public typealias singleMatchProducesList = (Module, AltParams<PType>) throws -> [Module]

    /// The set of parameters provided by the L-system for rule evaluation and production.
    public var parameters: Parameters = .init()

    /// The closure that provides the L-system state for the current, previous, and next nodes in the state sequence and expects an array of state elements with which to replace the current state.
    public let produce: multiMatchProducesModuleList

    /// The L-system uses the types of these modules to determine is this rule should be applied and re-write the current state.
    public let matchset: (Module.Type?, Module.Type, Module.Type?)

    /// Creates a new rule with the extended context and closures you provide that result in a list of state elements.
    /// - Parameters:
    ///   - left: The type of the L-system state element prior to the current element that the rule evaluates.
    ///   - direct: The type of the L-system state element that the rule evaluates.
    ///   - right: The type of the L-system state element following the current element that the rule evaluates.
    ///   - produces: A closure that produces an array of L-system state elements to use in place of the current element.
    public init(_ left: Module.Type?, _ direct: Module.Type, _ right: Module.Type?, _ produceClosure: @escaping multiMatchProducesModuleList) {
        matchset = (left, direct, right)
        produce = produceClosure
    }

    /// Creates a new rule to match the state element you provide along with a closures that results in a list of state elements.
    /// - Parameters:
    ///   - direct: The type of the L-system state element that the rule evaluates.
    ///   - produces: A closure that produces an array of L-system state elements to use in place of the current element.
    public init(_ direct: Module.Type, _ singleModuleProduce: @escaping singleMatchProducesList) {
        matchset = (nil, direct, nil)
        produce = { _, direct, _, params -> [Module] in
            try singleModuleProduce(direct, params)
        }
    }
}

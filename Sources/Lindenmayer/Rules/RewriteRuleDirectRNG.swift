//
//  RewriteRuleDirectRNG.swift
//
//
//  Created by Joseph Heck on 1/1/22.
//

import Foundation

/// A rule represents a potential re-writing match to elements within the L-systems state and the closure that provides the elements to be used for the new state elements.
///
/// ## Topics
///
/// ### Creating a Direct Rewrite Rule
///
/// - ``init(directType:prng:where:produces:)``
///
/// ### Evaluating if the Rule Applies
///
/// - ``evaluate(_:)``
/// - ``parametricEval``
/// - ``matchingType``
///
/// ### Invoking the Rule
///
/// - ``produce(_:)``
/// - ``produceClosure``
/// - ``singleMatchProducesList``
///

public struct RewriteRuleDirectRNG<DC, PRNG>: Rule where DC: Module, PRNG: SeededRandomNumberGenerator {
    /// An optional closure that provides the module to which it is being compared that returns whether the rule should be applied.
    public var parametricEval: (@Sendable (DC) -> Bool)?

    /// A psuedo-random number generator to use for stochastic rule productions.
    var prng: RNGWrapper<PRNG>

    /// The signature of the produce closure that provides a module and expects a sequence of modules.
    public typealias SingleMatchProducesList = @Sendable (DC, RNGWrapper<PRNG>) async -> [any Module]

    /// The closure that provides the L-system state for the current, previous, and next nodes in the state sequence and expects an array of state elements with which to replace the current state.
    public let produceClosure: SingleMatchProducesList

    /// The L-system uses the types of these modules to determine is this rule should be applied and re-write the current state.
    public let matchingType: DC.Type

    /// Creates a new rule to match the state element you provide along with a closures that results in a list of state elements.
    /// - Parameters:
    ///   - direct: The type of the L-system state element that the rule evaluates.
    ///   - prng: An optional psuedo-random number generator to use for stochastic rule productions.
    ///   - singleModuleProduce: A closure that produces an array of L-system state elements to use in place of the current element.
    public init(directType direct: DC.Type,
                prng: RNGWrapper<PRNG>,
                where eval: (@Sendable (DC) -> Bool)?,
                produces singleModuleProduce: @escaping SingleMatchProducesList)
    {
        matchingType = direct
        self.prng = prng
        parametricEval = eval
        produceClosure = singleModuleProduce
    }

    /// Determines if a rule should be evaluated while processing the individual atoms of an L-system state sequence.
    /// - Parameters:
    ///   - leftCtx: The type of atom 'to the left' of the atom being evaluated, if avaialble.
    ///   - directCtx: The type of the current atom to evaluate.
    ///   - rightCtx: The type of atom 'to the right' of the atom being evaluated, if available.
    /// - Returns: A Boolean value that indicates if the rule should be applied to the current atom within the L-systems state sequence.
    public func evaluate(_ matchSet: ModuleSet) -> Bool {
        // short circuit if the direct context doesn't match the matchset's setting
        guard matchingType == matchSet.directInstanceType else {
            return false
        }

        if let additionalEval = parametricEval {
            guard let directInstance = matchSet.directInstance as? DC else {
                return false
            }

            return additionalEval(directInstance)
        }

        return true
    }

    /// Invokes the rule's produce closure with the modules provided.
    /// - Parameter matchSet: The module instances to pass to the produce closure.
    /// - Returns: A sequence of modules that the produce closure returns.
    public func produce(_ matchSet: ModuleSet) async -> [any Module] {
        guard let directInstance = matchSet.directInstance as? DC else {
            return []
        }
        return await produceClosure(directInstance, prng)
    }
}

extension RewriteRuleDirectRNG: CustomStringConvertible {
    /// A description of the rule that details what it matches
    public var description: String {
        "Rule(direct)(\(String(describing: matchingType)) w/  rng"
    }
}

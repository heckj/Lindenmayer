//
//  RewriteRuleDirectRightDefines.swift
//
//
//  Created by Joseph Heck on 1/1/22.
//

import Foundation

/// A rule represents a potential re-writing match to elements within the L-systems state and the closure that provides the elements to be used for the new state elements.
public struct RewriteRuleDirectRightDefines<DC, RC, PType>: Rule where DC: Module, RC: Module {
    /// The set of parameters provided by the L-system for rule evaluation and production.
    var parameters: ParametersWrapper<PType>

    public var parametricEval: ((DC, RC, PType) -> Bool)?

    /// The signature of the produce closure that provides a module and expects a sequence of modules.
    public typealias combinationMatchProducesList = (DC, RC, PType) -> [Module]

    /// The closure that provides the L-system state for the current, previous, and next nodes in the state sequence and expects an array of state elements with which to replace the current state.
    public let produceClosure: combinationMatchProducesList

    /// The L-system uses the types of these modules to determine is this rule should be applied and re-write the current state.
    public let matchingTypes: (DC.Type, RC.Type)

    /// Creates a new rule to match the state element you provide along with a closures that results in a list of state elements.
    /// - Parameters:
    ///   - direct: The type of the L-system state element that the rule evaluates.
    ///   - prng: An optional psuedo-random number generator to use for stochastic rule productions.
    ///   - singleModuleProduce: A closure that produces an array of L-system state elements to use in place of the current element.
    public init(directType: DC.Type, rightType: RC.Type,
                parameters: ParametersWrapper<PType>,
                where _: ((DC, RC, PType) -> Bool)?,
                produces produceClosure: @escaping combinationMatchProducesList)
    {
        matchingTypes = (directType, rightType)
        self.parameters = parameters
        self.produceClosure = produceClosure
    }

    /// Determines if a rule should be evaluated while processing the individual atoms of an L-system state sequence.
    /// - Parameters:
    ///   - leftCtx: The type of atom 'to the left' of the atom being evaluated, if avaialble.
    ///   - directCtx: The type of the current atom to evaluate.
    ///   - rightCtx: The type of atom 'to the right' of the atom being evaluated, if available.
    /// - Returns: A Boolean value that indicates if the rule should be applied to the current atom within the L-systems state sequence.
    public func evaluate(_ matchSet: ModuleSet) -> Bool {
        guard matchingTypes.0 == matchSet.directInstanceType else {
            return false
        }
        guard matchingTypes.1 == matchSet.rightInstanceType else {
            return false
        }

        if let additionalEval = parametricEval {
            guard let directInstance = matchSet.directInstance as? DC,
                  let rightInstance = matchSet.rightInstance as? RC
            else {
                return false
            }
            return additionalEval(directInstance, rightInstance, parameters.unwrap())
        }

        return true
    }

    /// Invokes the rule's produce closure with the modules provided.
    /// - Parameter matchSet: The module instances to pass to the produce closure.
    /// - Returns: A sequence of modules that the produce closure returns.
    public func produce(_ matchSet: ModuleSet) -> [Module] {
        guard let directInstance = matchSet.directInstance as? DC,
              let rightInstance = matchSet.rightInstance as? RC
        else {
            return []
        }
        return produceClosure(directInstance, rightInstance, parameters.unwrap())
    }
}

extension RewriteRuleDirectRightDefines: CustomStringConvertible {
    /// A description of the rule that details what it matches
    public var description: String {
        return "Rule(direct,right)(\(String(describing: matchingTypes)) w/ parameters: \(String(describing: parameters))"
    }
}

//
//  Rule.swift
//  X5336
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation

/// A rule represents a potential re-writing match to elements within the L-systems state and the closure that provides the elements to be used for the new state elements.
public struct Rule: CustomStringConvertible {
    
    public typealias multiMatchProducesModuleList = (Module?, Module, Module?, Parameters) throws -> [Module]
    public typealias singleMatchProducesList = (Module, Parameters) throws -> [Module]
    
    /// The set of parameters provided by the L-system for rule evaluation and production.
    public var parameters: Parameters = Parameters()
    
    /// The closure that provides the L-system state for the current, previous, and next nodes in the state sequence and expects an array of state elements with which to replace the current state.
    public let produce: multiMatchProducesModuleList
    
    /// The L-system uses the types of these modules to determine is this rule should be applied and re-write the current state.
    public let matchset: (Module.Type?, Module.Type, Module.Type?)

    // it seems like it might be better to use the type of the module for providing the
    // matchsets...
    //    let y = A.self // -> A.Type

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
        produce = { left, direct, right, params -> [Module] in
            return try singleModuleProduce(direct, params)
        }
    }

    /// Determines if a rule should be evaluated while processing the individual atoms of an L-system state sequence.
    /// - Parameters:
    ///   - leftCtx: The type of atom 'to the left' of the atom being evaluated, if avaialble.
    ///   - directCtx: The type of the current atom to evaluate.
    ///   - rightCtx: The type of atom 'to the right' of the atom being evaluated, if available.
    /// - Returns: A Boolean value that indicates if the rule should be applied to the current atom within the L-systems state sequence.
    public func evaluate(_ leftCtxType: Module.Type?, _ directCtxType: Module.Type, _ rightCtxType: Module.Type?) -> Bool {
        // TODO(heckj): add an additional property that exposes a closure to call
        // to determine if the rule should be evaluated - where the closure exposes
        // access to the internal parameters of the various matched modules - effectively
        // make this a parametric L-system.
        
        // short circuit if the direct context doesn't match the matchset's setting
        guard matchset.1 == directCtxType else {
            return false
        }

        // The left matchset _can_ be nil, but if it's provided, try to match against it.
        let leftmatch: Bool
        // First unwrap the type if we can, because an Optional<Foo> won't match Foo...
        if let unwrapedLeft = matchset.0 {
            leftmatch = unwrapedLeft == leftCtxType
        } else {
            leftmatch = true
        }

        // The right matchset _can_ be nil, but if it's provided, try to match against it.
        let rightmatch: Bool
        // First unwrap the type if we can, because an Optional<Foo> won't match Foo...
        if let unwrapedRight = matchset.2 {
            rightmatch = unwrapedRight == rightCtxType
        } else {
            rightmatch = true
        }
                
        return leftmatch && rightmatch
    }
    
    // - MARK: CustomStringConvertable
    
    /// A description of the rule that details what it matches
    public var description: String {
        return "Rule[matching \(matchset)]"
    }

}

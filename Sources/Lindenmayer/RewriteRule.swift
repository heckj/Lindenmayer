////
////  RewriteRule.swift
////
////
////  Created by Joseph Heck on 1/1/22.
////
//
// import Foundation
//
///// A rule represents a potential re-writing match to elements within the L-systems state and the closure that provides the elements to be used for the new state elements.
// public struct RewriteRule: Rule {
//    public var parametricEval: ((ModuleSet) -> Bool)? = nil
//
//    /// The signature of the produce closure that provides a set of up to three modules and expects a sequence of modules.
//    public typealias multiMatchProducesModuleList = (Module?, Module, Module?) throws -> [Module]
//    /// The signature of the produce closure that provides a module and expects a sequence of modules.
//    public typealias singleMatchProducesList = (Module) throws -> [Module]
//
//    /// The closure that provides the L-system state for the current, previous, and next nodes in the state sequence and expects an array of state elements with which to replace the current state.
//    public let produceClosure: multiMatchProducesModuleList
//
//    /// The L-system uses the types of these modules to determine is this rule should be applied and re-write the current state.
//    public let matchset: (Module.Type?, Module.Type, Module.Type?)
//
//    /// Creates a new rule with the extended context and closures you provide that result in a list of state elements.
//    /// - Parameters:
//    ///   - left: The type of the L-system state element prior to the current element that the rule evaluates.
//    ///   - direct: The type of the L-system state element that the rule evaluates.
//    ///   - right: The type of the L-system state element following the current element that the rule evaluates.
//    ///   - produceClosure: A closure that produces an array of L-system state elements to use in place of the current element.
//    public init(_ left: Module.Type?, _ direct: Module.Type, _ right: Module.Type?,
//                _ evalClosure: ((ModuleSet) -> Bool)?,
//                _ produceClosure: @escaping multiMatchProducesModuleList)
//    {
//        matchset = (left, direct, right)
//        self.produceClosure = produceClosure
//    }
//
//    /// Creates a new rule to match the state element you provide along with a closures that results in a list of state elements.
//    /// - Parameters:
//    ///   - direct: The type of the L-system state element that the rule evaluates.
//    ///   - prng: An optional psuedo-random number generator to use for stochastic rule productions.
//    ///   - singleModuleProduce: A closure that produces an array of L-system state elements to use in place of the current element.
//    public init(_ direct: Module.Type,
//                _ evalClosure: ((ModuleSet) -> Bool)?,
//                _ singleModuleProduce: @escaping singleMatchProducesList)
//    {
//        matchset = (nil, direct, nil)
//        produceClosure = { _, direct, _ -> [Module] in
//            try singleModuleProduce(direct)
//        }
//    }
//
//    /// Determines if a rule should be evaluated while processing the individual atoms of an L-system state sequence.
//    /// - Parameters:
//    ///   - leftCtx: The type of atom 'to the left' of the atom being evaluated, if avaialble.
//    ///   - directCtx: The type of the current atom to evaluate.
//    ///   - rightCtx: The type of atom 'to the right' of the atom being evaluated, if available.
//    /// - Returns: A Boolean value that indicates if the rule should be applied to the current atom within the L-systems state sequence.
//    public func evaluate(_ matchSet: ModuleSet) -> Bool {
//        // short circuit if the direct context doesn't match the matchset's setting
//        guard matchset.1 == matchSet.directInstanceType else {
//            return false
//        }
//
//        // The left matchset _can_ be nil, but if it's provided, try to match against it.
//        let leftmatch: Bool
//        // First unwrap the type if we can, because an Optional<Foo> won't match Foo...
//        if let unwrapedLeft = matchset.0 {
//            leftmatch = unwrapedLeft == matchSet.leftInstanceType
//        } else {
//            leftmatch = true
//        }
//
//        // The right matchset _can_ be nil, but if it's provided, try to match against it.
//        let rightmatch: Bool
//        // First unwrap the type if we can, because an Optional<Foo> won't match Foo...
//        if let unwrapedRight = matchset.2 {
//            rightmatch = unwrapedRight == matchSet.rightInstanceType
//        } else {
//            rightmatch = true
//        }
//
//        if let additionalEval = self.parametricEval {
//            return leftmatch && rightmatch && additionalEval(matchSet)
//        }
//
//        return leftmatch && rightmatch
//    }
//    /// Invokes the rule's produce closure with the modules provided.
//    /// - Parameter matchSet: The module instances to pass to the produce closure.
//    /// - Returns: A sequence of modules that the produce closure returns.
//    public func produce(_ matchSet: ModuleSet) throws -> [Module] {
//        try produceClosure(matchSet.leftInstance, matchSet.directInstance, matchSet.rightInstance)
//    }
// }

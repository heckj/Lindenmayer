//
//  LSystem.swift
//  X5336
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation

public protocol LSystemProtocol {
    var state: [Module] { get }
    func evolve(iterations: Int) throws -> LSystemProtocol
}

// - likewise here in LSystem it feels like I could really use a factory method here to hide the specific types
// that I'm creating to allow for easier construction of the lsystems as I'm creating new Lsystems...

public struct NonParameterizedLSystem: LSystemProtocol {
    public let rules: [NonParameterizedRule]

    public let state: [Module]

    /// Creates a new Lindenmayer system from an initial state and rules you provide.
    /// - Parameters:
    ///   - axiom: A module that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(_ axiom: Module, rules: [NonParameterizedRule] = []) {
        // Using [axiom] instead of [] ensures that we always have a state
        // environment that can be evolved based on the rules available.
        state = [axiom]
        self.rules = rules
    }

    /// Creates a new Lindenmayer system from an initial state sequence and rules you provide.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(_ axiom: [Module], rules: [NonParameterizedRule] = []) {
        // Using [axiom] instead of [] ensures that we always have a state
        // environment that can be evolved based on the rules available.
        state = axiom
        self.rules = rules
    }

    /// Updates the state of the Lindenmayer system.
    ///
    /// The Lindermayer system iterates through the rules provided, applying the first rule that matches the state from the rule to the current state of the system.
    /// When applying the rule, the element that matched is replaced with what the rule returns from ``Rule/produce``.
    /// The types of errors that may be thrown is defined by any errors referenced and thrown within the set of rules you provide.
    /// - Returns: An updated Lindenmayer system.
    public func evolve(iterations: Int = 1) throws -> LSystemProtocol {
        // Performance is O(n)(z) with the (n) number of atoms in the state and (z) number of rules to apply.
        // TODO(heckj): revisit this with async methods in mind, creating tasks for each iteration
        // in order to run the whole suite of the state in parallel for a new result. Await the whole
        // kit for a final resolution.
        var currentState: [Module] = state
        for _ in 0 ..< iterations {
            var newState: [Module] = []

            for index in 0 ..< currentState.count {
                let leftInstance: Module?
                let leftInstanceType: Module.Type?
                let strictInstance: Module = currentState[index]
                let strictInstanceType: Module.Type = type(of: strictInstance)
                let rightInstance: Module?
                let rightInstanceType: Module.Type?

                if index - 1 > 0 {
                    leftInstance = currentState[index - 1]
                    if let unwrappedLeftInstance = leftInstance {
                        leftInstanceType = type(of: unwrappedLeftInstance)
                    } else {
                        leftInstanceType = nil
                    }
                } else {
                    leftInstance = nil
                    leftInstanceType = nil
                }

                if currentState.count > index + 1 {
                    rightInstance = currentState[index + 1]
                    if let unwrappedRightInstance = rightInstance {
                        rightInstanceType = type(of: unwrappedRightInstance)
                    } else {
                        rightInstanceType = nil
                    }
                } else {
                    rightInstance = nil
                    rightInstanceType = nil
                }

                // Iterate through the rules, finding the first rule to match
                // based on calling 'evaluate' on each of the rules in sequence.
                let maybeRule: NonParameterizedRule? = rules.first(where: { $0.evaluate(leftInstanceType, strictInstanceType, rightInstanceType) })
                if let foundRule = maybeRule {
                    // If a rule was found, then use it to generate the modules that
                    // replace this element in the sequence.
                    newState.append(contentsOf: try foundRule.produce(leftInstance, strictInstance, rightInstance))
                } else {
                    // If no rule was identified, we pass along the 'Module' as an
                    // ignored module for later evaluation - for example to be used
                    // to represent the final visual state externally.
                    newState.append(strictInstance)
                }
            }
            // update the current state for the next iteration of processing
            currentState = newState
        }
        return NonParameterizedLSystem(currentState, rules: rules)
    }
}

// that implements most of the stuff below, but _doesn't_ pass parameters
// through to the rules.

/// An instance of a parameterized, stochastic Lindenmayer system.
///
/// For more information on the background of Lindenmayer systems, see [Wikipedia's L-System](https://en.wikipedia.org/wiki/L-system).
public struct LSystem<PType>: LSystemProtocol {
    public let rules: [ParameterizedRule<PType>]
    // consider making rules a 'var' and allowing rules to be added after the L-system is instantiated...

    public let parameters: AltParams<PType>

    /// The current state of the LSystem, expressed as a sequence of elements that conform to Module.
    public let state: [Module]

    /// Creates a new Lindenmayer system from an initial state and rules you provide.
    /// - Parameters:
    ///   - axiom: A module that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(_ axiom: Module, parameters: AltParams<PType>, rules: [ParameterizedRule<PType>] = []) {
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
    public init(_ axiom: [Module], parameters: AltParams<PType>, rules: [ParameterizedRule<PType>] = []) {
        // Using [axiom] instead of [] ensures that we always have a state
        // environment that can be evolved based on the rules available.
        state = axiom
        self.rules = rules
        self.parameters = parameters
    }

    /// Updates the state of the Lindenmayer system.
    ///
    /// The Lindermayer system iterates through the rules provided, applying the first rule that matches the state from the rule to the current state of the system.
    /// When applying the rule, the element that matched is replaced with what the rule returns from ``Rule/produce``.
    /// The types of errors that may be thrown is defined by any errors referenced and thrown within the set of rules you provide.
    /// - Returns: An updated Lindenmayer system.
    public func evolve(iterations: Int = 1) throws -> LSystemProtocol {
        // Performance is O(n)(z) with the (n) number of atoms in the state and (z) number of rules to apply.
        // TODO(heckj): revisit this with async methods in mind, creating tasks for each iteration
        // in order to run the whole suite of the state in parallel for a new result. Await the whole
        // kit for a final resolution.
        var currentState: [Module] = state
        for _ in 0 ..< iterations {
            var newState: [Module] = []

            for index in 0 ..< currentState.count {
                let leftInstance: Module?
                let leftInstanceType: Module.Type?
                let strictInstance: Module = currentState[index]
                let strictInstanceType: Module.Type = type(of: strictInstance)
                let rightInstance: Module?
                let rightInstanceType: Module.Type?

                if index - 1 > 0 {
                    leftInstance = currentState[index - 1]
                    if let unwrappedLeftInstance = leftInstance {
                        leftInstanceType = type(of: unwrappedLeftInstance)
                    } else {
                        leftInstanceType = nil
                    }
                } else {
                    leftInstance = nil
                    leftInstanceType = nil
                }

                if currentState.count > index + 1 {
                    rightInstance = currentState[index + 1]
                    if let unwrappedRightInstance = rightInstance {
                        rightInstanceType = type(of: unwrappedRightInstance)
                    } else {
                        rightInstanceType = nil
                    }
                } else {
                    rightInstance = nil
                    rightInstanceType = nil
                }

                // Iterate through the rules, finding the first rule to match
                // based on calling 'evaluate' on each of the rules in sequence.
                let maybeRule: ParameterizedRule? = rules.first(where: { $0.evaluate(leftInstanceType, strictInstanceType, rightInstanceType) })
                if let foundRule = maybeRule {
                    // If a rule was found, then use it to generate the modules that
                    // replace this element in the sequence.
                    newState.append(contentsOf: try foundRule.produce(leftInstance, strictInstance, rightInstance, parameters))
                } else {
                    // If no rule was identified, we pass along the 'Module' as an
                    // ignored module for later evaluation - for example to be used
                    // to represent the final visual state externally.
                    newState.append(strictInstance)
                }
            }
            // update the current state for the next iteration of processing
            currentState = newState
        }
        return LSystem(currentState, parameters: parameters, rules: rules)
    }
}

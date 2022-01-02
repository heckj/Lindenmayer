//
//  ParametericLSystem.swift
//  X5336
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation

/// A parameterized, stochastic Lindenmayer system.
///
/// For more information on the background of Lindenmayer systems, see [Wikipedia's L-System](https://en.wikipedia.org/wiki/L-system).
public struct LSystemDefinesRNG<PType, PRNG>: LSystem where PRNG: RandomNumberGenerator {
    /// The sequence of rules that the L-system uses to process and evolve its state.
    public let rules: [Rule]

    /// The parameters to provide to rules for evaluation and production.
    public let parameters: PType

    /// The current state of the LSystem, expressed as a sequence of elements that conform to Module.
    public let state: [Module]

    var prng: RNGWrapper<PRNG>

    /// Creates a new Lindenmayer system from an initial state sequence and rules you provide.
    /// - Parameters:
    ///   - axiom: A sequence of modules that represents the initial state of the Lindenmayer system..
    ///   - parameters: A set of parameters accessible to rules for evaluation and production.
    ///   - prng: A psuedo-random number generator to use for stochastic rule productions.
    ///   - rules: A collection of rules that the Lindenmayer system applies when you call the evolve function.
    public init(axiom: [Module],
                parameters: PType,
                prng: RNGWrapper<PRNG>,
                rules: [Rule] = [])
    {
        // Using [axiom] instead of [] ensures that we always have a state
        // environment that can be evolved based on the rules available.
        state = axiom
        self.parameters = parameters
        self.prng = prng
        self.rules = rules
    }

    /// Returns a new L-system with the provided state.
    /// - Parameter state: The sequence of modules that represent the new state.
    /// - Returns: A new L-system with the updated state that has the same rules and parameters.
    public func updatedLSystem(with state: [Module]) -> LSystem {
        return LSystemDefinesRNG<PType, PRNG>(axiom: state, parameters: parameters, prng: prng, rules: rules)
    }
}

// - MARK: Rewrite rules including RNG and Parameters from the LSystem

extension LSystemDefinesRNG {
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithAll<LC, DC, RC>(
        leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
        where evalClosure: (@escaping (ModuleSet) -> Bool),
        produces produceClosure: @escaping (LC, DC, RC, PType, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where LC: Module, DC: Module, RC: Module, PRNG: RandomNumberGenerator {
        let rule = RewriteRuleLeftDirectRightDefinesRNG(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            parameters: self.parameters,
            prng: self.prng,
            where: evalClosure,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithAll<LC, DC, RC>(
        leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
        produces produceClosure: @escaping (LC, DC, RC, PType, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where LC: Module, DC: Module, RC: Module, PRNG: RandomNumberGenerator {
        let rule = RewriteRuleLeftDirectRightDefinesRNG(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            parameters: self.parameters,
            prng: self.prng,
            where: nil,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
    
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithAll<LC, DC>(
        leftContext: LC.Type, directContext: DC.Type,
        where evalClosure: (@escaping (ModuleSet) -> Bool),
        produces produceClosure: @escaping (LC, DC, PType, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where LC: Module, DC: Module {
        let rule = RewriteRuleLeftDirectDefinesRNG(
            leftType: leftContext, directType: directContext,
            parameters: self.parameters,
            prng: self.prng,
            where: evalClosure,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithAll<LC, DC>(
        leftContext: LC.Type, directContext: DC.Type,
        produces produceClosure: @escaping (LC, DC, PType, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where LC: Module, DC: Module {
        let rule = RewriteRuleLeftDirectDefinesRNG(
            leftType: leftContext, directType: directContext,
            parameters: self.parameters,
            prng: self.prng,
            where: nil,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
    
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithAll<DC, RC>(
        directContext: DC.Type, rightContext: RC.Type,
        where evalClosure: (@escaping (ModuleSet) -> Bool),
        produces produceClosure: @escaping (DC, RC, PType, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where DC: Module, RC: Module, PRNG: RandomNumberGenerator {
        let rule = RewriteRuleDirectRightDefinesRNG(
            directType: directContext, rightType: rightContext,
            parameters: self.parameters,
            prng: self.prng,
            where: evalClosure,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithAll<DC, RC>(
        directContext: DC.Type, rightContext: RC.Type,
        produces produceClosure: @escaping (DC, RC, PType, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where DC: Module, RC: Module {
        let rule = RewriteRuleDirectRightDefinesRNG(
            directType: directContext, rightType: rightContext,
            parameters: self.parameters,
            prng: self.prng,
            where: nil,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
    
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithAll<DC>(
        directContext: DC.Type,
        where evalClosure: (@escaping (ModuleSet) -> Bool),
        produces produceClosure: @escaping (DC, PType, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where DC: Module {
        let rule = RewriteRuleDirectDefinesRNG(
            directType: directContext,
            parameters: self.parameters,
            prng: self.prng,
            where: evalClosure,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithAll<DC>(
        directContext: DC.Type,
        produces produceClosure: @escaping (DC, PType, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where DC: Module {
        let rule = RewriteRuleDirectDefinesRNG(
            directType: directContext,
            parameters: self.parameters,
            prng: self.prng,
            where: nil,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
}


// - MARK: Rewrite rules including Parameters from the LSystem

extension LSystemDefinesRNG {
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithParams<LC, DC, RC>(
        leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
        where evalClosure: (@escaping (ModuleSet) -> Bool),
        produces produceClosure: @escaping (LC, DC, RC, PType) throws -> [Module]) -> Self
    where LC: Module, DC: Module, RC: Module {
        let rule = RewriteRuleLeftDirectRightDefines(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            parameters: self.parameters,
            where: evalClosure,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithParams<LC, DC, RC>(
        leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
        produces produceClosure: @escaping (LC, DC, RC, PType) throws -> [Module]) -> Self
    where LC: Module, DC: Module, RC: Module {
        let rule = RewriteRuleLeftDirectRightDefines(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            parameters: self.parameters,
            where: nil,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
}

// - MARK: Rewrite rules including PRNG from the LSystem

extension LSystemDefinesRNG {

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithRNG<LC, DC, RC>(
        leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
        where evalClosure: (@escaping (ModuleSet) -> Bool),
        produces produceClosure: @escaping (LC, DC, RC, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where LC: Module, DC: Module, RC: Module, PRNG: RandomNumberGenerator {
        let rule = RewriteRuleLeftDirectRightRNG(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            prng: self.prng,
            where: evalClosure,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithRNG<LC, DC, RC>(
        leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
        produces produceClosure: @escaping (LC, DC, RC, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where LC: Module, DC: Module, RC: Module, PRNG: RandomNumberGenerator {
        let rule = RewriteRuleLeftDirectRightRNG(
            leftType: leftContext, directType: directContext, rightType: rightContext,
            prng: self.prng,
            where: nil,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
    
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithRNG<LC, DC>(
        leftContext: LC.Type, directContext: DC.Type,
        where evalClosure: (@escaping (ModuleSet) -> Bool),
        produces produceClosure: @escaping (LC, DC, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where LC: Module, DC: Module {
        let rule = RewriteRuleLeftDirectRNG(
            leftType: leftContext, directType: directContext,
            prng: self.prng,
            where: evalClosure,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithRNG<LC, DC>(
        leftContext: LC.Type, directContext: DC.Type,
        produces produceClosure: @escaping (LC, DC, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where LC: Module, DC: Module {
        let rule = RewriteRuleLeftDirectRNG(
            leftType: leftContext, directType: directContext,
            prng: self.prng,
            where: nil,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
    
    
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - left: An optional type of module that the rule matches to the left of the main module.
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithRNG<DC, RC>(
        directContext: DC.Type, rightContext: RC.Type,
        where evalClosure: (@escaping (ModuleSet) -> Bool),
        produces produceClosure: @escaping (DC, RC, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where DC: Module, RC: Module {
        let rule = RewriteRuleDirectRightRNG(
            directType: directContext, rightType: rightContext,
            prng: self.prng,
            where: evalClosure,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - right: An optional type of module that the rule matches to the right of the main module.
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithRNG<DC, RC>(
        directContext: DC.Type, rightContext: RC.Type,
        produces produceClosure: @escaping (DC, RC, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where DC: Module, RC: Module {
        let rule = RewriteRuleDirectRightRNG(
            directType: directContext, rightType: rightContext,
            prng: self.prng,
            where: nil,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
    
    
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that...
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithRNG<DC>(
        directContext: DC.Type,
        where evalClosure: (@escaping (ModuleSet) -> Bool),
        produces produceClosure: @escaping (DC, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where DC: Module {
        let rule = RewriteRuleDirectRNG(
            directType: directContext,
            prng: self.prng,
            where: evalClosure,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A new L-System with the additional rule added.
    /// - Returns: A new L-System with the additional rule added.
    public func rewriteWithRNG<DC>(
        directContext: DC.Type,
        produces produceClosure: @escaping (DC, RNGWrapper<PRNG>) throws -> [Module]) -> Self
    where DC: Module {
        let rule = RewriteRuleDirectRNG(
            directType: directContext,
            prng: self.prng,
            where: nil,
            produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [rule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
    
}

extension LSystemDefinesRNG {
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<DC>(_ direct: DC.Type,
                            where evalClosure: (@escaping (ModuleSet) -> Bool),
                            produces produceClosure: @escaping (Module) throws -> [Module]) -> Self where DC: Module {
        let newRule = RewriteRuleDirect(direct: direct, where: evalClosure, produce: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<DC>(_ direct: DC.Type,
                            produces produceClosure: @escaping (Module) throws -> [Module]) -> Self where DC: Module {
        let newRule = RewriteRuleDirect(direct: direct, where: nil, produce: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<LC, DC>(leftContext: LC.Type, directContext: DC.Type,
                            where evalClosure: (@escaping (ModuleSet) -> Bool),
                                produces produceClosure: @escaping (LC, DC) throws -> [Module]) -> Self where LC: Module, DC: Module {
        let newRule = RewriteRuleLeftDirect(leftType: leftContext, directType: directContext, where: evalClosure, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<LC, DC>(leftContext: LC.Type, directContext: DC.Type,
                                produces produceClosure: @escaping (LC, DC) throws -> [Module]) -> Self where LC: Module, DC: Module {
        let newRule = RewriteRuleLeftDirect(leftType: leftContext, directType: directContext, where: nil, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<DC, RC>(directContext: DC.Type, rightContext: RC.Type,
                            where evalClosure: (@escaping (ModuleSet) -> Bool),
                                produces produceClosure: @escaping (DC, RC) throws -> [Module]) -> Self where DC: Module, RC: Module {
        let newRule = RewriteRuleDirectRight(directType: directContext, rightType: rightContext, where: evalClosure, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<DC, RC>(directContext: DC.Type, rightContext: RC.Type,
                                produces produceClosure: @escaping (DC, RC) throws -> [Module]) -> Self where DC: Module, RC: Module {
        let newRule = RewriteRuleDirectRight(directType: directContext, rightType: rightContext, where: nil, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
    
    
    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - where: A closure that you provide ...
    ///   - produces: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<LC, DC, RC>(leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
                            where evalClosure: (@escaping (ModuleSet) -> Bool),
                                    produces produceClosure: @escaping (LC, DC, RC) throws -> [Module]) -> Self where LC: Module, DC: Module, RC: Module {
        let newRule = RewriteRuleLeftDirectRight(leftType: leftContext, directType: directContext, rightType: rightContext, where: evalClosure, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }

    /// Adds a rewriting rule to the L-System.
    /// - Parameters:
    ///   - direct: The type of module that the rule matches
    ///   - produce: A closure that you provide that returns a list of modules to replace the matching module.
    /// - Returns: A new L-System with the additional rule added.
    public func rewrite<LC, DC, RC>(leftContext: LC.Type, directContext: DC.Type, rightContext: RC.Type,
                                    produces produceClosure: @escaping (LC, DC, RC) throws -> [Module]) -> Self where LC: Module, DC: Module, RC: Module {
        let newRule = RewriteRuleLeftDirectRight(leftType: leftContext, directType: directContext, rightType: rightContext, where: nil, produces: produceClosure)
        var newRuleSet: [Rule] = rules
        newRuleSet.append(contentsOf: [newRule])
        return LSystemDefinesRNG(axiom: state, parameters: parameters, prng: prng, rules: newRuleSet)
    }
    
}

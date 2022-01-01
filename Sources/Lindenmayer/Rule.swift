//
//  Rule.swift
//
//
//  Created by Joseph Heck on 12/28/21.
//

import Foundation

/// A type that represents a rewriting rule used by an L-system to process the modules within it.
public protocol Rule: CustomStringConvertible {
    
    /// The types of modules this rule matches.
    var matchset: (Module.Type?, Module.Type, Module.Type?) { get }
    
    /// Returns a Boolean value that indicates whether the rule applies to the set of modules you provide.
    func evaluate(_ leftCtxType: Module.Type?, _ directCtxType: Module.Type, _ rightCtxType: Module.Type?) -> Bool
    
    /// Returns a sequence of modules based on the existing module, and potentially it's contextual position with the module to the right and left.
    /// - Returns: The sequence of modules that replaces the current module during evolution.
    func produce(_ matchSet: ModuleSet) throws -> [Module]
}

public extension Rule {
    /// Determines if a rule should be evaluated while processing the individual atoms of an L-system state sequence.
    /// - Parameters:
    ///   - leftCtx: The type of atom 'to the left' of the atom being evaluated, if avaialble.
    ///   - directCtx: The type of the current atom to evaluate.
    ///   - rightCtx: The type of atom 'to the right' of the atom being evaluated, if available.
    /// - Returns: A Boolean value that indicates if the rule should be applied to the current atom within the L-systems state sequence.
    func evaluate(_ leftCtxType: Module.Type?, _ directCtxType: Module.Type, _ rightCtxType: Module.Type?) -> Bool {
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
}

public extension Rule {
    // - MARK: CustomStringConvertable

    /// A description of the rule that details what it matches
    var description: String {
        return "Rule[matching \(matchset)]"
    }
}

//
//  Rule.swift
//  
//
//  Created by Joseph Heck on 12/28/21.
//

import Foundation

public protocol Rule: CustomStringConvertible {
    var matchset: (Module.Type?, Module.Type, Module.Type?) { get }
    func evaluate(_ leftCtxType: Module.Type?, _ directCtxType: Module.Type, _ rightCtxType: Module.Type?) -> Bool
}

extension Rule {
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
}

extension Rule {
    // - MARK: CustomStringConvertable
    
    /// A description of the rule that details what it matches
    public var description: String {
        return "Rule[matching \(matchset)]"
    }

}

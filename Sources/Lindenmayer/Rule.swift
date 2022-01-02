//
//  Rule.swift
//
//  Created by Joseph Heck on 12/28/21.
//

import Foundation

/// A type that represents a rewriting rule used by an L-system to process the modules within it.
public protocol Rule {
    /// Returns a Boolean value that indicates whether the rule applies to the set of modules you provide.
    func evaluate(_ matchSet: ModuleSet) -> Bool

    /// Returns a sequence of modules based on the existing module, and potentially it's contextual position with the module to the right and left.
    /// - Returns: The sequence of modules that replaces the current module during evolution.
    func produce(_ matchSet: ModuleSet) -> [Module]
}

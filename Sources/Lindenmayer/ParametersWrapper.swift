//
//  ParametersWrapper.swift
//
//
//  Created by Joseph Heck on 1/4/22.
//

import Foundation
import Squirrel3

/// A class that provides reference semantics to access an underlying parameter value type that you provide.
public final class ParametersWrapper<PType> {
    private var _parameters: PType

    public func update(_ p: PType) {
        _parameters = p
    }

    public func unwrap() -> PType {
        return _parameters
    }

    /// Creates a new random number generator wrapper class with the random number generator you provide.
    /// - Parameter prng: A random number generator.
    public init(_ p: PType) {
        _parameters = p
    }
}

//
//  ParameterSet.swift
//  
//
//  Created by Joseph Heck on 12/20/21.
//

import Foundation

/// A struct that holds a collection of parameters.
///
/// Parameters are referenced by a string, accessible as a subscript on the struct, that provide a value of type Double.
@dynamicMemberLookup
public struct Parameters {

    let _params: [String:Double]
    
    public init(_ p: [String:Double] = [:]) {
        _params = p
    }
    
    /// Returns the module's parameter defined by the string provided if available; otherwise, nil.
    public subscript(dynamicMember key: String) -> Double? {
        get {
            return _params[key]
        }
    }
}

extension Parameters: CustomStringConvertible {
    
    /// Returns a string description for this module.
    public var description: String {
        return String(describing: _params)
    }
}

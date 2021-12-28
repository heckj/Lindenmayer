//
//  ParameterSet.swift
//
//
//  Created by Joseph Heck on 12/20/21.
//

import Foundation

/*
 struct Point { var x, y: Int }

 @dynamicMemberLookup
 struct PassthroughWrapper<Value> {
     var value: Value
     subscript<T>(dynamicMember member: KeyPath<Value, T>) -> T {
         get { return value[keyPath: member] }
     }
 }

 let point = Point(x: 381, y: 431)
 let wrapper = PassthroughWrapper(value: point)
 print(wrapper.x)
 */

public struct EmptyParams {}

@dynamicMemberLookup
public struct AltParams<Value> {
    var _params: Value

    // initialize with a struct of your choice
    public init(_ p: Value) {
        _params = p
    }

    public init() {
        self._params = EmptyParams() as! Value
    }

    // lookup via a keypath, which gives you typed parameters...
    public subscript<T>(dynamicMember key: KeyPath<Value, T>) -> T { return _params[keyPath: key] }
}

/// A struct that holds a collection of parameters.
///
/// Parameters are referenced by a string, accessible as a subscript on the struct, that provide a value of type Double.
@dynamicMemberLookup
public struct Parameters {
    let _params: [String: Double]

    public init(_ p: [String: Double] = [:]) {
        _params = p
    }

    /// Returns the module's parameter defined by the string provided if available; otherwise, nil.
    public subscript(dynamicMember key: String) -> Double? {
        return _params[key]
    }
}

extension Parameters: CustomStringConvertible {
    /// Returns a string description for this module.
    public var description: String {
        return String(describing: _params)
    }
}

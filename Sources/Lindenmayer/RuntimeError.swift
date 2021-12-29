//
//  RuntimeError.swift
//
//
//  Created by Joseph Heck on 12/20/21.
//

import Foundation

/// A run-time error that exposes the specific type of module that was involved with the error.
public struct RuntimeError<T: Module>: Error {
    let message: String

    public init(_ t: Module) {
        message = "Downcasting failure on module \(t.description)"
    }

    public init(_ msg: String) {
        message = msg
    }

    public var localizedDescription: String {
        return message
    }
}

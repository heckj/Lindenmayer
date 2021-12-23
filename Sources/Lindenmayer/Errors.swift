//
//  Errors.swift
//  
//
//  Created by Joseph Heck on 12/20/21.
//

import Foundation

public struct RuntimeError<T:Module>: Error {
    let message: String

    public init(_ t: Module) {
        self.message = "Downcasting failure on module \(t.description)"
    }
    
    public init(_ msg: String) {
        self.message = msg
    }

    public var localizedDescription: String {
        return message
    }
    
}


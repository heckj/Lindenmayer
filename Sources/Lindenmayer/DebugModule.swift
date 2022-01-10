//
//  DebugModule.swift
//  
//
//  Created by Joseph Heck on 1/10/22.
//

import Foundation

public class DebugModule: Identifiable {
    public let module: Module
    public let new: Bool
    public let id: Int
    init(_ m: Module, at: Int, isNew: Bool = false) {
        self.id = at
        self.module = m
        self.new = isNew
    }
}

extension DebugModule: Equatable {
    public static func == (lhs: DebugModule, rhs: DebugModule) -> Bool {
        lhs.id == rhs.id && lhs.module.name == rhs.module.name
    }
}

public extension LSystem {
    func state(at: Int) -> DebugModule {
        precondition(at >= 0 && at < state.count && at < newStateIndicators.count)
        return DebugModule(state[at], at: at, isNew: newStateIndicators[at])
    }
}


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
    private let _filteredAndSortedKeys: [String]
    public var mirroredProperties: [String] {
        _filteredAndSortedKeys
    }

    public func valueOf(_ propertyKey: String) -> String? {
        if module.children().keys.contains(propertyKey) {
            if let value = module.children()[propertyKey] {
                // if we can convert this over into a Double (pretty common), then reformat it down
                // to a notably shorter string for display purposes.
                if let asDouble = Double(value) {
                    return asDouble.formatted(.number.precision(
                        .integerAndFractionLength(integerLimits: 1 ... 2, fractionLimits: 0 ... 3))
                    )
                }
            }
            return module.children()[propertyKey]
        }
        return nil
    }

    init(_ m: Module, at: Int, isNew: Bool = false) {
        id = at
        module = m
        new = isNew
        _filteredAndSortedKeys = module.children().keys
            .filter { $0 != "name" }
            .sorted()
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

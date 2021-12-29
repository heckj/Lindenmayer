//
//  ModuleSet.swift
//
//
//  Created by Joseph Heck on 12/28/21.
//

import Foundation

public struct ModuleSet {
    var leftInstance: Module?
    var leftInstanceType: Module.Type?

    let directInstance: Module
    let directInstanceType: Module.Type

    var rightInstanceType: Module.Type?
    var rightInstance: Module?

    public init(directInstance: Module, directInstanceType: Module.Type) {
        self.directInstance = directInstance
        self.directInstanceType = directInstanceType
    }

    public init(leftInstance: Module?, leftInstanceType: Module.Type?, directInstance: Module, directInstanceType: Module.Type, rightInstance: Module?, rightInstanceType: Module.Type?) {
        self.leftInstance = leftInstance
        self.leftInstanceType = leftInstanceType
        self.directInstance = directInstance
        self.directInstanceType = directInstanceType
        self.rightInstance = rightInstance
        self.rightInstanceType = rightInstanceType
    }
}

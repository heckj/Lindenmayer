//
//  SnippetsForDocs.swift
//
//
//  Created by Joseph Heck on 1/23/22.
//

import Foundation
import Lindenmayer
import XCTest

final class SnippetsForDocs: XCTestCase {
    func testDebugModuleSnippets() {
        let system = Examples2D.barnsleyFern.evolved(iterations: 4)
        let debugModuleInstance = system.state(at: 14)
        print("ID: \(debugModuleInstance.id), name: \(debugModuleInstance.module.name)")

        // ID: 14, name: F
    }
}

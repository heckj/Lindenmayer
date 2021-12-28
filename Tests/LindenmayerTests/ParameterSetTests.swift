//
//  ParameterSetTests.swift
//
//
//  Created by Joseph Heck on 12/20/21.
//

import Lindenmayer
import XCTest

final class ParameterSetTests: XCTestCase {
    func testBasicParameters() throws {
        let x = Parameters()
        XCTAssertNotNil(x)
        XCTAssertNil(x[dynamicMember: "something"])
        XCTAssertNil(x.something)
    }

    func testParameterLookup() throws {
        let x = Parameters(["something": 42.0])
        XCTAssertNotNil(x)
        XCTAssertNotNil(x[dynamicMember: "something"])
        XCTAssertNotNil(x.something)
        XCTAssertEqual(x.something, 42.0)
    }
}

//
//  AngleTests.swift
//
//
//  Created by Joseph Heck on 1/22/22.
//

import Lindenmayer
import XCTest

final class AngleTests: XCTestCase {
    func testSimpleAngleInit() throws {
        let x = SimpleAngle()
        XCTAssertEqual(0, x.radians)
        XCTAssertEqual(0, x.degrees)
    }

    func testSimpleAngleInitRadian() throws {
        let x = SimpleAngle(radians: Double.pi)
        XCTAssertEqual(Double.pi, x.radians, accuracy: 0.00001)
        XCTAssertEqual(180, x.degrees, accuracy: 0.00001)
    }

    func testSimpleAngleInitDegree() throws {
        let x = SimpleAngle(degrees: 60.0)
        XCTAssertEqual(x.radians, Double.pi / 3.0, accuracy: 0.00001)
        XCTAssertEqual(60, x.degrees, accuracy: 0.00001)
    }
}

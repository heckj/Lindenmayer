//
//  PWrapperTests.swift
//
//
//  Created by Joseph Heck on 1/4/22.
//

@testable import Lindenmayer
import Squirrel3
import XCTest

final class PWrapperTests: XCTestCase {
    func testInitalParameter() throws {
        struct P: Equatable {
            let value: Int
        }
        let initialP = P(value: 10)

        let f = Lindenmayer.withDefines(Modules.Internode(), prng: PRNG(seed: 0), parameters: initialP)
            .rewriteWithParams(directContext: Modules.Internode.self) { m, params in
                XCTAssertEqual(params.value, 10)
                return [m]
            }
        let next = f.evolve()
        XCTAssertEqual(f.parameters.unwrap().value, 10)
        XCTAssertNotNil(next)
    }

    func testUpdatedParameter() throws {
        struct P: Equatable {
            let value: Int
        }
        let initialP = P(value: 10)

        let f = Lindenmayer.withDefines(Modules.Internode(), prng: PRNG(seed: 0), parameters: initialP)
            .rewriteWithParams(directContext: Modules.Internode.self) { m, params in
                XCTAssertEqual(params.value, 13)
                return [m]
            }
        XCTAssertEqual(f.parameters.unwrap().value, 10)
        f.parameters.update(P(value: 13))
        let next = f.evolve()
        XCTAssertEqual(f.parameters.unwrap().value, 13)
        XCTAssertNotNil(next)
    }
}

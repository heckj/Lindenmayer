//
//  PWrapperTests.swift
//
//
//  Created by Joseph Heck on 1/4/22.
//

@testable import Lindenmayer
import XCTest

final class PWrapperTests: XCTestCase {
    func testInitalParameter() throws {
        struct P: Equatable {
            let value: Int
        }
        let initialP = P(value: 10)

        let f = LSystem.create(Examples2D.Internode(), with: Xoshiro(seed: 0), using: initialP)
            .rewriteWithParams(directContext: Examples2D.Internode.self) { m, params in
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

        let f = LSystem.create(Examples2D.Internode(), with: Xoshiro(seed: 0), using: initialP)
            .rewriteWithParams(directContext: Examples2D.Internode.self) { m, params in
                XCTAssertEqual(params.value, 13)
                return [m]
            }
        XCTAssertEqual(f.parameters.unwrap().value, 10)
        f.parameters.update(P(value: 13))
        let next = f.evolve()
        XCTAssertEqual(f.parameters.unwrap().value, 13)
        XCTAssertNotNil(next)
    }

    func testCodabling() throws {
        let x = JSONEncoder()
        let zzz = try x.encode(Examples3D.figure2_6B)
        print(String(data: zzz, encoding: .utf8)!)
        /*
         {"contractionRatioForTrunk":0.9,"widthContraction":0.707,"lateralBranchAngle":45,"trunklength":10,"trunkdiameter":1,"branchAngle":45,"divergence":137.5,"contractionRatioForBranch":0.9}
         */
    }
}

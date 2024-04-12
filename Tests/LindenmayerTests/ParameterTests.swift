//
//  ParameterTests.swift
//
//
//  Created by Joseph Heck on 1/4/22.
//

@testable import Lindenmayer
import XCTest

final class ParameterTests: XCTestCase {
    func testInitalParameter() async throws {
        struct P: Equatable {
            let value: Int
        }
        let initialP = P(value: 10)

        let f = LSystem.create(Examples2D.Internode(), with: Xoshiro(seed: 0), using: initialP)
            .rewriteWithParams(directContext: Examples2D.Internode.self) { m, params in
                XCTAssertEqual(params.value, 10)
                return [m]
            }
        let next = await f.evolve()
        XCTAssertEqual(f.parameters.value, 10)
        XCTAssertNotNil(next)
    }

    func testCodabling() throws {
        let x = JSONEncoder()
        let zzz = try x.encode(Examples3D.figure2_6B)
        print(String(data: zzz, encoding: .utf8)!)
        /*
         {"trunkdiameter":1,"lateralBranchAngle":45,"contractionRatioForBranch":0.9,"divergence":137.5,"contractionRatioForTrunk":0.9,"widthContraction":0.707,"branchAngle":45,"trunklength":10}
         */
    }
}

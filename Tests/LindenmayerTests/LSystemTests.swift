@testable import Lindenmayer
import XCTest

final class LSystemTests: XCTestCase {
    func testLSystemDefault() async throws {
        let x = RandomContextualLSystem(axiom: [Examples2D.Internode()], state: nil, newStateIndicators: nil, prng: RNGWrapper(Xoshiro(seed: 0)))
        XCTAssertNotNil(x)

        let result = x.state
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(x.newStateIndicators.count, 1)
        XCTAssertEqual(x.newStateIndicators[0], true)

        XCTAssertEqual(result[0].description, "I")
        XCTAssertEqual(result[0].render2D.count, 1)
        XCTAssertEqual(result[0].render2D[0].name, RenderCommand.Draw(length: 10).name)
        XCTAssertEqual(result[0].render3D.name, RenderCommand.Ignore().name)

        let updated = await x.evolve()
        XCTAssertEqual(updated.state.count, 1)
        XCTAssertEqual(updated.state.count, updated.newStateIndicators.count)
        let downcast = updated.state[0] as! Examples2D.Internode
        XCTAssertEqual(downcast.description, "I")
    }

    func testAlgaeLSystem_evolve1() async throws {
        let algae = Examples2D.algae
        XCTAssertNotNil(algae)
        XCTAssertEqual(algae.state.count, 1)
        XCTAssertEqual(algae.state.map(\.description).joined(), "A")

        let iter1 = await algae.evolve() // debugPrint: true
        XCTAssertEqual(iter1.state.count, 2)
        XCTAssertEqual(iter1.state.count, iter1.newStateIndicators.count)

        XCTAssertEqual(iter1.state[0].description, "A")
        XCTAssertEqual(iter1.state[1].description, "B")

        let resultSequence = iter1.state.map(\.description).joined()
        XCTAssertEqual(resultSequence, "AB")
    }

    func testAlgaeLSystem_evolve2() async throws {
        var resultSequence = ""
        let algae = Examples2D.algae
        let iter2 = await algae.evolve()
        resultSequence = iter2.state.map(\.description).joined()
        XCTAssertEqual(resultSequence, "AB")
        let iter3 = await iter2.evolve() // debugPrint: true
        resultSequence = iter3.state.map(\.description).joined()
        XCTAssertEqual(resultSequence, "ABA")
        XCTAssertEqual(iter3.state.count, iter3.newStateIndicators.count)
    }

    func testAlgaeLSystem_evolve3() async throws {
        var resultSequence = ""
        let algae = Examples2D.algae
        let evolution = await algae.evolved(iterations: 3)
        resultSequence = evolution.state.map(\.description).joined()
        XCTAssertEqual(resultSequence, "ABAAB")
        let evolution2 = await evolution.evolve()
        resultSequence = evolution2.state.map(\.description).joined()
        XCTAssertEqual(resultSequence, "ABAABABA")
        XCTAssertEqual(evolution2.state.count, evolution2.newStateIndicators.count)
    }

    func testFractalTree_evolve2() async throws {
        let tree = Examples2D.fractalTree
        let evo1 = await tree.evolve()
        XCTAssertEqual(evo1.state.map(\.description).joined(), "I[+L]-L")
        XCTAssertEqual(evo1.newStateIndicators, [true, true, true, true, true, true, true])
        let evo2 = await evo1.evolve()
        XCTAssertEqual(evo2.state.map(\.description).joined(), "II[+I[+L]-L]-I[+L]-L")
    }

    func testLSystem_kochCurve() async throws {
        let tree = Examples2D.kochCurve
        let evo1 = await tree.evolved(iterations: 3)
        XCTAssertEqual(evo1.state.map(\.description).joined(),
                       "F+F-F-F+F+F+F-F-F+F-F+F-F-F+F-F+F-F-F+F+F+F-F-F+F+F+F-F-F+F+F+F-F-F+F-F+F-F-F+F-F+F-F-F+F+F+F-F-F+F-F+F-F-F+F+F+F-F-F+F-F+F-F-F+F-F+F-F-F+F+F+F-F-F+F-F+F-F-F+F+F+F-F-F+F-F+F-F-F+F-F+F-F-F+F+F+F-F-F+F+F+F-F-F+F+F+F-F-F+F-F+F-F-F+F-F+F-F-F+F+F+F-F-F+F")
        print(evo1.newStateIndicators)
    }
}

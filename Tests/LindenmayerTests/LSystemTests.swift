import Lindenmayer
import Squirrel3
import XCTest

final class LSystemTests: XCTestCase {
    func testLSystemDefault() throws {
        let x = LSystemRNG<PRNG>(axiom: [Modules.Internode()], state: nil, newStateIndicators: nil, prng: RNGWrapper(PRNG(seed: 0)))
        XCTAssertNotNil(x)

        let result = x.state
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(x.newStateIndicators.count, 1)
        XCTAssertEqual(x.newStateIndicators[0], true)

        XCTAssertEqual(result[0].description, "I")
        XCTAssertEqual(result[0].render2D.count, 1)
        XCTAssertEqual(result[0].render2D[0].name, RenderCommand.Draw(length: 10).name)
        XCTAssertEqual(result[0].render3D.name, RenderCommand.Ignore().name)

        let updated = x.evolve()
        XCTAssertEqual(updated.state.count, 1)
        XCTAssertEqual(updated.state.count, updated.newStateIndicators.count)
        let downcast = updated.state[0] as! Modules.Internode
        XCTAssertEqual(downcast.description, "I")
    }

    func testAlgaeLSystem_evolve1() throws {
        let algae = Examples2D.algae.lsystem
        XCTAssertNotNil(algae)
        XCTAssertEqual(algae.state.count, 1)
        XCTAssertEqual(algae.state.map { $0.description }.joined(), "A")

        let iter1 = algae.evolve() // debugPrint: true
        XCTAssertEqual(iter1.state.count, 2)
        XCTAssertEqual(iter1.state.count, iter1.newStateIndicators.count)

        XCTAssertEqual(iter1.state[0].description, "A")
        XCTAssertEqual(iter1.state[1].description, "B")

        let resultSequence = iter1.state.map { $0.description }.joined()
        XCTAssertEqual(resultSequence, "AB")
    }

    func testAlgaeLSystem_evolve2() throws {
        var resultSequence = ""
        let algae = Examples2D.algae.lsystem
        let iter2 = algae.evolve()
        resultSequence = iter2.state.map { $0.description }.joined()
        XCTAssertEqual(resultSequence, "AB")
        let iter3 = iter2.evolve() // debugPrint: true
        resultSequence = iter3.state.map { $0.description }.joined()
        XCTAssertEqual(resultSequence, "ABA")
        XCTAssertEqual(iter3.state.count, iter3.newStateIndicators.count)
    }

    func testAlgaeLSystem_evolve3() throws {
        var resultSequence = ""
        let algae = Examples2D.algae.lsystem
        let evolution = algae.evolved(iterations: 3)
        resultSequence = evolution.state.map { $0.description }.joined()
        XCTAssertEqual(resultSequence, "ABAAB")
        let evolution2 = evolution.evolve()
        resultSequence = evolution2.state.map { $0.description }.joined()
        XCTAssertEqual(resultSequence, "ABAABABA")
        XCTAssertEqual(evolution2.state.count, evolution2.newStateIndicators.count)
    }

    func testFractalTree_evolve2() throws {
        let tree = Examples2D.fractalTree.lsystem
        let evo1 = tree.evolve()
        XCTAssertEqual(evo1.state.map { $0.description }.joined(), "I[+L]-L")
        XCTAssertEqual(evo1.newStateIndicators, [true, true, true, true, true, true, true])
        let evo2 = evo1.evolve()
        XCTAssertEqual(evo2.state.map { $0.description }.joined(), "II[+I[+L]-L]-I[+L]-L")
    }

    func testLSystem_kochCurve() throws {
        let tree = Examples2D.kochCurve.lsystem
        let evo1 = tree.evolved(iterations: 3)
        XCTAssertEqual(evo1.state.map { $0.description }.joined(),
                       "F+F-F-F+F+F+F-F-F+F-F+F-F-F+F-F+F-F-F+F+F+F-F-F+F+F+F-F-F+F+F+F-F-F+F-F+F-F-F+F-F+F-F-F+F+F+F-F-F+F-F+F-F-F+F+F+F-F-F+F-F+F-F-F+F-F+F-F-F+F+F+F-F-F+F-F+F-F-F+F+F+F-F-F+F-F+F-F-F+F-F+F-F-F+F+F+F-F-F+F+F+F-F-F+F+F+F-F-F+F-F+F-F-F+F-F+F-F-F+F+F+F-F-F+F")
        print(evo1.newStateIndicators)
    }
}

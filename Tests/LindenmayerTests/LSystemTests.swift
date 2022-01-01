import Lindenmayer
import XCTest

final class LSystemTests: XCTestCase {
    func testLSystemDefault() throws {
        let x = NoDefinesLSystem<HasherPRNG>([Modules.internode], prng: HasherPRNG(seed: 42))
        XCTAssertNotNil(x)

        let result = x.state
        XCTAssertEqual(result.count, 1)

        XCTAssertEqual(result[0].description, "I")
        XCTAssertEqual(result[0].render2D, [.draw(10)])
        XCTAssertEqual(result[0].render3D, .ignore)

        let updated = try x.evolve()
        XCTAssertEqual(updated.state.count, 1)
        let downcast = updated.state[0] as! Modules.Internode
        XCTAssertEqual(downcast.description, "I")
    }

    func testAlgaeLSystem_evolve1() throws {
        let algae = Examples2D.algae.lsystem
        XCTAssertNotNil(algae)
        XCTAssertEqual(algae.state.count, 1)
        XCTAssertEqual(algae.state.map { $0.description }.joined(), "A")

        let iter1 = try algae.evolve() // debugPrint: true
        XCTAssertEqual(iter1.state.count, 2)

        XCTAssertEqual(iter1.state[0].description, "A")
        XCTAssertEqual(iter1.state[1].description, "B")

        let resultSequence = iter1.state.map { $0.description }.joined()
        XCTAssertEqual(resultSequence, "AB")
    }

    func testAlgaeLSystem_evolve2() throws {
        var resultSequence = ""
        let algae = Examples2D.algae.lsystem
        let iter2 = try algae.evolve()
        resultSequence = iter2.state.map { $0.description }.joined()
        XCTAssertEqual(resultSequence, "AB")
        let iter3 = try iter2.evolve() // debugPrint: true
        resultSequence = iter3.state.map { $0.description }.joined()
        XCTAssertEqual(resultSequence, "ABA")
    }

    func testAlgaeLSystem_evolve3() throws {
        var resultSequence = ""
        let algae = Examples2D.algae.lsystem
        let evolution = try algae.evolve(iterations: 3)
        resultSequence = evolution.state.map { $0.description }.joined()
        XCTAssertEqual(resultSequence, "ABAAB")
        let evolution2 = try evolution.evolve()
        resultSequence = evolution2.state.map { $0.description }.joined()
        XCTAssertEqual(resultSequence, "ABAABABA")
    }

    func testFractalTree_evolve2() throws {
        let tree = Examples2D.fractalTree.lsystem
        let evo1 = try tree.evolve()
        XCTAssertEqual(evo1.state.map { $0.description }.joined(), "I[-L]+L")
        let evo2 = try evo1.evolve()
        XCTAssertEqual(evo2.state.map { $0.description }.joined(), "II[-I[-L]+L]+I[-L]+L")
    }

    func testLSystem_kochCurve() throws {
        let tree = Examples2D.kochCurve.lsystem
        let evo1 = try tree.evolve(iterations: 3)
        XCTAssertEqual(evo1.state.map { $0.description }.joined(),
                       "F-F+F+F-F-F-F+F+F-F+F-F+F+F-F+F-F+F+F-F-F-F+F+F-F-F-F+F+F-F-F-F+F+F-F+F-F+F+F-F+F-F+F+F-F-F-F+F+F-F+F-F+F+F-F-F-F+F+F-F+F-F+F+F-F+F-F+F+F-F-F-F+F+F-F+F-F+F+F-F-F-F+F+F-F+F-F+F+F-F+F-F+F+F-F-F-F+F+F-F-F-F+F+F-F-F-F+F+F-F+F-F+F+F-F+F-F+F+F-F-F-F+F+F-F")
    }
}

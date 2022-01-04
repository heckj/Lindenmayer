@testable import Lindenmayer
import Squirrel3
import XCTest

final class PRNGWrapperTests: XCTestCase {
    func testConsistency_HasherPRNG() throws {
        let seed: UInt64 = 235_474_323
        var firstResults: [UInt64] = []
        var subject1 = PRNG(seed: seed)
        for _ in 0 ... 10 {
            firstResults.append(subject1.next())
        }

        var secondResults: [UInt64] = []
        var subject2 = PRNG(seed: seed)
        for _ in 0 ... 10 {
            secondResults.append(subject2.next())
        }
        XCTAssertEqual(firstResults, secondResults)
    }

    func testInconsistency_HasherPRNG() throws {
        let seed: UInt64 = 235_474_323
        var firstResults: [UInt64] = []
        var subject1 = PRNG(seed: seed)
        for _ in 0 ... 10 {
            firstResults.append(subject1.next())
        }

        var secondResults: [UInt64] = []
        var subject2 = PRNG(seed: seed + 1)
        for _ in 0 ... 10 {
            secondResults.append(subject2.next())
        }
        XCTAssertNotEqual(firstResults, secondResults)
    }

    func testPosition_PRNG() throws {
        let seed: UInt64 = 34634
        var firstResults: [UInt64] = []
        var subject1 = PRNG(seed: seed)
        let capturedPosition = subject1.position
        for _ in 0 ... 10 {
            firstResults.append(subject1.next())
        }

        var secondResults: [UInt64] = []
        var subject2 = PRNG(seed: seed)
        subject2.position = capturedPosition
        for _ in 0 ... 10 {
            secondResults.append(subject2.next())
        }

        XCTAssertEqual(firstResults, secondResults)
    }

    func testCheckingRNGReferenceType() throws {
        // requires `@testable import Lindenmayer` to get to the DetailedExamples struct
        let start = Detailed3DExamples.randomBush

        XCTAssertEqual(start.prng.seed, 42)
        XCTAssertEqual(start.prng._invokeCount, 0)

        let oneEv = start.evolve()
        XCTAssertEqual(oneEv.prng.seed, 42)
        XCTAssertEqual(oneEv.prng._invokeCount, 2)
        // print(oneEv.prng.position)

        let sideTest = RNGWrapper(PRNG(seed: 42))
        _ = sideTest.p()
        _ = sideTest.p()
        XCTAssertEqual(sideTest._invokeCount, 2)
        XCTAssertEqual(sideTest.position, oneEv.prng.position)

        let twoEv = oneEv.evolve()
        // Even though evolve is returning a new LSystem, the underlying reference to the RNG should be the same - so it
        // continues to move forward as new evolutions are invoked.
        XCTAssertEqual(twoEv.prng._invokeCount, 4)
        start.prng.resetRNG(seed: start.prng.seed)
    }

    func testResettingPRNG() throws {
        // requires `@testable import Lindenmayer` to get to the DetailedExamples struct
        let start = Detailed3DExamples.randomBush

        XCTAssertEqual(start.prng.seed, 42)
        XCTAssertEqual(start.prng._invokeCount, 0)

        let oneEv = start.evolve()

        XCTAssertEqual(oneEv.prng.seed, 42)
        XCTAssertEqual(oneEv.prng._invokeCount, 2)

        start.prng.resetRNG(seed: start.prng.seed)
        XCTAssertEqual(oneEv.prng.seed, 42)
        XCTAssertEqual(oneEv.prng.position, 42)
        XCTAssertEqual(oneEv.prng._invokeCount, 0)
    }
}

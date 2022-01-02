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
        let start = DetailedExamples.randomBush

        XCTAssertEqual(start.prng._prng.seed, 42)
        XCTAssertEqual(start.prng._invokeCount, 0)

        let oneEv = try start.evolve()
        let downcastOneEv = oneEv as! LSystemRNG<PRNG>
        XCTAssertEqual(downcastOneEv.prng._prng.seed, 42)
        XCTAssertEqual(downcastOneEv.prng._invokeCount, 2)
        // print(downcastOneEv.prng._prng.position)

        let sideTest = RNGWrapper(PRNG(seed: 42))
        _ = sideTest.p()
        _ = sideTest.p()
        XCTAssertEqual(sideTest._invokeCount, 2)
        XCTAssertEqual(sideTest._prng.position, downcastOneEv.prng._prng.position)

        let twoEv = try oneEv.evolve()
        let downcastTwoEv = twoEv as! LSystemRNG<PRNG>
        // Even though evolve is returning a new LSystem, the underlying reference to the RNG should be the same - so it
        // continues to move forward as new evolutions are invoked.
        XCTAssertEqual(downcastTwoEv.prng._invokeCount, 4)
        XCTAssertEqual(downcastOneEv.prng._invokeCount, 4)
    }
}

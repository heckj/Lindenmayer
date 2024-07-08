@testable import Lindenmayer
import XCTest

final class PRNGWrapperTests: XCTestCase {
    func testConsistency_HasherPRNG() throws {
        let seed: UInt64 = 235_474_323
        var firstResults: [UInt64] = []
        var subject1 = Xoshiro(seed: seed)
        for _ in 0 ... 10 {
            firstResults.append(subject1.next())
        }

        var secondResults: [UInt64] = []
        var subject2 = Xoshiro(seed: seed)
        for _ in 0 ... 10 {
            secondResults.append(subject2.next())
        }
        XCTAssertEqual(firstResults, secondResults)
    }

    func testInconsistency_HasherPRNG() throws {
        let seed: UInt64 = 235_474_323
        var firstResults: [UInt64] = []
        var subject1 = Xoshiro(seed: seed)
        for _ in 0 ... 10 {
            firstResults.append(subject1.next())
        }

        var secondResults: [UInt64] = []
        var subject2 = Xoshiro(seed: seed + 1)
        for _ in 0 ... 10 {
            secondResults.append(subject2.next())
        }
        XCTAssertNotEqual(firstResults, secondResults)
    }

    func testPosition_PRNG() throws {
        let seed: UInt64 = 34634
        var firstResults: [UInt64] = []
        var subject1 = Xoshiro(seed: seed)
        let capturedPosition = subject1.position
        for _ in 0 ... 10 {
            firstResults.append(subject1.next())
        }

        var secondResults: [UInt64] = []
        var subject2 = Xoshiro(seed: seed)
        subject2.position = capturedPosition
        for _ in 0 ... 10 {
            secondResults.append(subject2.next())
        }

        XCTAssertEqual(firstResults, secondResults)
    }

    func testCheckingRNGReferenceType() async throws {
        // requires `@testable import Lindenmayer` to get to the DetailedExamples struct
        let start = Examples3D.randomBush

        var seedValue = await start.prng.seed
        var _invokeCount = await start.prng._invokeCount
        XCTAssertEqual(seedValue, 42)
        XCTAssertEqual(_invokeCount, 0)

        let oneEv = await start.evolve()
        seedValue = await start.prng.seed
        _invokeCount = await start.prng._invokeCount
        XCTAssertEqual(seedValue, 42)
        XCTAssertEqual(_invokeCount, 2)
        // print(oneEv.prng.position)

        let sideTest = RNGWrapper(Xoshiro(seed: 42))
        _ = await sideTest.p()
        _ = await sideTest.p()
        _invokeCount = await sideTest._invokeCount
        let sideTestPosition = await sideTest.position
        let oneEvPosition = await sideTest.position
        XCTAssertEqual(_invokeCount, 2)
        XCTAssertEqual(sideTestPosition, oneEvPosition)

        let twoEv = await oneEv.evolve()
        // Even though evolve is returning a new LSystem, the underlying reference to the RNG should be the same - so it
        // continues to move forward as new evolutions are invoked.
        _invokeCount = await twoEv.prng._invokeCount
        XCTAssertEqual(_invokeCount, 4)
        await start.prng.resetRNG()
        _invokeCount = await start.prng._invokeCount
        XCTAssertEqual(_invokeCount, 0)
    }

    func testResettingPRNG() async throws {
        // requires `@testable import Lindenmayer` to get to the DetailedExamples struct
        let start = Examples3D.randomBush

        var seed = await start.prng.seed
        var _invokeCount = await start.prng._invokeCount
        XCTAssertEqual(seed, 42)
        XCTAssertEqual(_invokeCount, 0)

        let oneEv = await start.evolve()

        seed = await oneEv.prng.seed
        _invokeCount = await oneEv.prng._invokeCount

        XCTAssertEqual(seed, 42)
        XCTAssertEqual(_invokeCount, 2)

        await start.prng.resetRNG()
        let position = await oneEv.prng.position
        seed = await oneEv.prng.seed
        _invokeCount = await oneEv.prng._invokeCount
        XCTAssertEqual(seed, 42)
        XCTAssertEqual(position, 0)
        XCTAssertEqual(_invokeCount, 0)
    }
}

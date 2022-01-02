import Lindenmayer
import Squirrel3
import XCTest

final class HasherPRNGTests: XCTestCase {
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
}

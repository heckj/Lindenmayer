import Lindenmayer
import XCTest

final class HasherPRNGTests: XCTestCase {
    
    func testConsistency_HasherPRNG() throws {
        let seed: UInt32 = 235474323
        var firstResults: [Int] = []
        let subject1 = HasherPRNG(seed: seed)
        for _ in 0...10 {
            firstResults.append(subject1.randomInt())
        }
        
        var secondResults: [Int] = []
        let subject2 = HasherPRNG(seed: seed)
        for _ in 0...10 {
            secondResults.append(subject2.randomInt())
        }
        XCTAssertEqual(firstResults, secondResults)
    }

    func testInconsistency_HasherPRNG() throws {
        let seed: UInt32 = 235474323
        var firstResults: [Int] = []
        let subject1 = HasherPRNG(seed: seed)
        for _ in 0...10 {
            firstResults.append(subject1.randomInt())
        }
        
        var secondResults: [Int] = []
        let subject2 = HasherPRNG(seed: seed+1)
        for _ in 0...10 {
            secondResults.append(subject2.randomInt())
        }
        XCTAssertNotEqual(firstResults, secondResults)
    }

    func testPosition_HasherPRNG() throws {
        let seed: UInt32 = 34634
        var firstResults: [UInt64] = []
        let subject1 = HasherPRNG(seed: seed)
        for _ in 0...10 {
            firstResults.append(subject1.next())
        }
        
        XCTAssertEqual(subject1.position, 11)
        var secondResults: [UInt64] = []
        let subject2 = HasherPRNG(seed: seed)
        for _ in 0...10 {
            secondResults.append(subject2.next())
        }
        XCTAssertEqual(subject2.position, 11)
        
        XCTAssertEqual(firstResults, secondResults)
    }


}

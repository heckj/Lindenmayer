import Lindenmayer
import Squirrel3
import XCTest

final class HasherPRNGTests: XCTestCase {
    func testConsistency_HasherPRNG() throws {
        let seed: UInt64 = 235_474_323
        var firstResults: [Int] = []
        var subject1 = HasherPRNG(seed: seed)
        for _ in 0 ... 10 {
            firstResults.append(subject1.randomInt())
        }
        
        var secondResults: [Int] = []
        var subject2 = HasherPRNG(seed: seed)
        for _ in 0 ... 10 {
            secondResults.append(subject2.randomInt())
        }
        XCTAssertEqual(firstResults, secondResults)
    }
    
    func testInconsistency_HasherPRNG() throws {
        let seed: UInt64 = 235_474_323
        var firstResults: [Int] = []
        var subject1 = HasherPRNG(seed: seed)
        for _ in 0 ... 10 {
            firstResults.append(subject1.randomInt())
        }
        
        var secondResults: [Int] = []
        var subject2 = HasherPRNG(seed: seed + 1)
        for _ in 0 ... 10 {
            secondResults.append(subject2.randomInt())
        }
        XCTAssertNotEqual(firstResults, secondResults)
    }
    
    func testPosition_HasherPRNG() throws {
        let seed: UInt64 = 34634
        var firstResults: [UInt64] = []
        var subject1 = HasherPRNG(seed: seed)
        for _ in 0 ... 10 {
            firstResults.append(subject1.next())
        }
        
        XCTAssertEqual(subject1.position, 11)
        var secondResults: [UInt64] = []
        var subject2 = HasherPRNG(seed: seed)
        for _ in 0 ... 10 {
            secondResults.append(subject2.next())
        }
        XCTAssertEqual(subject2.position, 11)
        
        XCTAssertEqual(firstResults, secondResults)
    }
    
    
    
    func testFairness() throws {
        
        var rng = HasherPRNG(seed: UInt64.random(in: 0 ..< 1_000_000))
        
        let flips = 1_000_000
        var heads = 0
        for _ in 0 ..< flips {
            if Bool.random(using: &rng) {
                heads += 1
            }
        }
        
        let p = 0.5
        let μ = Double(flips) * p
        let ɑ = sqrt(Double(flips) * p * (1.0 - p))
        
        print("After \(flips) coin flips, we got \(heads). Expected: \(μ) Standard deviation: \(ɑ)")
        XCTAssert( ( μ - 2*ɑ ... μ + 2*ɑ).contains(Double(heads)) )
    }
    
    func testMinCycles() throws {
        var rng = HasherPRNG(seed: UInt64.random(in: 0 ..< 1_000_000))
        
        let targetMinCycles = 1_000_000
        var results = Set<UInt64>()
        
        var collision = false
        var i = 0;
        while i < targetMinCycles && collision == false {
            let result = rng.next()
            if results.contains(result) {
                collision = true
            }
            results.insert(result)
            i += 1
        }
        
        XCTAssertEqual(results.count, targetMinCycles)
        
    }
    
    func testNotSameResult() throws {
        for x: UInt64 in 0 ... 1_000_000 {
            var rnd = HasherPRNG(seed: x)
            XCTAssertNotEqual(x, rnd.next())
        }
    }
    
    func testNoCollisions() throws {
        let targetMinCycles = 1_000_000
        var results = Set<UInt64>()
        
        var collision = false
        var i: UInt64 = 0;
        while i < targetMinCycles && collision == false {
            var rnd = HasherPRNG(seed: i)
            let result = rnd.next()
            if results.contains(result) {
                collision = true
            }
            results.insert(result)
            i += 1
        }
        
        XCTAssertEqual(results.count, targetMinCycles)
    }
    
    func testSquirrel3Performance() throws {
        // This is an example of a performance test case.
        var pass = 0
        self.measure {
            pass += 1
            var rng = PRNG(seed: UInt64.random(in: 0 ..< 1_000_000))
            // Put the code you want to measure the time of here.
            // Generate a lot of bools
            
            var heads = 0
            for _ in 0 ..< 1_000_000 {
                if Bool.random(using: &rng) {
                    heads += 1
                }
            }
            print("Pass: \(pass) - number of heads: \(heads).")
        }
    }
    
    func testHasherPRNGPerformance() throws {
        // This is an example of a performance test case.
        var pass = 0
        self.measure {
            pass += 1
            var rng = HasherPRNG(seed: UInt64.random(in: 0 ..< 1_000_000))
            // Put the code you want to measure the time of here.
            // Generate a lot of bools
            
            var heads = 0
            for _ in 0 ..< 1_000_000 {
                if Bool.random(using: &rng) {
                    heads += 1
                }
            }
            print("Pass: \(pass) - number of heads: \(heads).")
        }
    }    
}

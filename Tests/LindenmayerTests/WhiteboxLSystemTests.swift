@testable import Lindenmayer
import Squirrel3
import XCTest

final class WhiteboxLSystemTests: XCTestCase {
    func testLSystemDefault() throws {
        let x = LSystemRNG<PRNG>(axiom: [Modules.Internode()], state: nil, prng: RNGWrapper(PRNG(seed: 0)))
        XCTAssertNotNil(x)
        // Verify internal state of LSystem:
        // No rules
        XCTAssertEqual(x.rules.count, 0)
        // 1 atom in the state - the axiom
        XCTAssertEqual(x.state.count, 1)
        let downcast = x.state[0] as! Modules.Internode
        XCTAssertEqual(downcast.description, "I")
    }
}

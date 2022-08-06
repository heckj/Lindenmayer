@testable import Lindenmayer
import XCTest

final class WhiteboxLSystemTests: XCTestCase {
    func testLSystemDefault() throws {
        let x = RandomContextualLSystem(axiom: [Examples2D.Internode()], state: nil, newStateIndicators: nil, prng: RNGWrapper(Xoshiro(seed: 0)))
        XCTAssertNotNil(x)
        // Verify internal state of LSystem:
        // No rules
        XCTAssertEqual(x.rules.count, 0)
        // 1 atom in the state - the axiom
        XCTAssertEqual(x.state.count, 1)
        let downcast = x.state[0] as! Examples2D.Internode
        XCTAssertEqual(downcast.description, "I")
    }
}

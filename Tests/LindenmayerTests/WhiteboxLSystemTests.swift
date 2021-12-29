@testable import Lindenmayer
import XCTest

final class WhiteboxLSystemTests: XCTestCase {
    func testLSystemDefault() throws {
        let x = NonParameterizedLSystem(Lindenmayer.Modules.internode)
        XCTAssertNotNil(x)
        // Verify internal state of LSystem:
        // No rules
        XCTAssertEqual(x.rules.count, 0)
        // 1 atom in the state - the axiom
        XCTAssertEqual(x.state.count, 1)
        let downcast = x.state[0] as! Lindenmayer.Modules.Internode
        XCTAssertEqual(downcast.description, "I")
    }
}

@testable import Lindenmayer
import XCTest

final class WhiteboxRuleTests: XCTestCase {
    func testRuleDefaults() throws {
        let r = RewriteRuleDirect(direct: Examples2D.Internode.self,
                                  where: nil)
        { ctx in
            [ctx]
        }
        XCTAssertNotNil(r)

        XCTAssertNotNil(r.matchingType)

        XCTAssertEqual(String(describing: type(of: r.matchingType)), "Internode.Type")
    }

    func testRuleProduction() throws {
        let r = RewriteRuleDirectRNG(directType: Examples2D.Internode.self, prng: RNGWrapper(Xoshiro(seed: 0)), where: nil) { _, _ in
            [Examples2D.Internode()]
        }
        XCTAssertNotNil(r)

        let set = ModuleSet(directInstance: Examples2D.Internode())
        // Verify produce returns an Internode
        let newModule = r.produce(set)
        XCTAssertEqual(newModule.count, 1)
        XCTAssertEqual(newModule[0].description, "I")
    }
}

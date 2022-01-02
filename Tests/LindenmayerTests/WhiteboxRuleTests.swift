@testable import Lindenmayer
import Squirrel3
import XCTest

final class WhiteboxRuleTests: XCTestCase {
    func testRuleDefaults() throws {
        let r = RewriteRuleDirect(direct: Modules.Internode.self,
                                  where: nil) { ctx in
            [ctx]
        }
        XCTAssertNotNil(r)
        

        XCTAssertNotNil(r.matchingType)

        XCTAssertEqual(String(describing: type(of: r.matchingType)), "Internode.Type")
    }

    func testRuleProduction() throws {
        let r = RewriteRuleDirectRNG(directType: Modules.Internode.self, prng: RNGWrapper(PRNG(seed: 0)), where: nil) { _, _ in
            [Modules.internode]
        }
        XCTAssertNotNil(r)

        let set = ModuleSet(directInstance: Modules.internode)
        // Verify produce returns an Internode
        let newModule = r.produce(set)
        XCTAssertEqual(newModule.count, 1)
        XCTAssertEqual(newModule[0].description, "I")
    }
}

@testable import Lindenmayer
import XCTest

final class WhiteboxRuleTests: XCTestCase {
    func testRuleDefaults() throws {
        let r = ParameterizedRule<EmptyParams>(Modules.Internode.self, params: AltParams(EmptyParams())) { ctx, _ throws -> [Module] in
            [ctx]
        }
        XCTAssertNotNil(r)

        // Verify matchset with basic rule
        XCTAssertNotNil(r.matchset)
        XCTAssertNil(r.matchset.0)

        // Kind of a wrong hack - Type isn't equatable, but I can get a string description of it...
        XCTAssertEqual(String(describing: r.matchset.1), "Internode")
        XCTAssertNil(r.matchset.2)
    }

    func testRuleProduction() throws {
        let r = NonParameterizedRule(Modules.Internode.self) { _ in
            [Modules.internode]
        }
        XCTAssertNotNil(r)

        let set = ModuleSet(directInstance: Modules.internode, directInstanceType: Modules.Internode.self)
        // Verify produce returns an Internode
        let newModule = try r.produce(set)
        XCTAssertEqual(newModule.count, 1)
        XCTAssertEqual(newModule[0].description, "I")
    }
}

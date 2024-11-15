@testable import Lindenmayer
import XCTest

final class RuleTests: XCTestCase {
    struct Foo: Module {
        var name: String = "foo"
    }

    func testRuleDefaults() throws {
        let r = RewriteRuleDirectRNG(directType: Examples2D.Internode.self,
                                     prng: RNGWrapper(Xoshiro(seed: 0)),
                                     where: nil)
        { ctx, _ -> [Module] in
            XCTAssertNotNil(ctx)

            return [ctx]
        }
        XCTAssertNotNil(r)
        let moduleSet = ModuleSet(directInstance: Foo())
        XCTAssertEqual(r.evaluate(moduleSet), false)
    }

    func testRuleBasicMatch() throws {
        let r = RewriteRuleDirectRNG(directType: Examples2D.Internode.self,
                                     prng: RNGWrapper(Xoshiro(seed: 0)),
                                     where: nil)
        { _, _ -> [Module] in
            [Foo()]
        }

        let moduleSet = ModuleSet(directInstance: Examples2D.Internode())
        XCTAssertEqual(r.evaluate(moduleSet), true)
    }

    func testRuleBasicFailMatch() throws {
        let r = RewriteRuleDirectRNG(directType: Examples2D.Internode.self,
                                     prng: RNGWrapper(Xoshiro(seed: 0)),
                                     where: nil)
        { _, _ -> [Module] in
            [Foo()]
        }
        let moduleSet = ModuleSet(directInstance: Foo())
        XCTAssertEqual(r.evaluate(moduleSet), false)
    }

    func testRuleMatchExtraRight() throws {
        let r = RewriteRuleDirectRNG(directType: Examples2D.Internode.self,
                                     prng: RNGWrapper(Xoshiro(seed: 0)),
                                     where: nil)
        { _, _ -> [Module] in
            [Foo()]
        }
        let moduleSet = ModuleSet(leftInstance: nil,
                                  directInstance: Examples2D.Internode(),
                                  rightInstance: Foo())
        XCTAssertEqual(r.evaluate(moduleSet), true)
    }

    func testRuleMatchExtraLeft() throws {
        let r = RewriteRuleDirectRNG(directType: Examples2D.Internode.self,
                                     prng: RNGWrapper(Xoshiro(seed: 0)),
                                     where: nil)
        { _, _ -> [Module] in
            [Foo()]
        }
        let moduleSet = ModuleSet(leftInstance: Foo(),
                                  directInstance: Examples2D.Internode(),
                                  rightInstance: nil)

        XCTAssertEqual(r.evaluate(moduleSet), true)
    }

    func testRuleMatchExtraLeftAndRight() throws {
        let r = RewriteRuleDirectRNG(directType: Examples2D.Internode.self,
                                     prng: RNGWrapper(Xoshiro(seed: 0)),
                                     where: nil)
        { _, _ -> [Module] in
            [Foo()]
        }
        let moduleSet = ModuleSet(leftInstance: Foo(),
                                  directInstance: Examples2D.Internode(),
                                  rightInstance: Foo())
        XCTAssertEqual(r.evaluate(moduleSet), true)
    }
}

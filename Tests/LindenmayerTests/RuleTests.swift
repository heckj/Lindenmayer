import Lindenmayer
import Squirrel3
import XCTest

final class RuleTests: XCTestCase {
    struct Foo: Module {
        var name: String = "foo"
    }

    let foo = Foo()

    func testRuleDefaults() throws {
        let r = RewriteRuleRNG(Modules.Internode.self, prng: RNGWrapper(PRNG(seed: 0)), nil) { ctx, _ -> [Module] in
            XCTAssertNotNil(ctx)

            return [ctx]
        }
        XCTAssertNotNil(r)
        let moduleSet = ModuleSet(directInstance: foo)
        XCTAssertEqual(r.evaluate(moduleSet), false)
    }

    func testRuleBasicMatch() throws {
        let r = RewriteRuleRNG(Modules.Internode.self, prng: RNGWrapper(PRNG(seed: 0)), nil) { _, _ -> [Module] in
            [self.foo]
        }

        let moduleSet = ModuleSet(directInstance: Modules.internode)
        XCTAssertEqual(r.evaluate(moduleSet), true)
    }

    func testRuleBasicFailMatch() throws {
        let r = RewriteRuleRNG(Modules.Internode.self, prng: RNGWrapper(PRNG(seed: 0)), nil) { _, _ -> [Module] in
            [self.foo]
        }
        let moduleSet = ModuleSet(directInstance: foo)
        XCTAssertEqual(r.evaluate(moduleSet), false)
    }

    func testRuleMatchExtraRight() throws {
        let r = RewriteRuleRNG(Modules.Internode.self, prng: RNGWrapper(PRNG(seed: 0)), nil) { _, _ -> [Module] in
            [self.foo]
        }
        let moduleSet = ModuleSet(leftInstance: nil,
                                  directInstance: Modules.internode,
                                  rightInstance: Foo())
        XCTAssertEqual(r.evaluate(moduleSet), true)
    }

    func testRuleMatchExtraLeft() throws {
        let r = RewriteRuleRNG(Modules.Internode.self, prng: RNGWrapper(PRNG(seed: 0)), nil) { _, _ -> [Module] in
            [self.foo]
        }
        let moduleSet = ModuleSet(leftInstance: Foo(),
                                  directInstance: Modules.internode,
                                  rightInstance: nil)

        XCTAssertEqual(r.evaluate(moduleSet), true)
    }

    func testRuleMatchExtraLeftAndRight() throws {
        let r = RewriteRuleRNG(Modules.Internode.self, prng: RNGWrapper(PRNG(seed: 0)), nil) { _, _ -> [Module] in
            [self.foo]
        }
        let moduleSet = ModuleSet(leftInstance: Foo(),
                                  directInstance: Modules.internode,
                                  rightInstance: Foo())
        XCTAssertEqual(r.evaluate(moduleSet), true)
    }
}

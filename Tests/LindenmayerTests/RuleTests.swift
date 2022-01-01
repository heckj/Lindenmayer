import Lindenmayer
import XCTest

final class RuleTests: XCTestCase {
    struct Foo: Module {
        var name: String = "foo"
    }

    let foo = Foo()

    func testRuleDefaults() throws {
        let r = RewriteRuleRNG(Modules.Internode.self, prng: HasherPRNG(seed: 0)) { ctx, _ -> [Module] in
            XCTAssertNotNil(ctx)

            return [ctx]
        }
        XCTAssertNotNil(r)
        let check = r.evaluate(nil, type(of: foo), nil)
        XCTAssertEqual(check, false)
    }

    func testRuleBasicMatch() throws {
        let r = RewriteRuleRNG(Modules.Internode.self, prng: HasherPRNG(seed: 0)) { _, _ -> [Module] in
            [self.foo]
        }

        XCTAssertEqual(r.evaluate(nil, Modules.Internode.self, nil), true)
    }

    func testRuleBasicFailMatch() throws {
        let r = RewriteRuleRNG(Modules.Internode.self, prng: HasherPRNG(seed: 0)) { _, _ -> [Module] in
            [self.foo]
        }

        XCTAssertEqual(r.evaluate(nil, Foo.self, nil), false)
    }

    func testRuleMatchExtraRight() throws {
        let r = RewriteRuleRNG(Modules.Internode.self, prng: HasherPRNG(seed: 0)) { _, _ -> [Module] in
            [self.foo]
        }

        XCTAssertEqual(r.evaluate(nil, Modules.Internode.self, Foo.self), true)
    }

    func testRuleMatchExtraLeft() throws {
        let r = RewriteRuleRNG(Modules.Internode.self, prng: HasherPRNG(seed: 0)) { _, _ -> [Module] in
            [self.foo]
        }

        XCTAssertEqual(r.evaluate(Foo.self, Modules.Internode.self, nil), true)
    }

    func testRuleMatchExtraLeftAndRight() throws {
        let r = RewriteRuleRNG(Modules.Internode.self, prng: HasherPRNG(seed: 0)) { _, _ -> [Module] in
            [self.foo]
        }

        XCTAssertEqual(r.evaluate(Foo.self, Modules.Internode.self, Foo.self), true)
    }
}

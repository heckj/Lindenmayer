import Lindenmayer
import XCTest

final class RuleTests: XCTestCase {

    struct Foo: Module {
        var name: String = "foo"
    }
    let foo = Foo()

    func testRuleDefaults() throws {
        
        let r = Rule(Modules.Internode.self) { (ctx, p) -> [Module] in
            XCTAssertNotNil(ctx)
            XCTAssertNotNil(p)
            
            return [ctx]
        }
        XCTAssertNotNil(r)
        let check = r.evaluate(nil, type(of: foo), nil)
        XCTAssertEqual(check, false)
    }
    
    func testRuleBasicMatch() throws {
        let r = Rule(Modules.Internode.self) { (ctx, _) -> [Module] in
            return [self.foo]
        }
        
        XCTAssertEqual(r.evaluate(nil, Modules.Internode.self, nil), true)
    }

    func testRuleBasicFailMatch() throws {
        let r = Rule(Modules.Internode.self) { (ctx, _) -> [Module] in
            return [self.foo]
        }
        
        XCTAssertEqual(r.evaluate(nil, Foo.self, nil), false)
    }

    func testRuleMatchExtraRight() throws {
        let r = Rule(Modules.Internode.self) { (ctx, _) -> [Module] in
            return [self.foo]
        }
        
        XCTAssertEqual(r.evaluate(nil, Modules.Internode.self, Foo.self), true)
    }

    func testRuleMatchExtraLeft() throws {
        let r = Rule(Modules.Internode.self) { (ctx, _) -> [Module] in
            return [self.foo]
        }
        
        XCTAssertEqual(r.evaluate(Foo.self, Modules.Internode.self, nil), true)
    }

    func testRuleMatchExtraLeftAndRight() throws {
        let r = Rule(Modules.Internode.self) { (ctx, _) -> [Module] in
            return [self.foo]
        }
        
        XCTAssertEqual(r.evaluate(Foo.self, Modules.Internode.self, Foo.self), true)
    }

}
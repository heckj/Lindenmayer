@testable import Lindenmayer
import XCTest

final class WhiteboxParametricRuleTests: XCTestCase {
    struct ParameterizedExample: Module {
        var name: String = "P"
        var i: Double

        // Create an initializer that accepts any parameters you require.
        init(_ i: Double = 10) {
            self.i = i
        }
    }

    struct ExampleDefines {
        let value: Double = 10.0
    }

    let p = ParameterizedExample()

    func testRuleDefaults() throws {
        let r = RewriteRuleDefinesRNG(ParameterizedExample.self, params: ExampleDefines(), prng: HasherPRNG(seed: 42)) { _, p, _ -> [Module] in
            [ParameterizedExample(p.value + 1.0)]
        }

        XCTAssertNotNil(r)
        XCTAssertNotNil(r.parameters)

        // verify evaluation will trigger with a default P module
        XCTAssertEqual(r.evaluate(nil, ParameterizedExample.self, nil), true)
        // And with a different parameter value
        XCTAssertEqual(r.evaluate(nil, type(of: ParameterizedExample(21)), nil), true)

        let set = ModuleSet(directInstance: ParameterizedExample(10), directInstanceType: ParameterizedExample.self)
        let newModules: [Module] = try r.produce(set)
        XCTAssertEqual(newModules.count, 1)
        let param = newModules[0] as! ParameterizedExample
        // verify that our rule was processed, returning the same module with
        // an increased value from 10.0 -> 11.0.
        XCTAssertEqual(param.i, 11)
    }

    func testRuleDefaultsWithSystemParameters() throws {
        let r = RewriteRuleDefinesRNG(ParameterizedExample.self, params: ExampleDefines(), prng: HasherPRNG(seed: 42)) { ctx, p, _ -> [Module] in
            guard let value = ctx.i else {
                throw RuntimeError<ParameterizedExample>(ctx)
            }
            return [ParameterizedExample(value + p.value)]
        }

        XCTAssertNotNil(r)
        XCTAssertNotNil(r.parameters)

        // verify evaluation will trigger with a default P module
        XCTAssertEqual(r.evaluate(nil, ParameterizedExample.self, nil), true)
        // And with a different parameter value
        XCTAssertEqual(r.evaluate(nil, type(of: ParameterizedExample(21)), nil), true)

        let set = ModuleSet(directInstance: ParameterizedExample(10), directInstanceType: ParameterizedExample.self)
        let newModules: [Module] = try r.produce(set)
        XCTAssertEqual(newModules.count, 1)
        let param = newModules[0] as! ParameterizedExample
        // verify that our rule was processed, returning the same module with
        // an increased value from 10.0 -> 11.0.
        XCTAssertEqual(param.i, 20)
    }
}

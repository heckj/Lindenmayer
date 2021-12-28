import Lindenmayer
import XCTest

final class ParametricRuleTests: XCTestCase {
    struct ParameterizedExample: Module {
        var name: String = "P"
        var i: Double

        // Create an initializer that accepts any parameters you require.
        init(_ i: Double = 10) {
            self.i = i
        }
    }

    let p = ParameterizedExample()

    func testRuleDefaults() throws {
        let r = ParameterizedRule(ParameterizedExample.self) { ctx, _ -> [Module] in
            guard let value = ctx.i else {
                throw Lindenmayer.RuntimeError<ParameterizedExample>(ctx)
            }
            return [ParameterizedExample(value + 1.0)]
        }

        XCTAssertNotNil(r)
        XCTAssertNotNil(r.parameters)

        // verify evaluation will trigger with a default P module
        XCTAssertEqual(r.evaluate(nil, ParameterizedExample.self, nil), true)
        // And with a different parameter value
        XCTAssertEqual(r.evaluate(nil, type(of: ParameterizedExample(21)), nil), true)

        let newModules: [Module] = try r.produce(nil, p, nil, Parameters())
        XCTAssertEqual(newModules.count, 1)
        let param = newModules[0] as! ParameterizedExample
        // verify that our rule was processed, returning the same module with
        // an increased value from 10.0 -> 11.0.
        XCTAssertEqual(param.i, 11)
    }

    func testRuleDefaultsWithSystemParameters() throws {
        let r = ParameterizedRule(ParameterizedExample.self) { ctx, p -> [Module] in
            guard let value = ctx.i else {
                throw Lindenmayer.RuntimeError<ParameterizedExample>(ctx)
            }
            guard let unwrappedP = p.something else {
                throw Lindenmayer.RuntimeError<ParameterizedExample>(ctx)
            }
            return [ParameterizedExample(value + unwrappedP)]
        }

        XCTAssertNotNil(r)
        XCTAssertNotNil(r.parameters)

        // verify evaluation will trigger with a default P module
        XCTAssertEqual(r.evaluate(nil, ParameterizedExample.self, nil), true)
        // And with a different parameter value
        XCTAssertEqual(r.evaluate(nil, type(of: ParameterizedExample(21)), nil), true)

        let newModules: [Module] = try r.produce(nil, p, nil, Parameters(["something": 1.0]))
        XCTAssertEqual(newModules.count, 1)
        let param = newModules[0] as! ParameterizedExample
        // verify that our rule was processed, returning the same module with
        // an increased value from 10.0 -> 11.0.
        XCTAssertEqual(param.i, 11)
    }
}

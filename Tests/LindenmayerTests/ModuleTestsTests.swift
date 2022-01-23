// @testable
import Lindenmayer
import XCTest

final class ModuleTests: XCTestCase {
    func testBuiltins() {
        XCTAssertNotNil(Modules.Draw())
        XCTAssertNotNil(Modules.Move())
        XCTAssertNotNil(Modules.Branch())
        XCTAssertNotNil(Modules.EndBranch())
        XCTAssertNotNil(Modules.TurnLeft())
        XCTAssertNotNil(Modules.TurnRight())
    }

    func testModuleFoo() {
        struct Foo: Module {
            var name: String = "foo"
        }
        let x = Foo()
        // Verify name is passed out as 'description'
        XCTAssertEqual(x.description, "foo")
        // Verify default built-in behavior for a new module
        XCTAssertEqual(x.render2D.count, 0)
        XCTAssertEqual(x.render3D.name, RenderCommand.Ignore().name)
    }

    func testEmptyModuleName() {
        struct EmptyModule: Module {
            var name: String = ""
        }
        let x = EmptyModule()
        // Verify name is passed out as 'description'
        XCTAssertEqual(x.description, "EmptyModule")
    }
}

// @testable
import Lindenmayer
import XCTest

final class ModuleTests: XCTestCase {
    func testBuiltins() {
        XCTAssertNotNil(Modules.internode)
        XCTAssertNotNil(Modules.draw)
        XCTAssertNotNil(Modules.move)
        XCTAssertNotNil(Modules.branch)
        XCTAssertNotNil(Modules.endbranch)
        XCTAssertNotNil(Modules.turnleft)
        XCTAssertNotNil(Modules.turnright)
    }

    func testModuleFoo() {
        struct Foo: Module {
            var name: String = "foo"
        }
        let x = Foo()
        // Verify name is passed out as 'description'
        XCTAssertEqual(x.description, "foo")
        // Verify default built-in behavior for a new module
        XCTAssertEqual(x.render2D, [TwoDRenderCommand.ignore])
        XCTAssertEqual(x.render3D, ThreeDRenderCommand.ignore)
        // Verify subscript lookup returns nil, but doesn't throw
        XCTAssertNil(x[dynamicMember: "something"])
        XCTAssertNil(x.something)
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

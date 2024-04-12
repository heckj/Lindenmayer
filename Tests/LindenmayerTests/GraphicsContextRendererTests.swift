import Lindenmayer
import XCTest

final class GraphicsContextRendererTests: XCTestCase {
    func testLSystem_boundingRectCalc() async throws {
        let tree = Examples2D.kochCurve
        let evo1 = await tree.evolved(iterations: 3)
        let path: CGRect = GraphicsContextRenderer().calcBoundingRect(system: evo1)
        // print(path)
        // print("Size: \(path.size) -> height: \(path.size.height), width: \(path.size.width)")
        XCTAssertTrue(path.size.width >= 130)
        XCTAssertTrue(path.size.height >= 270)
    }
}

import Lindenmayer
import XCTest

final class PerformanceTests: XCTestCase {
    func X_testMemoryUse() async {
//        measure(metrics: [XCTMemoryMetric()]) {
        let tree = Examples2D.barnsleyFern
        let evo1 = await tree.evolved(iterations: 6)
        XCTAssertNotNil(evo1)
//        }
    }

    func X_testEvolutionSpeed() async {
//        measure async {
        // 20.675 seconds
        let tree = Examples2D.barnsleyFern
        let evo1 = await tree.evolved(iterations: 10)
        XCTAssertNotNil(evo1)
//        }
    }

    func X_testPerfBoundingRectCalc() async {
        let evo1: LindenmayerSystem?
        // 20.675 seconds
        let tree = Examples2D.barnsleyFern
        evo1 = await tree.evolved(iterations: 10)
        XCTAssertNotNil(evo1)
        measure {
            // 9.9 seconds
            let path: CGRect = GraphicsContextRenderer().calcBoundingRect(system: evo1!)
            print(path)
        }
    }
}

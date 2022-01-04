import Lindenmayer
import XCTest

final class PerformanceTests: XCTestCase {
    func X_testMemoryUse() {
        measure(metrics: [XCTMemoryMetric()]) {
            let tree = Examples2D.barnsleyFern.lsystem
            let evo1 = tree.evolved(iterations: 6)
            XCTAssertNotNil(evo1)
        }
    }

    func X_testEvolutionSpeed() {
        measure {
            // 20.675 seconds
            let tree = Examples2D.barnsleyFern.lsystem
            let evo1 = tree.evolved(iterations: 10)
            XCTAssertNotNil(evo1)
        }
    }

    func X_testPerfBoundingRectCalc() {
        let evo1: LSystem?
        // 20.675 seconds
        let tree = Examples2D.barnsleyFern.lsystem
        evo1 = tree.evolved(iterations: 10)
        XCTAssertNotNil(evo1)
        measure {
            // 9.9 seconds
            let path: CGRect = GraphicsContextRenderer().calcBoundingRect(system: evo1!)
            print(path)
        }
    }
}

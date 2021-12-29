import Lindenmayer
import XCTest

final class PerformanceTests: XCTestCase {
    func X_testMemoryUse() {
        measure(metrics: [XCTMemoryMetric()]) {
            do {
                let tree = Lindenmayer.Examples2D.barnsleyFern.lsystem
                let evo1 = try tree.evolve(iterations: 6)
                XCTAssertNotNil(evo1)
            } catch {}
        }
    }

    func X_testEvolutionSpeed() {
        measure {
            do {
                // 20.675 seconds
                let tree = Lindenmayer.Examples2D.barnsleyFern.lsystem
                let evo1 = try tree.evolve(iterations: 10)
                XCTAssertNotNil(evo1)
            } catch {}
        }
    }

    func X_testPerfBoundingRectCalc() {
        let evo1: LSystemProtocol?
        do {
            // 20.675 seconds
            let tree = Lindenmayer.Examples2D.barnsleyFern.lsystem
            evo1 = try tree.evolve(iterations: 10)
            XCTAssertNotNil(evo1)
        } catch {
            evo1 = nil
        }
        measure {
            // 9.9 seconds
            let path: CGRect = GraphicsContextRenderer().calcBoundingRect(system: evo1!)
            print(path)
        }
    }
}

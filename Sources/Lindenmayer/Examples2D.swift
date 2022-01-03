//
//  ExampleLSystems.swift
//
//  Created by Joseph Heck on 12/14/21.
//

import Foundation
import Squirrel3

/// A collection of two-dimensional example L-systems.
///
/// The collection examples were inspired by the Wikipedia page [L-system](https://en.wikipedia.org/wiki/L-system).
public enum Examples2D: String, CaseIterable, Identifiable {
    case algae
    case sierpinskiTriangle
    case kochCurve
    case dragonCurve
    case fractalTree
    case barnsleyFern
    public var id: String { rawValue }
    /// The example seed L-system
    public var lsystem: LSystem {
        switch self {
        case .algae:
            return Detailed2DExamples.algae
        case .sierpinskiTriangle:
            return Detailed2DExamples.sierpinskiTriangle
        case .kochCurve:
            return Detailed2DExamples.kochCurve
        case .dragonCurve:
            return Detailed2DExamples.dragonCurve
        case .fractalTree:
            return Detailed2DExamples.fractalTree
        case .barnsleyFern:
            return Detailed2DExamples.barnsleyFern
        }
    }

    /// The L-system evolved by a number of iterations you provide.
    /// - Parameter iterations: The number of times to evolve the L-system.
    /// - Returns: The updated L-system from the number of evolutions you provided.
    public func evolved(iterations: Int) -> LSystem {
        var evolved: LSystem = lsystem
        do {
            evolved = try evolved.evolve(iterations: iterations)
        } catch {}
        return evolved
    }
}

enum Detailed2DExamples {
    // - MARK: Algae example

    struct A: Module {
        public var name = "A"
    }

    static var a = A()
    struct B: Module {
        public var name = "B"
    }

    static var b = B()

    static var algae = Lindenmayer.basic([a])
        .rewrite(A.self) { _ in
            [a, b]
        }
        .rewrite(B.self) { _ in
            [a]
        }

    // - MARK: Fractal tree example

    struct Leaf: Module {
        static let green = ColorRepresentation(r: 0.3, g: 0.56, b: 0.0)
        public var name = "L"
        public var render2D: [TwoDRenderCmd] = [
            RenderCommand.SetLineWidth(width: 3),
            RenderCommand.SetColor(representation: green),
            RenderCommand.Draw(length: 5)
        ]
    }

    static var leaf = Leaf()

    struct Stem: Module {
        public var name = "I"
        public var render2D: [TwoDRenderCmd] = [RenderCommand.Draw(length: 5)] // would be neat to make this green...
    }

    static var stem = Stem()

    static var fractalTree = Lindenmayer.basic(leaf)
        .rewrite(Leaf.self) { _ in
            [stem,
             RenderCommand.branch, RenderCommand.TurnLeft(angle: 45), leaf, RenderCommand.endBranch,
             RenderCommand.TurnRight(angle: 45), leaf]
        }
        .rewrite(Stem.self) { _ in
            [stem, stem]
        }

    // - MARK: Koch curve example

    static var kochCurve = Lindenmayer.basic(RenderCommand.Draw(length: 10))
        .rewrite(RenderCommand.Draw.self) { _ in
            [RenderCommand.draw, RenderCommand.turnLeft,
             RenderCommand.draw, RenderCommand.turnRight,
             RenderCommand.draw, RenderCommand.turnRight,
             RenderCommand.draw, RenderCommand.turnLeft,
             RenderCommand.draw]
        }

    // - MARK: Sierpinski triangle example

    struct F: Module {
        public var name = "F"
        public var render2D: [TwoDRenderCmd] = [RenderCommand.Draw(length: 10)]
    }

    static var f = F()

    struct G: Module {
        public var name = "G"
        public var render2D: [TwoDRenderCmd] = [RenderCommand.Draw(length: 10)]
    }

    static var g = G()

    static var sierpinskiTriangle = Lindenmayer.basic(
        [f, RenderCommand.TurnRight(angle: 120),
         g, RenderCommand.TurnRight(angle: 120),
         g, RenderCommand.TurnRight(angle: 120)]
    )
    .rewrite(F.self) { _ in
        [f, RenderCommand.TurnRight(angle: 120),
         g, RenderCommand.TurnLeft(angle: 120),
         f, RenderCommand.TurnLeft(angle: 120),
         g, RenderCommand.TurnRight(angle: 120),
         f]
    }
    .rewrite(G.self) { _ in
        [g, g]
    }

    // - MARK: dragon curve example

    static var dragonCurve = Lindenmayer.basic(f)
        .rewrite(F.self) { _ in
            [f, RenderCommand.turnLeft, g]
        }
        .rewrite(G.self) { _ in
            [f, RenderCommand.turnRight, g]
        }

    // - MARK: Barnsley fern example

    struct X: Module {
        public var name = "X"
    }

    static var x = X()

    static var barnsleyFern = Lindenmayer.basic(x)
        .rewrite(X.self) { _ in
            [f, RenderCommand.TurnLeft(angle: 25),
             RenderCommand.branch,
                RenderCommand.branch, x, RenderCommand.endBranch,
                RenderCommand.TurnRight(angle: 25), x,
             RenderCommand.endBranch,
             RenderCommand.TurnRight(angle: 25), f,
             RenderCommand.branch, RenderCommand.TurnRight(angle: 25), f, x, RenderCommand.endBranch,
             RenderCommand.TurnLeft(angle: 25), x]
        }
        .rewrite(F.self) { _ in
            [f, f]
        }
}

//
//  Examples2D.swift
//
//  Created by Joseph Heck on 12/14/21.
//

import Foundation

/// A collection of two-dimensional example L-systems.
///
/// The collection examples were inspired by the Wikipedia page [L-system](https://en.wikipedia.org/wiki/L-system).
public enum Examples2D {
    // MARK: - An Example module -

    struct Internode: Module {
        // This is the kind of thing that I want external developers using the library to be able to create to represent elements within their L-system.
        public var name = "I"
        public var render2D: [TwoDRenderCmd] = [RenderCommand.Draw(length: 10)] // draws a line 10 units long
        public init() {}
    }

    // - MARK: Algae example

    struct A: Module {
        public var name = "A"
    }

    static let a = A()
    struct B: Module {
        public var name = "B"
    }

    static let b = B()

    /// An L-system that describes the growth of algae.
    ///
    /// The example is a translation of the [Wikipedia example](https://en.wikipedia.org/wiki/L-system#Example_1:_Algae)
    public static let algae = LSystem.create(A())
        .rewrite(A.self) { _ in
            [A(), B()]
        }
        .rewrite(B.self) { _ in
            [A()]
        }

    // - MARK: Fractal tree example

    struct Leaf: Module {
        static let green = ColorRepresentation(r: 0.3, g: 0.56, b: 0.0)
        public var name = "L"
        public var render2D: [TwoDRenderCmd] = [
            RenderCommand.SetLineWidth(width: 3),
            RenderCommand.SetColor(representation: green),
            RenderCommand.Draw(length: 5),
        ]
    }

    static let leaf = Leaf()

    struct Stem: Module {
        public var name = "I"
        public var render2D: [TwoDRenderCmd] = [RenderCommand.Draw(length: 5)] // would be neat to make this green...
    }

    static let stem = Stem()

    /// An L-system that describes a fractal, or binary, tree.
    ///
    /// ![An image displaying a binary tree.](fractal_tree_6.png)
    /// The example is a translation of the [Wikipedia example](https://en.wikipedia.org/wiki/L-system#Example_2:_Fractal_(binary)_tree), rendered at `6` evolutions.
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples2D.swift).
    public static let fractalTree = LSystem.create(leaf)
        .rewrite(Leaf.self) { leaf in
            [stem,
             Modules.Branch(), Modules.TurnLeft(angle: Angle(degrees: 45)), leaf, Modules.EndBranch(),
             Modules.TurnRight(angle: Angle(degrees: 45)), leaf]
        }
        .rewrite(Stem.self) { stem in
            [stem, stem]
        }

    // - MARK: Koch curve example

    /// An L-system that describes a fractal koch curve.
    ///
    /// ![An image displaying a sierpinski triangle fractcal.](koch_curve_6.png)
    /// The example is a translation of the [Wikipedia example](https://en.wikipedia.org/wiki/L-system#Example_4:_Koch_curve), rendered at `6` evolutions.
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples2D.swift).
    public static let kochCurve = LSystem.create(Modules.Draw(length: 10))
        .rewrite(Modules.Draw.self) { _ in
            [Modules.Draw(length: 10), Modules.TurnLeft(angle: Angle(degrees: 90)),
             Modules.Draw(length: 10), Modules.TurnRight(angle: Angle(degrees: 90)),
             Modules.Draw(length: 10), Modules.TurnRight(angle: Angle(degrees: 90)),
             Modules.Draw(length: 10), Modules.TurnLeft(angle: Angle(degrees: 90)),
             Modules.Draw(length: 10)]
        }

    // - MARK: Sierpinski triangle example

    struct F: Module {
        public var name = "F"
        public var render2D: [TwoDRenderCmd] = [RenderCommand.Draw(length: 10)]
    }

    static let f = F()

    struct G: Module {
        public var name = "G"
        public var render2D: [TwoDRenderCmd] = [RenderCommand.Draw(length: 10)]
    }

    static let g = G()

    /// An L-system that describes a fractal sierpinski triangle.
    ///
    /// ![An image displaying a sierpinski triangle fractcal.](sierpinski_triangle_6.png)
    /// The example is a translation of the [Wikipedia example](https://en.wikipedia.org/wiki/L-system#Example_5:_Sierpinski_triangle), rendered at `6` evolutions.
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples2D.swift).
    public static let sierpinskiTriangle = LSystem.create(
        [f, Modules.TurnRight(angle: Angle(degrees: 120)),
         g, Modules.TurnRight(angle: Angle(degrees: 120)),
         g, Modules.TurnRight(angle: Angle(degrees: 120))]
    )
    .rewrite(F.self) { _ in
        [f, Modules.TurnRight(angle: Angle(degrees: 120)),
         g, Modules.TurnLeft(angle: Angle(degrees: 120)),
         f, Modules.TurnLeft(angle: Angle(degrees: 120)),
         g, Modules.TurnRight(angle: Angle(degrees: 120)),
         f]
    }
    .rewrite(G.self) { _ in
        [g, g]
    }

    // - MARK: dragon curve example

    /// An L-system that describes a fractal dragon curve.
    ///
    /// ![An image displaying a dragon curve fractal.](dragon_curve_9.png)
    /// The example is a translation of the [Wikipedia example](https://en.wikipedia.org/wiki/L-system#Example_6:_Dragon_curve), rendered at `9` evolutions.
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples2D.swift).
    public static let dragonCurve = LSystem.create(f)
        .rewrite(F.self) { _ in
            [f, Modules.TurnLeft(angle: Angle(degrees: 90)), g]
        }
        .rewrite(G.self) { _ in
            [f, Modules.TurnRight(angle: Angle(degrees: 90)), g]
        }

    // - MARK: Barnsley fern example

    struct X: Module {
        public var name = "X"
    }

    static let x = X()

    /// An L-system that describes a fractal plant, also known as the Barnsley Fern.
    ///
    /// ![An image displaying a fractal plant.](barnsley_fern_7.png)
    /// The example above is a translation of the [Wikipedia example](https://en.wikipedia.org/wiki/L-system#Example_7:_Fractal_plant), rendered at `7` evolutions.
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples2D.swift).
    public static let barnsleyFern = LSystem.create(x)
        .rewrite(X.self) { _ in
            [f, Modules.TurnLeft(angle: Angle(degrees: 25)),
             Modules.Branch(),
             Modules.Branch(), x, Modules.EndBranch(),
             Modules.TurnRight(angle: Angle(degrees: 25)), x,
             Modules.EndBranch(),
             Modules.TurnRight(angle: Angle(degrees: 25)), f,
             Modules.Branch(), Modules.TurnRight(angle: Angle(degrees: 25)), f, x, Modules.EndBranch(),
             Modules.TurnLeft(angle: Angle(degrees: 25)), x]
        }
        .rewrite(F.self) { _ in
            [f, f]
        }
}

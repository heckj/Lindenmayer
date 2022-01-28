//
//  Examples3D.swift
//
//
//  Created by Joseph Heck on 1/3/22.
//

import Foundation
import Squirrel3

/// A collection of three-dimensional example L-systems.
///
/// Some of the collection examples were inspired by the [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
/// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
///
/// ## Topics
///
/// ### Algae L-system
///
/// - ``Examples3D/algae3D``
///
/// ### Monopodial Tree L-systems
///
/// - ``Examples3D/monopodialTree``
/// - ``Examples3D/MonopodialDefn``
/// - ``Examples3D/figure2_6A``
/// - ``Examples3D/figure2_6B``
/// - ``Examples3D/figure2_6C``
/// - ``Examples3D/figure2_6D``
///
/// ### Sympodial Tree L-systems
///
/// - ``Examples3D/sympodialTree``
/// - ``Examples3D/SympodialDefn``
/// - ``Examples3D/figure2_7A``
/// - ``Examples3D/figure2_7B``
/// - ``Examples3D/figure2_7C``
/// - ``Examples3D/figure2_7D``
///
public enum Examples3D {
    // - MARK: 3D Algae test

    struct Cyl: Module {
        public var name = "C"
        public var render3D: ThreeDRenderCmd = RenderCommand.Cylinder(
            length: 10,
            radius: 1,
            color: ColorRepresentation(red: 1.0, green: 0.1, blue: 0.1, alpha: 1.0)
        )
    }

    struct S: Module {
        public var name = "S"
        public var render3D: ThreeDRenderCmd = RenderCommand.Cylinder(
            length: 5,
            radius: 2,
            color: ColorRepresentation(red: 0.1, green: 1.0, blue: 0.1, alpha: 1.0)
        )
    }

    /// An example of a L-system that produces a tree with monopodial structure.
    ///
    /// A 3D L-system translated from Wikipedia's Algae example L-system.
    ///
    /// ![A screenshot of a 3D rendering of the algae L-system evolved to display 3 short green segments connected by 2 longer red seegments.](algae_4.png)
    ///
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
    public static var algae3D = LSystem.create(Cyl())
        .rewrite(Cyl.self) { _ in
            [Cyl(), S()]
        }
        .rewrite(S.self) { _ in
            [Cyl()]
        }

    // - MARK: Honda's model for trees

    /*
     Monopodial tree - as described by Honda

     #define r1   0.9   /* Contraction ratio for the trunk */
     #define r2   0.6   /* Contraction ratio for branches */
     #define a0   45    /* Branching angle from the trunk */
     #define a2   45    /* Branching angle for lateral axes */
     #define d    137.5 /* Divergence angle */
     #define wr   0.707 /* Width contraction ratio */

     w: A(1,10) // axiom
     P1: A(s, w) -> !(w) F(s) [ &(a0) B(s * r2, w * wr) ] /(d) A(s * r1, w * wr)
     P2: B(s, w) -> !(w) F(s) [ -(a2) @V C(s * r2, w * wr) ] C(s * r1, w * wr)
     P3: C(s, w) -> !(w) F(s) [ +(a2) @V B(s * r2, w * wr) ] B(s * r1, w * wr)

     Rules of L+C modeling in: http://algorithmicbotany.org/papers/hanan.dis1992.pdf
     - 'PARAMETRIC L-SYSTEMS AND THEIR APPLICATION TO THE MODELLING AND VISUALIZATION
     OF PLANTS'

     pg 34

     & - pitch down by angle ∂
     ^ - pitch up by angle ∂
     \ - roll left by angle ∂
     / - roll right by angle ∂
     | - turn around (∂ = 180°)
     - turn right by angle ∂
     + turn left by angle ∂

     F - move and draw line of current width

     , select next color from the color map by index+
     ; select previous color from the color map by index-
     # increase the line width by line width increment
     ! decrease the line width by line width increment
     " increase the value of the elasticity factor by its increment
     ' decrease the value of the elasticity factor by its increment

     ~ display bicubic surface patch for this element

     pg 41:

     @ - special purpose interpretation
     @C - draw circle with radius equal to current linewidth
     @S - draw sphere with radius equal to current linewidth
     @LF - decrease line length attribute by a constant factor
     @V rotates the turtle around it's heading vector so that the left vector is horizontal and the y component of the up vector is positive
     */

    struct Trunk: Module {
        public var name = "A"

        let growthDistance: Double // start at 1
        let diameter: Double // start at 10
    }

    struct MainBranch: Module {
        public var name = "B"

        let growthDistance: Double
        let diameter: Double
    }

    struct SecondaryBranch: Module {
        public var name = "C"

        let growthDistance: Double
        let diameter: Double
    }

    struct StaticTrunk: Module {
        public var name = "A°"
        public var render3D: ThreeDRenderCmd {
            RenderCommand.Cylinder(
                length: growthDistance,
                radius: diameter / 2,
                color: ColorRepresentation(red: 0.7, green: 0.3, blue: 0.1, alpha: 0.95)
            )
        }

        let growthDistance: Double
        let diameter: Double
    }

    /// A structure that provides parameters for example monopodial trees in [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
    ///
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
    public struct MonopodialDefn: Codable, Equatable {
        var contractionRatioForTrunk: Double = 0.9 /* Contraction ratio for the trunk */
        var contractionRatioForBranch: Double = 0.6 /* Contraction ratio for branches */
        var branchAngle: Double = 45 /* Branching angle from the trunk */
        var lateralBranchAngle: Double = 45 /* Branching angle for lateral axes */
        var divergence: Double = 137.5 /* Divergence angle */
        var widthContraction: Double = 0.707 /* Width contraction ratio */
        var trunklength: Double = 10.0
        var trunkdiameter: Double = 1.0

        init(r1: Double = 0.9,
             r2: Double = 0.6,
             a0: Double = 45,
             a2: Double = 45)
        {
            contractionRatioForTrunk = r1
            contractionRatioForBranch = r2
            branchAngle = a0
            lateralBranchAngle = a2
        }
    }

    static let defines = MonopodialDefn()
    
    /// The parameter definitions for Figure 2.6 A from [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
    ///
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
    public static let figure2_6A = defines
    
    /// The parameter definitions for Figure 2.6 B from [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
    ///
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
    public static let figure2_6B = MonopodialDefn(r1: 0.9, r2: 0.9, a0: 45, a2: 45)
    
    /// The parameter definitions for Figure 2.6 C from [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
    ///
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
    public static let figure2_6C = MonopodialDefn(r1: 0.9, r2: 0.8, a0: 45, a2: 45)
    
    /// The parameter definitions for Figure 2.6 D from [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
    ///
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
    public static let figure2_6D = MonopodialDefn(r1: 0.9, r2: 0.7, a0: 30, a2: -30)

    /// An example of a L-system that produces a tree with monopodial structure.
    ///
    /// A 3D L-system translated from an example in [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
    ///
    /// The L-system and the definitions match Fig 2.6 from the book, along with the parameter defintions for each of the 4 figures defined here:
    /// - ``Examples3D/figure2_6A``
    /// - ``Examples3D/figure2_6B``
    /// - ``Examples3D/figure2_6C``
    /// - ``Examples3D/figure2_6D``
    ///
    /// ![A screenshot showing four rendered trees that correspond to the parameters as described in The Algorithmic Beauty of Plants for figure 2.6](rendered_2_6_trees.png)
    ///
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
    public static var monopodialTree = LSystem.create(
        [Trunk(growthDistance: defines.trunklength, diameter: defines.trunkdiameter)],
        with: PRNG(seed: 42),
        using: defines
    )
    .rewriteWithParams(directContext: Trunk.self) { trunk, params in

        // original: !(w) F(s) [ &(a0) B(s * r2, w * wr) ] /(d) A(s * r1, w * wr)
        // Conversion:
        // s -> trunk.growthDistance, w -> trunk.diameter
        // !(w) F(s) => reduce width of pen, then draw the line forward a distance of 's'
        //   this is covered by returning a StaticTrunk that doesn't continue to evolve
        // [ &(a0) B(s * r2, w * wr) ] /(d)
        //   => branch, pitch down by a0 degrees, then grow a B branch (s = s * r2, w = w * wr)
        //      then end the branch, and yaw around by d°
        [
            StaticTrunk(growthDistance: trunk.growthDistance, diameter: trunk.diameter),
            Modules.Branch(),
            Modules.PitchDown(angle: Angle(degrees: params.branchAngle)),
            MainBranch(growthDistance: trunk.growthDistance * params.contractionRatioForBranch,
                       diameter: trunk.diameter * params.widthContraction),
            Modules.EndBranch(),
            Modules.RollLeft(angle: Angle(degrees: params.divergence)),
            Trunk(growthDistance: trunk.growthDistance * params.contractionRatioForTrunk,
                  diameter: trunk.diameter * params.widthContraction),
        ]
    }
    .rewriteWithParams(directContext: MainBranch.self) { branch, params in
        // Original P2: B(s, w) -> !(w) F(s) [ -(a2) @V C(s * r2, w * wr) ] C(s * r1, w * wr)
        // !(w) F(s) - Static Main Branch
        [
            StaticTrunk(growthDistance: branch.growthDistance, diameter: branch.diameter),
            Modules.Branch(),

            Modules.TurnLeft(angle: Angle(degrees: params.lateralBranchAngle)),
            Modules.RollUpToVertical(),
            SecondaryBranch(growthDistance: branch.growthDistance * params.contractionRatioForBranch,
                            diameter: branch.diameter * params.widthContraction),

            Modules.EndBranch(),

            SecondaryBranch(growthDistance: branch.growthDistance * params.contractionRatioForTrunk,
                            diameter: branch.diameter * params.widthContraction),
        ]
    }
    .rewriteWithParams(directContext: SecondaryBranch.self) { branch, params in
        // Original: P3: C(s, w) -> !(w) F(s) [ +(a2) @V B(s * r2, w * wr) ] B(s * r1, w * wr)
        [
            StaticTrunk(growthDistance: branch.growthDistance, diameter: branch.diameter),
            Modules.Branch(),

            Modules.TurnRight(angle: Angle(degrees: params.branchAngle)),
            Modules.RollUpToVertical(),

            MainBranch(growthDistance: branch.growthDistance * params.contractionRatioForBranch,
                       diameter: branch.diameter * params.widthContraction),

            Modules.EndBranch(),
            MainBranch(growthDistance: branch.growthDistance * params.contractionRatioForTrunk,
                       diameter: branch.diameter * params.widthContraction),
        ]
    }

    // - MARK: Sympodial Trees

    // Sympodial tree - as described by Aono and Kunii
    // ABOP - page 58, 59
    //    n = 10
    //    #define r1 0.9 /* contraction ratio 1 */
    //    #define r2 0.7 /* contraction ratio 2 */
    //    #define a1 10 /* branching angle 1 */
    //    #define a2 60 /* branching angle 2 */
    //    #define wr 0.707 /* width decrease rate */
    //    ω : A(1,10)
    //    p1 : A(l,w) : * → !(w)F(l)[&(a1)B(l*r1,w*wr)] /(180)[&(a2 )B(l*r2 ,w*wr )]
    //    p2 : B(l,w) : * → !(w)F(l)[+(a1)$B(l*r1,w*wr)] [-(a2 )$B(l*r2 ,w*wr )]

    /// A structure that provides parameters for example sympodial trees in [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
    ///
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
    public struct SympodialDefn: Codable, Equatable {
        var r1: Double
        var r2: Double
        var a1: Double
        var a2: Double
        var wr: Double = 0.707 /* Width contraction ratio */

        init(r1: Double = 0.9,
             r2: Double = 0.7,
             a1: Double = 10,
             a2: Double = 60)
        {
            self.r1 = r1
            self.r2 = r2
            self.a1 = a1
            self.a2 = a2
        }
    }

    /// The parameter definitions for Figure 2.7 A from [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
    ///
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
    public static let figure2_7A = SympodialDefn(r1: 0.9, r2: 0.7, a1: 5, a2: 65)
    
    /// The parameter definitions for Figure 2.7 B from [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
    ///
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
    public static let figure2_7B = SympodialDefn(r1: 0.9, r2: 0.7, a1: 10, a2: 60)
    
    /// The parameter definitions for Figure 2.7 C from [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
    ///
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
    public static let figure2_7C = SympodialDefn(r1: 0.9, r2: 0.8, a1: 20, a2: 50)
    
    /// The parameter definitions for Figure 2.7 D from [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
    ///
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
    public static let figure2_7D = SympodialDefn(r1: 0.9, r2: 0.8, a1: 35, a2: 35)

    /// An example of a L-system that produces a tree with sympodial structure.
    ///
    /// A 3D L-system translated from an example in [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
    /// The L-system and the definitions match Fig 2.6 from the book, along with the parameter defintions for each of the 4 figures defined here:
    /// - ``Examples3D/figure2_7A``
    /// - ``Examples3D/figure2_7B``
    /// - ``Examples3D/figure2_7C``
    /// - ``Examples3D/figure2_7D``
    ///
    /// ![A screenshot showing four rendered trees that correspond to the parameters as described in The Algorithmic Beauty of Plants for figure 2.7](rendered_2_7_trees.png)
    ///
    /// The example source for this L-system is [available on GitHub](https://github.com/heckj/Lindenmayer/blob/main/Sources/Lindenmayer/Examples3D.swift).
    public static let sympodialTree = LSystem.create(
        MainBranch(growthDistance: 10, diameter: 1),
        with: PRNG(seed: 0),
        using: figure2_7A
    ).rewriteWithParams(directContext: MainBranch.self) { node, params in
        //    p1 : A(l,w) : * → !(w)F(l)[&(a1)B(l*r1,w*wr)] /(180)[&(a2 )B(l*r2 ,w*wr )]
        [
            StaticTrunk(growthDistance: node.growthDistance, diameter: node.diameter),

            Modules.Branch(),
            Modules.PitchDown(angle: Angle(degrees: params.a1)),
            SecondaryBranch(growthDistance: node.growthDistance * params.r1, diameter: node.diameter * params.wr),
            Modules.EndBranch(),

            Modules.RollLeft(angle: Angle(degrees: 180)),

            Modules.Branch(),
            Modules.PitchDown(angle: Angle(degrees: params.a2)),
            SecondaryBranch(growthDistance: node.growthDistance * params.r2, diameter: node.diameter * params.wr),
            Modules.EndBranch(),
        ]
    }
    .rewriteWithParams(directContext: SecondaryBranch.self) { node, params in
        //    p2 : B(l,w) : * → !(w)F(l)[+(a1)$B(l*r1,w*wr)] [-(a2 )$B(l*r2 ,w*wr )]
        [
            StaticTrunk(growthDistance: node.growthDistance, diameter: node.diameter),
            Modules.Branch(),
            Modules.TurnRight(angle: Angle(degrees: params.a1)),
            Modules.RollUpToVertical(),
            SecondaryBranch(growthDistance: node.growthDistance * params.r1, diameter: node.diameter * params.wr),
            Modules.EndBranch(),
            Modules.Branch(),
            Modules.TurnLeft(angle: Angle(degrees: params.a2)),
            Modules.RollUpToVertical(),
            SecondaryBranch(growthDistance: node.growthDistance * params.r2, diameter: node.diameter * params.wr),
            Modules.EndBranch(),
        ]
    }

    // - MARK: Random Bush

    struct Stem2: Module {
        public var name = "i"
        let length: Double // start at 10
        public var render3D: ThreeDRenderCmd {
            RenderCommand.Cylinder(
                length: length,
                radius: length / 10,
                color: ColorRepresentation(red: 0.5, green: 0.7, blue: 0.1, alpha: 0.9)
            )
        }
    }

    struct StaticStem2: Module {
        public var name = "I"
        let length: Double // start at 10
        public var render3D: ThreeDRenderCmd {
            RenderCommand.Cylinder(
                length: length,
                radius: length / 10,
                color: ColorRepresentation(red: 0.7, green: 0.7, blue: 0.1, alpha: 0.95)
            )
        }
    }

    public static var randomBush = LSystem.create(Stem2(length: 1), with: PRNG(seed: 42))
        .rewriteWithRNG(directContext: Stem2.self) { stem, rng -> [Module] in

            let upper: Float = 45.0
            let lower: Float = 15.0

            if rng.p(0.5) {
                return [
                    StaticStem2(length: 2),
                    Modules.PitchDown(angle: Angle(degrees: Double(rng.randomFloat(in: lower ... upper)))),
                    Stem2(length: stem.length),
                ]
            } else {
                return [
                    StaticStem2(length: 2),
                    Modules.PitchUp(angle: Angle(degrees: Double(rng.randomFloat(in: lower ... upper)))),
                    Stem2(length: stem.length),
                ]
            }
        }

    static var experiment2 = LSystem.create(Stem2(length: 1))
        .rewrite(Stem2.self, where: { stem in
            stem.length < 5
        }, produces: { stem in
            [Stem2(length: stem.length + 1)]
        })
}

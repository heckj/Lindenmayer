//
//  Examples3D.swift
//  
//
//  Created by Joseph Heck on 1/3/22.
//

import Foundation
import Squirrel3

/// A collection of three-dimensional example L-systems.
public enum Examples3D: String, CaseIterable, Identifiable {
    /// A tree branching L-system based on L-system 6 in the model provided in Algorithmic Beauty of Plants.
    case hondaTreeBranchingModel
    case algae3D
    case randomBush
    public var id: String { rawValue }
    /// The example seed L-system
    public var lsystem: LSystem {
        switch self {
        case .hondaTreeBranchingModel:
            return Detailed3DExamples.hondaTree
        case .algae3D:
            return Detailed3DExamples.algae3D
        case .randomBush:
            return Detailed3DExamples.randomBush
        }
    }
}

enum Detailed3DExamples {
    
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

    static var algae3D = Lindenmayer.basic(Cyl())
        .rewrite(Cyl.self) { _ in
            [Cyl(), S()]
        }
        .rewrite(S.self) { _ in
            [Cyl()]
        }

    // - MARK: Honda's model for trees

    /*
     Honda's model for trees
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
        public var render3D: ThreeDRenderCmd {
            RenderCommand.Cylinder(
                length: growthDistance,
                radius: diameter / 2,
                color: ColorRepresentation(red: 0.7, green: 0.7, blue: 0.1, alpha: 0.9)
            )
        }

        let growthDistance: Double // start at 1
        let diameter: Double // start at 10
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

        let growthDistance: Double // start at 1
        let diameter: Double // start at 10
    }

    struct MainBranch: Module {
        public var name = "B"
        public var render3D: ThreeDRenderCmd {
            RenderCommand.Cylinder(
                length: growthDistance,
                radius: diameter / 2,
                color: ColorRepresentation(red: 0.3, green: 0.9, blue: 0.1, alpha: 0.9)
            )
        }

        let growthDistance: Double
        let diameter: Double
    }

    struct StaticBranch: Module {
        public var name = "o"
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

    struct SecondaryBranch: Module {
        public var name = "C"
        public var render3D: ThreeDRenderCmd {
            RenderCommand.Cylinder(
                length: growthDistance,
                radius: diameter / 2,
                color:ColorRepresentation(red: 0.3, green: 0.1, blue: 0.9, alpha: 0.9)
            )
        }

        let growthDistance: Double
        let diameter: Double
    }

    struct Definitions {
        var contractionRatioForTrunk: Double = 0.9 /* Contraction ratio for the trunk */
        var contractionRatioForBranch: Double = 0.6 /* Contraction ratio for branches */
        var branchAngle: Double = 45 /* Branching angle from the trunk */
        var lateralBranchAngle: Double = 45 /* Branching angle for lateral axes */
        var divergence: Double = 137.5 /* Divergence angle */
        var widthContraction: Double = 0.707 /* Width contraction ratio */
        var trunklength: Double = 10.0
        var trunkdiameter: Double = 2.0
        
        init(r1: Double = 0.9,
                 r2: Double = 0.6,
                 a0: Double = 45,
                 a2: Double = 45) {
            contractionRatioForTrunk = r1
            contractionRatioForBranch = r2
            branchAngle = a0
            lateralBranchAngle = a2
        }
    }

    static let defines = Definitions()
    static let figure2_6A = defines
    static let figure2_6B = Definitions(r1: 0.9, r2: 0.9, a0: 45, a2: 45)
    static let figure2_6C = Definitions(r1: 0.9, r2: 0.8, a0: 45, a2: 45)
    static let figure2_6D = Definitions(r1: 0.9, r2: 0.7, a0: 30, a2: -30)

    static let figure2_7A = Definitions(r1: 0.9, r2: 0.7, a0: 5, a2: 65)
    static let figure2_7B = Definitions(r1: 0.9, r2: 0.7, a0: 10, a2: 60)
    static let figure2_7C = Definitions(r1: 0.9, r2: 0.8, a0: 20, a2: 50)
    static let figure2_7D = Definitions(r1: 0.9, r2: 0.8, a0: 35, a2: 35)

    static var hondaTree = Lindenmayer.withDefines(
        [Trunk(growthDistance: defines.trunklength, diameter: defines.trunkdiameter)],
        prng: PRNG(seed: 42),
        parameters: defines
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
            Modules.PitchDown(angle: params.branchAngle),
            MainBranch(growthDistance: trunk.growthDistance,
                       diameter: trunk.diameter * params.widthContraction),
            Modules.EndBranch(),
            Modules.TurnLeft(angle: params.divergence),
            Trunk(growthDistance: trunk.growthDistance * params.contractionRatioForTrunk,
                  diameter: trunk.diameter * params.widthContraction),
        ]
    }
    .rewriteWithParams(directContext: MainBranch.self) { branch, params in
        // Original P2: B(s, w) -> !(w) F(s) [ -(a2) @V C(s * r2, w * wr) ] C(s * r1, w * wr)
        // !(w) F(s) - Static Main Branch
        [
            StaticBranch(growthDistance: branch.growthDistance, diameter: branch.diameter),
            Modules.Branch(),

            Modules.RollLeft(angle: params.lateralBranchAngle),
            Modules.LevelOut(),
            SecondaryBranch(growthDistance: branch.growthDistance * params.contractionRatioForBranch,
                            diameter: branch.diameter * params.widthContraction),

            Modules.EndBranch(),

            SecondaryBranch(growthDistance: branch.growthDistance * params.contractionRatioForBranch,
                            diameter: branch.diameter * params.widthContraction),
        ]
    }
    .rewriteWithParams(directContext: SecondaryBranch.self) { branch, params in
        // Original: P3: C(s, w) -> !(w) F(s) [ +(a2) @V B(s * r2, w * wr) ] B(s * r1, w * wr)
        [
            StaticBranch(growthDistance: branch.growthDistance, diameter: branch.diameter),
            Modules.Branch(),

            Modules.RollRight(angle: params.branchAngle),
            Modules.LevelOut(),

            MainBranch(growthDistance: branch.growthDistance * params.contractionRatioForBranch,
                       diameter: branch.diameter * params.widthContraction),

            Modules.EndBranch(),
            MainBranch(growthDistance: branch.growthDistance * params.contractionRatioForBranch,
                                    diameter: branch.diameter * params.widthContraction)
        ]
    }

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

    struct BushDefinitions {}

    static var randomBush = Lindenmayer.withRNG(Stem2(length: 1), prng: PRNG(seed: 42))
        .rewriteWithRNG(directContext: Stem2.self) { stem, rng -> [Module] in

            let upper: Float = 45.0
            let lower: Float = 15.0

            if rng.p(0.5) {
                return [
                    StaticStem2(length: 2),
                    Modules.PitchDown(angle: Double(rng.randomFloat(in: lower ... upper))),
                    Stem2(length: stem.length)
                ]
            } else {
                return [
                    StaticStem2(length: 2),
                    Modules.PitchUp(angle: Double(rng.randomFloat(in: lower ... upper))),
                    Stem2(length: stem.length)
                ]
            }
        }

    static var experiment2 = Lindenmayer.basic(Stem2(length: 1))
        .rewrite(Stem2.self, where: { stem in
            stem.length < 5
        }, produces: { stem in
            [Stem2(length: stem.length + 1)]
        })
}

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
            return DetailedExamples.algae
        case .sierpinskiTriangle:
            return DetailedExamples.sierpinskiTriangle
        case .kochCurve:
            return DetailedExamples.kochCurve
        case .dragonCurve:
            return DetailedExamples.dragonCurve
        case .fractalTree:
            return DetailedExamples.fractalTree
        case .barnsleyFern:
            return DetailedExamples.barnsleyFern
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
            return DetailedExamples.hondaTree
        case .algae3D:
            return DetailedExamples.algae3D
        case .randomBush:
            return DetailedExamples.randomBush
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

enum DetailedExamples {
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
        public var render2D: [TwoDRenderCommand] = [
            .setLineWidth(3),
            .setLineColor(green),
            .draw(5),
        ]
    }

    static var leaf = Leaf()

    struct Stem: Module {
        public var name = "I"
        public var render2D: [TwoDRenderCommand] = [.draw(10)] // would be neat to make this green...
    }

    static var stem = Stem()

    static var fractalTree = Lindenmayer.basic(leaf)
        .rewrite(Leaf.self) { _ in
            [stem, Modules.branch, Modules.TurnLeft(45), leaf, Modules.endbranch, Modules.TurnRight(45), leaf]
        }
        .rewrite(Stem.self) { _ in
            [stem, stem]
        }

    /* Two notes from this latest update:
     first - the need to specify the type of generic isn't great. I'd love to hide that away entirely, but still keep the capability of
     specifying an alternate generic RNG to use internally. I might be able to leave the type system in place, but "hide" it by
     creating a static func on the protocol itself, which returns the relevant type without having the specify all the gory details.

     second - the types passed through to the closure - I'm not using the stochastics all the time, so I'm wondering if it would make
     more sense to have yet another generic type of LSystem and Rule - one that didn't have stochastics at all. Then the others might
     build on that, adding generics (and generating them with static func's on the protocol for convenience). So something like:

     BasicLSystem
     StochasticLSystem <-- adds the default HasherPRNG generic to the rules
     StochasticDefinesLSystem <-- adds the HasherPRNG and the definition object to the rules

     I'd need the corresponding rules to match:

     BasicRule
     StochasticRule
     StochasticDefinesRules
     */

    // - MARK: Koch curve example

    static var kochCurve = Lindenmayer.basic(Modules.Draw(10))
        .rewrite(Modules.Draw.self) { _ in
            [Modules.Draw(10), Modules.TurnLeft(), Modules.Draw(10), Modules.TurnRight(), Modules.Draw(10), Modules.TurnRight(), Modules.Draw(10), Modules.TurnLeft(), Modules.Draw(10)]
        }

    // - MARK: Sierpinski triangle example

    struct F: Module {
        public var name = "F"
        public var render2D: [TwoDRenderCommand] = [.draw(10.0)]
    }

    static var f = F()

    struct G: Module {
        public var name = "G"
        public var render2D: [TwoDRenderCommand] = [.draw(10.0)]
    }

    static var g = G()

    static var sierpinskiTriangle = Lindenmayer.basic(
        [f, Modules.TurnRight(120), g, Modules.TurnRight(120), g, Modules.TurnRight(120)]
    )
    .rewrite(F.self) { _ in
        [f, Modules.TurnRight(120), g, Modules.TurnLeft(120), f, Modules.TurnLeft(120), g, Modules.TurnRight(120), f]
    }
    .rewrite(G.self) { _ in
        [g, g]
    }

    // - MARK: dragon curve example

    static var dragonCurve = Lindenmayer.basic(f)
        .rewrite(F.self) { _ in
            [f, Modules.TurnLeft(90), g]
        }
        .rewrite(G.self) { _ in
            [f, Modules.TurnRight(90), g]
        }

    // - MARK: Barnsley fern example

    struct X: Module {
        public var name = "X"
        public var render2D: [TwoDRenderCommand] = [.ignore]
    }

    static var x = X()

    static var barnsleyFern = Lindenmayer.basic(x)
        .rewrite(X.self) { _ in
            [f, Modules.TurnLeft(25), Modules.branch, Modules.branch, x, Modules.endbranch, Modules.TurnRight(25), x, Modules.endbranch, Modules.TurnRight(25), f, Modules.branch, Modules.TurnRight(25), f, x, Modules.endbranch, Modules.TurnLeft(25), x]
        }
        .rewrite(F.self) { _ in
            [f, f]
        }

    // - MARK: Super simple test tree

    struct Cyl: Module {
        public var name = "C"
        public var render3D: ThreeDRenderCommand = ThreeDRenderCommand.cylinder(10, 1, ColorRepresentation(red: 1.0, green: 0.1, blue: 0.1, alpha: 1.0)) // length, radius
    }

    struct S: Module {
        public var name = "S"
        public var render3D: ThreeDRenderCommand = ThreeDRenderCommand.cylinder(5, 2, ColorRepresentation(red: 0.1, green: 1.0, blue: 0.1, alpha: 1.0))
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
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.cylinder( // length, radius
                growthDistance,
                diameter / 2,
                ColorRepresentation(red: 0.7, green: 0.7, blue: 0.1, alpha: 0.9)
            )
        }

        let growthDistance: Double // start at 1
        let diameter: Double // start at 10
    }

    struct StaticTrunk: Module {
        public var name = "A°"
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.cylinder( // length, radius
                growthDistance,
                diameter / 2,
                ColorRepresentation(red: 0.7, green: 0.3, blue: 0.1, alpha: 0.95)
            )
        }

        let growthDistance: Double // start at 1
        let diameter: Double // start at 10
    }

    struct MainBranch: Module {
        public var name = "B"
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.cylinder(growthDistance, diameter / 2,
                                         ColorRepresentation(red: 0.3, green: 0.9, blue: 0.1, alpha: 0.9)) // length, radius
        }

        let growthDistance: Double
        let diameter: Double
    }

    struct StaticBranch: Module {
        public var name = "o"
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.cylinder(growthDistance, diameter / 2,
                                         ColorRepresentation(red: 0.7, green: 0.3, blue: 0.1, alpha: 0.95)) // length, radius
        }

        let growthDistance: Double
        let diameter: Double
    }

    struct SecondaryBranch: Module {
        public var name = "C"
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.cylinder(growthDistance, diameter / 2,
                                         ColorRepresentation(red: 0.3, green: 0.1, blue: 0.9, alpha: 0.9)) // length, radius
        }

        let growthDistance: Double
        let diameter: Double
    }

    struct Definitions {
        let contractionRatioForTrunk: Double = 0.9 /* Contraction ratio for the trunk */
        let contractionRatioForBranch: Double = 0.6 /* Contraction ratio for branches */
        let branchAngle: Double = 45 /* Branching angle from the trunk */
        let lateralBranchAngle: Double = 45 /* Branching angle for lateral axes */
        let divergence: Double = 137.5 /* Divergence angle */
        let widthContraction: Double = 0.707 /* Width contraction ratio */
        let trunklength: Double = 10.0
        let trunkdiameter: Double = 2.0
    }

    static let defines = Definitions()

    static var hondaTree = Lindenmayer.withDefines(
        [Trunk(growthDistance: defines.trunklength, diameter: defines.trunkdiameter)],
        prng: PRNG(seed: 42),
        parameters: defines
    )
    .rewriteWithAll(directContext: Trunk.self) { trunk, params, _ in

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
            Modules.branch,
            Modules.PitchDown(params.branchAngle),
            MainBranch(growthDistance: trunk.growthDistance,
                       diameter: trunk.diameter * params.widthContraction),
            Modules.endbranch,
            Modules.TurnLeft(params.divergence),
            Trunk(growthDistance: trunk.growthDistance * params.contractionRatioForTrunk,
                  diameter: trunk.diameter * params.widthContraction),
        ]
    }
    .rewriteWithAll(directContext: MainBranch.self) { branch, params, _ in

        // Original P2: B(s, w) -> !(w) F(s) [ -(a2) @V C(s * r2, w * wr) ] C(s * r1, w * wr)
        // !(w) F(s) - Static Main Branch

        [
            StaticBranch(growthDistance: branch.growthDistance, diameter: branch.diameter),
            Modules.branch,

            Modules.RollLeft(params.lateralBranchAngle),
            Modules.LevelOut(),
            SecondaryBranch(growthDistance: branch.growthDistance * params.contractionRatioForBranch,
                            diameter: branch.diameter * params.widthContraction),

            Modules.endbranch,

            SecondaryBranch(growthDistance: branch.growthDistance * params.contractionRatioForBranch,
                            diameter: branch.diameter * params.widthContraction),
        ]
    }
    .rewriteWithAll(directContext: SecondaryBranch.self) { branch, params, _ in

        // Original: P3: C(s, w) -> !(w) F(s) [ +(a2) @V B(s * r2, w * wr) ] B(s * r1, w * wr)

        [
            StaticBranch(growthDistance: branch.growthDistance, diameter: branch.diameter),
            Modules.branch,

            Modules.RollRight(params.branchAngle),
            Modules.LevelOut(),

            MainBranch(growthDistance: branch.growthDistance * params.contractionRatioForBranch,
                       diameter: branch.diameter * params.widthContraction),

            Modules.endbranch,

            MainBranch(growthDistance: branch.growthDistance * params.contractionRatioForBranch,
                       diameter: branch.diameter * params.widthContraction),
        ]
    }

    // - MARK: Random Bush

    struct Stem2: Module {
        public var name = "i"
        let length: Double // start at 10
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.cylinder( // length, radius
                length,
                length / 10,
                ColorRepresentation(red: 0.5, green: 0.7, blue: 0.1, alpha: 0.9)
            )
        }
    }

    struct StaticStem2: Module {
        public var name = "I"
        let length: Double // start at 10
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.cylinder( // length, radius
                length,
                length / 10,
                ColorRepresentation(red: 0.7, green: 0.7, blue: 0.1, alpha: 0.95)
            )
        }
    }

    struct BushDefinitions {}

    static var randomBush = Lindenmayer.withRNG(Stem2(length: 1), prng: PRNG(seed: 42))
        .rewriteWithRNG(directContext: Stem2.self) { stem, rng -> [Module] in

            let upper: Float = 45.0
            let lower: Float = 15.0

            if rng.p(0.5) {
                return [StaticStem2(length: 2), Modules.PitchDown(Double(rng.randomFloat(in: lower ... upper))), Stem2(length: stem.length)]
            } else {
                return [StaticStem2(length: 2), Modules.PitchUp(Double(rng.randomFloat(in: lower ... upper))), Stem2(length: stem.length)]
            }
        }

    static var experiment2 = Lindenmayer.basic(Stem2(length: 1))
        .rewrite(Stem2.self, where: { stem in
            stem.length < 5
        }, produces: { stem in
            [Stem2(length: stem.length + 1)]
        })
}

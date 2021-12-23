//
//  ExampleLSystems.swift
//
//  Created by Joseph Heck on 12/14/21.
//

import Foundation

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
    public var id: String { self.rawValue }
    /// The example seed L-system
    public var lsystem: LSystem {
        get {
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
    }
    /// The L-system evolved by a number of iterations you provide.
    /// - Parameter iterations: The number of times to evolve the L-system.
    /// - Returns: The updated L-system from the number of evolutions you provided.
    public func evolved(iterations: Int) -> LSystem {
        var evolved: LSystem = self.lsystem
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
    public var id: String { self.rawValue }
    /// The example seed L-system
    public var lsystem: LSystem {
        get {
            switch self {
            case .hondaTreeBranchingModel:
                return DetailedExamples.hondaTree
            case .algae3D:
                return DetailedExamples.algae3D
            }
        }
    }
    /// The L-system evolved by a number of iterations you provide.
    /// - Parameter iterations: The number of times to evolve the L-system.
    /// - Returns: The updated L-system from the number of evolutions you provided.
    public func evolved(iterations: Int) -> LSystem {
        var evolved: LSystem = self.lsystem
        do {
            evolved = try evolved.evolve(iterations: iterations)
        } catch {}
        return evolved
    }
}

struct DetailedExamples {
    
    // - MARK: Algae example
    
    struct A: Module {
        public var name = "A"
    }
    static var a = A()
    struct B: Module {
        public var name = "B"
    }
    static var b = B()
    
    static var algae = LSystem(a, rules: [
        Rule(A.self, { _, _ in
            [a,b]
        }),
        Rule(B.self, { _, _ in
            [a]
        })
    ])
    
    // - MARK: Fractal tree example
    
    struct Leaf: Module {
        static let green = ColorRepresentation(r: 0.3, g: 0.56, b: 0.0)
        public var name = "L"
        public var render2D: [TwoDRenderCommand] = [
            .setLineWidth(3),
            .setLineColor(green),
            .draw(5)
        ]
    }
    static var leaf = Leaf()
    
    struct Stem: Module {
        public var name = "I"
        public var render2D: [TwoDRenderCommand] = [.draw(10)] // would be neat to make this green...
    }
    static var stem = Stem()
    
    static var fractalTree = LSystem(leaf, rules: [
        Rule(Leaf.self, { _, _ in
            [stem, Modules.branch, Modules.TurnLeft(45), leaf, Modules.endbranch, Modules.TurnRight(45), leaf]
        }),
        Rule(Stem.self, { _, _ in
            [stem, stem]
        })
    ])
    
    // - MARK: Koch curve example
    
    static var kochCurve = LSystem(Modules.Draw(10), rules: [
        Rule(Modules.Draw.self, { _, _ in
            [Modules.Draw(10), Modules.TurnLeft(), Modules.Draw(10), Modules.TurnRight(), Modules.Draw(10), Modules.TurnRight(), Modules.Draw(10), Modules.TurnLeft(), Modules.Draw(10)]
        })
    ])
    
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
    
    static var sierpinskiTriangle = LSystem(
        [f,Modules.TurnRight(120),g,Modules.TurnRight(120),g,Modules.TurnRight(120)],
        rules: [
            Rule(F.self, { _, _ in
                [f,Modules.TurnRight(120),g,Modules.TurnLeft(120),f,Modules.TurnLeft(120),g,Modules.TurnRight(120),f]
            }),
            Rule(G.self, { _, _ in
                [g,g]
            })
        ]
    )
    
    // - MARK: dragon curve example
    
    static var dragonCurve = LSystem(f,
                                     rules: [
                                        Rule(F.self, { _, _ in
                                            [f,Modules.TurnLeft(90),g]
                                        }),
                                        Rule(G.self, { _, _ in
                                            [f,Modules.TurnRight(90),g]
                                        })
                                     ]
    )
    
    // - MARK: Barnsley fern example
    
    struct X: Module {
        public var name = "X"
        public var render2D: [TwoDRenderCommand] = [.ignore]
    }
    static var x = X()
    
    static var barnsleyFern = LSystem(x,
                                      rules: [
                                        Rule(X.self, { _, _ in
                                            [f,Modules.TurnLeft(25),Modules.branch,Modules.branch,x,Modules.endbranch,Modules.TurnRight(25),x,Modules.endbranch,Modules.TurnRight(25),f,Modules.branch,Modules.TurnRight(25),f,x,Modules.endbranch,Modules.TurnLeft(25),x]
                                        }),
                                        Rule(F.self, { _, _ in
                                            [f,f]
                                        })
                                      ]
    )
    
    // - MARK: Super simple test tree
    
    struct Cyl: Module {
        public var name = "C"
        public var render3D: ThreeDRenderCommand = ThreeDRenderCommand.cylinder(10, 1, ColorRepresentation(red: 1.0, green: 0.1, blue: 0.1, alpha: 1.0)) // length, radius
    }
    struct S: Module {
        public var name = "S"
        public var render3D: ThreeDRenderCommand = ThreeDRenderCommand.cylinder(5, 2, ColorRepresentation(red: 0.1, green: 1.0, blue: 0.1, alpha: 1.0))
    }
    static var algae3D = LSystem(Cyl(), rules: [
        Rule(Cyl.self, { _, _ in
            [Cyl(),S()]
        }),
        Rule(S.self, { _, _ in
            [Cyl()]
        })
    ])
    
    
    // - MARK: Honda's model for trees
    
    struct Trunk: Module {
        public var name = "A"
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.cylinder( // length, radius
                self.growthDistance,
                self.diameter/2,
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
                self.growthDistance,
                self.diameter/2,
                ColorRepresentation(red: 0.7, green: 0.3, blue: 0.1, alpha: 0.95)
            )
        }
        let growthDistance: Double // start at 1
        let diameter: Double // start at 10
    }

    struct MainBranch: Module {
        public var name = "B"
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.cylinder(self.growthDistance, self.diameter/2,
                                         ColorRepresentation(red: 0.3, green: 0.9, blue: 0.1, alpha: 0.9)) // length, radius
        }
        let growthDistance: Double
        let diameter: Double
    }
    
    struct StaticBranch: Module {
        public var name = "o"
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.cylinder(self.growthDistance, self.diameter/2,
                                         ColorRepresentation(red: 0.7, green: 0.3, blue: 0.1, alpha: 0.95)) // length, radius
        }
        let growthDistance: Double
        let diameter: Double
    }
    
    struct SecondaryBranch: Module {
        public var name = "C"
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.cylinder(self.growthDistance, self.diameter/2,
                                         ColorRepresentation(red: 0.3, green: 0.1, blue: 0.9, alpha: 0.9)) // length, radius
        }
        let growthDistance: Double
        let diameter: Double
    }
    
    static let defines: [String:Double] = [
        "r1": 0.9,   /* Contraction ratio for the trunk */
        "r2": 0.6,   /* Contraction ratio for branches */
        "a0": 45,    /* Branching angle from the trunk */
        "a2": 45,    /* Branching angle for lateral axes */
        "d": 137.5,  /* Divergence angle */
        "wr": 0.707  /* Width contraction ratio */
    ]
    
    static var hondaTree = LSystem(
        Trunk(growthDistance: 10, diameter: 2),
        parameters: defines,
        rules: [
            Rule(Trunk.self, { trunk, params in
                guard let currentDiameter = trunk.diameter,
                      let currentGrowthDistance = trunk.growthDistance,
                      let widthContraction = params.wr,
                      let contractionRatioForTrunk = params.r1,
                      let contractionRatioForBranch = params.r2,
                      let branchAngle = params.a0,
                      let divergence = params.d
                else {
                    throw RuntimeError<Trunk>(trunk)
                }
                // original: !(w) F(s) [ &(a0) B(s * r2, w * wr) ] /(d) A(s * r1, w * wr)
                // Conversion:
                // s -> trunk.growthDistance, w -> trunk.diameter
                // !(w) F(s) => reduce width of pen, then draw the line forward a distance of 's'
                //   this is covered by returning a StaticTrunk that doesn't continue to evolve
                // [ &(a0) B(s * r2, w * wr) ] /(d)
                //   => branch, pitch down by a0 degrees, then grow a B branch (s = s * r2, w = w * wr)
                //      then end the branch, and yaw around by d°
                return [
                    StaticTrunk(growthDistance: currentGrowthDistance, diameter: currentDiameter),
                    Modules.branch,
                    Modules.PitchDown(branchAngle),
                    MainBranch(growthDistance: currentGrowthDistance,
                            diameter: currentDiameter * widthContraction),
                    Modules.endbranch,
                    Modules.TurnLeft(divergence),
                    Trunk(growthDistance: currentGrowthDistance * contractionRatioForTrunk,
                          diameter: currentDiameter * widthContraction)
                    
                ]
            }),
            Rule(MainBranch.self, { branch, params in
                guard let currentDiameter = branch.diameter,
                      let currentGrowthDistance = branch.growthDistance,
                      let widthContraction = params.wr,
                      let contractionRatioForTrunk = params.r1,
                      let contractionRatioForBranch = params.r2,
                      let branchAngle = params.a2,
                      let divergence = params.d
                else {
                    throw RuntimeError<MainBranch>(branch)
                }
                // Original P2: B(s, w) -> !(w) F(s) [ -(a2) @V C(s * r2, w * wr) ] C(s * r1, w * wr)
                // !(w) F(s) - Static Main Branch

                return [
                    StaticBranch(growthDistance: currentGrowthDistance, diameter: currentDiameter),
                    Modules.branch,
                    
                    Modules.RollLeft(branchAngle),
//                    Modules.TurnLeft(branchAngle),
//                    Modules.LevelOut(),
                    SecondaryBranch(growthDistance: currentGrowthDistance*contractionRatioForBranch,
                            diameter: currentDiameter * widthContraction),

                    Modules.endbranch,
                    
                    SecondaryBranch(growthDistance: currentGrowthDistance*contractionRatioForBranch,
                            diameter: currentDiameter * widthContraction)
                ]
            }),
            Rule(SecondaryBranch.self, { branch, params in
                guard let currentDiameter = branch.diameter,
                      let currentGrowthDistance = branch.growthDistance,
                      let widthContraction = params.wr,
                      let contractionRatioForTrunk = params.r1,
                      let contractionRatioForBranch = params.r2,
                      let branchAngle = params.a2,
                      let divergence = params.d
                else {
                    throw RuntimeError<SecondaryBranch>(branch)
                }

                // Original: P3: C(s, w) -> !(w) F(s) [ +(a2) @V B(s * r2, w * wr) ] B(s * r1, w * wr)
                return [
                    StaticBranch(growthDistance: currentGrowthDistance, diameter: currentDiameter),
                    Modules.branch,
                    
                    Modules.RollRight(branchAngle),
//                    Modules.TurnRight(branchAngle),
//                    Modules.LevelOut(),

                    MainBranch(growthDistance: currentGrowthDistance*contractionRatioForBranch,
                            diameter: currentDiameter * widthContraction),

                    Modules.endbranch,
                    
                    MainBranch(growthDistance: currentGrowthDistance*contractionRatioForBranch,
                            diameter: currentDiameter * widthContraction)
                ]

            })
        ]
    )
    
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
     
     // simpler version - L-system 24
     
     { W = 10; }
     w: A(1)
     { W = W * wr; } // re-evaluate current width by contracting
     P1: A(1) -> !(W) F(1) [ &(a0) B(1*r2) ] /(d) A(1*r1)
     P2: B(1) -> !(W) F(1) [ -(a2) @V C(1*r2) ] C(1*r1)
     P3: C(1) -> !(W) F(1) [ +(a2) @V B(1*r2) ] B(1*r1)
     
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
    
}
//
//  RenderCommands.swift
//
//  Created by Joseph Heck on 12/15/21.
//

import Foundation

// MARK: - REPRESENTATION TYPES FOR RENDERING -

/// A struct that represents a color using red, green, blue, and alpha values.
public struct ColorRepresentation: Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    public init(r: Double, g: Double, b: Double) {
        red = r
        green = g
        blue = b
        alpha = 1.0
    }

    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    static var black: ColorRepresentation {
        return ColorRepresentation(r: 0, g: 0, b: 0)
    }
}

// Inspired by turtle command interpretation from the Algorithmic Beauty of Plants, pg 209
public enum TurtleCodes: String {
    // 2D
    case setLineWidth = "!"
    case setColor = "'"
    // 2D & 3D
    case branch = "["
    case endBranch = "]"
    case move = "f"
    case draw = "F"
    case rightTurn = "-"
    case leftTurn = "+"
    case ignore = " "
    case prune = "%" // NOTE(heckj): un-implemented
    // 3D
    case rollLeft = "\\"
    case rollRight = "/"
    case pitchUp = "^"
    case pitchDown = "&"
    case spinToVertical = "$" // NOTE(heckj): un-implemented
    case spinToHorizontal = "_" // aka @V
    case spinVerticalTropism = "e" // NOTE(heckj): un-implemented
    // extensions for 3D objects
    case cylinder = "||"
    case cone = "/\\"
    case sphere = "o"
}

// MARK: - RENDERING COMMAND PROTOCOLS -

// marker protocol to indicate something is a 2D rendering command
public protocol TwoDRenderCmd {
    /// Use a single character or very short string for the name, as it's used in textual descriptions of the state of an L-system.
    var name: String { get }
}

// marker protocol to indicate something is a 3D rendering command
public protocol ThreeDRenderCmd {
    /// Use a single character or very short string for the name, as it's used in textual descriptions of the state of an L-system.
    var name: String { get }
}

// MARK: - RENDERING COMMANDS -

public enum RenderCommand {
    // MARK: - BUILT-IN 2D & 3D FOCUSED MODULES -

    public struct Branch: TwoDRenderCmd, ThreeDRenderCmd {
        public var name: String = TurtleCodes.branch.rawValue
        public init() {}
    }

    public struct EndBranch: TwoDRenderCmd, ThreeDRenderCmd {
        public var name: String = TurtleCodes.endBranch.rawValue
        public init() {}
    }

    public struct Move: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.move.rawValue

        public let length: Double
        public init(length: Double) {
            self.length = length
        }
    }

    public struct Draw: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.draw.rawValue

        public let length: Double
        public init(length: Double) {
            self.length = length
        }
    }

    public struct TurnLeft: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.leftTurn.rawValue

        public let angle: Double
        public init(angle: Double) {
            self.angle = angle
        }
    }

    public struct TurnRight: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.rightTurn.rawValue

        public let angle: Double
        public init(angle: Double) {
            self.angle = angle
        }
    }

    public struct Ignore: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.ignore.rawValue
        public init() {}
    }

    public struct SetLineWidth: TwoDRenderCmd {
        public let name = TurtleCodes.setLineWidth.rawValue
        public let width: Double
        public init(width: Double) {
            self.width = width
        }
    }

    public struct SetColor: TwoDRenderCmd {
        public let name = TurtleCodes.setColor.rawValue
        public let representation: ColorRepresentation
        public init(representation: ColorRepresentation) {
            self.representation = representation
        }
    }

    public struct PitchUp: ThreeDRenderCmd {
        public let name = TurtleCodes.pitchUp.rawValue
        public let angle: Double
        public init(angle: Double) {
            self.angle = angle
        }
    }

    public struct PitchDown: ThreeDRenderCmd {
        public let name = TurtleCodes.pitchDown.rawValue
        public let angle: Double
        public init(angle: Double) {
            self.angle = angle
        }
    }

    public struct RollRight: ThreeDRenderCmd {
        public let name = TurtleCodes.rollRight.rawValue
        public let angle: Double
        public init(angle: Double) {
            self.angle = angle
        }
    }

    public struct RollLeft: ThreeDRenderCmd {
        public let name = TurtleCodes.rollLeft.rawValue
        public let angle: Double
        public init(angle: Double) {
            self.angle = angle
        }
    }

    public struct SpinToFlat: ThreeDRenderCmd {
        public let name = TurtleCodes.spinToHorizontal.rawValue
    }

    public struct SpinToVertical: ThreeDRenderCmd {
        public let name = TurtleCodes.spinToVertical.rawValue
    }

    public struct Cylinder: ThreeDRenderCmd {
        public let name = TurtleCodes.cylinder.rawValue
        public let length: Double
        public let radius: Double
        public let color: ColorRepresentation?
        public init(length: Double, radius: Double, color: ColorRepresentation? = nil) {
            self.length = length
            self.radius = radius
            self.color = color
        }
    }

    public struct Cone: ThreeDRenderCmd {
        public let name = TurtleCodes.cone.rawValue
        public let length: Double
        public let radiusTop: Double
        public let radiusBottom: Double
        public let color: ColorRepresentation?
        public init(length: Double, radiusTop: Double, radiusBottom: Double, color: ColorRepresentation? = nil) {
            self.length = length
            self.radiusTop = radiusTop
            self.radiusBottom = radiusBottom
            self.color = color
        }
    }

    public struct Sphere: ThreeDRenderCmd {
        public let name = TurtleCodes.sphere.rawValue
        public let radius: Double
        public let color: ColorRepresentation?
        public init(radius: Double, color: ColorRepresentation? = nil) {
            self.radius = radius
            self.color = color
        }
    }

    // 2D ONLY
    public static var setLineWidth = SetLineWidth(width: 1)
    public static var setColor = SetColor(representation: ColorRepresentation(r: 0.0, g: 0.0, b: 0.0))

    // 2D and 3D
    public static var move = Move(length: 1.0)
    public static var draw = Draw(length: 1.0)

    public static var turnLeft = TurnLeft(angle: 90)
    public static var turnRight = TurnRight(angle: 90)

    public static var branch = Branch()
    public static var endBranch = EndBranch()

    // 3D ONLY
    public static var pitchUp = PitchUp(angle: 30)
    public static var pitchDown = PitchDown(angle: 30)

    public static var rollRight = RollRight(angle: 90)
    public static var rollLeft = RollLeft(angle: 90)

    public static var spinToFlat = SpinToFlat()

    public static var cylinder = Cylinder(length: 1, radius: 0.1)
    public static var cone = Cone(length: 1, radiusTop: 0, radiusBottom: 0.1)
    public static var sphere = Sphere(radius: 0.1)
}

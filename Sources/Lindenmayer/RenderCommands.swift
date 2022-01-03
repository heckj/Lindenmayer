//
//  RenderCommands.swift
//
//  Created by Joseph Heck on 12/15/21.
//

import Foundation

// MARK: - RENDERING/REPRESENTATION -

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
public protocol TwoDRenderCmd: Module {}

// marker protocol to indicate something is a 3D rendering command
public protocol ThreeDRenderCmd: Module {}

enum RenderCommand {
    // MARK: - BUILT-IN 2D & 3D FOCUSED MODULES -

    struct Branch: TwoDRenderCmd, ThreeDRenderCmd {
        public var name: String = TurtleCodes.branch.rawValue
    }

    struct EndBranch: TwoDRenderCmd, ThreeDRenderCmd {
        public var name: String = TurtleCodes.endBranch.rawValue
    }

    public struct Move: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.move.rawValue
        
        public let length: Double
    }

    public struct Draw: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.draw.rawValue
        
        public let length: Double
    }

    public struct TurnLeft: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.leftTurn.rawValue
        
        public let angle: Double
    }

    public struct TurnRight: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.rightTurn.rawValue
        
        public let angle: Double
    }

    public struct Ignore: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.ignore.rawValue
    }

    public struct SetLineWidth: TwoDRenderCmd {
        public let name = TurtleCodes.setLineWidth.rawValue
        public let width: Double
    }

    public struct SetColor: TwoDRenderCmd {
        public let name = TurtleCodes.setColor.rawValue
        public let representation: ColorRepresentation
    }

    public struct PitchUp: ThreeDRenderCmd {
        public let name = TurtleCodes.pitchUp.rawValue
        public let angle: Double
    }

    public struct PitchDown: ThreeDRenderCmd {
        public let name = TurtleCodes.pitchDown.rawValue
        public let angle: Double
    }

    public struct RollRight: ThreeDRenderCmd {
        public let name = TurtleCodes.rollRight.rawValue
        public let angle: Double
    }

    public struct RollLeft: ThreeDRenderCmd {
        public let name = TurtleCodes.rollLeft.rawValue
        public let angle: Double
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
    }

    public struct Cone: ThreeDRenderCmd {
        public let name = TurtleCodes.cone.rawValue
        public let length: Double
        public let radiusTop: Double
        public let radiusBottom: Double
        public let color: ColorRepresentation?
    }

    public struct Sphere: ThreeDRenderCmd {
        public let name = TurtleCodes.sphere.rawValue
        public let radius: Double
        public let color: ColorRepresentation?
    }
    
    // 2D ONLY
    static var setLineWidth = SetLineWidth(width: 1)
    static var setColor = SetColor(representation: ColorRepresentation(r: 0.0, g: 0.0, b: 0.0))

    // 2D and 3D
    static var move = Move(length: 1.0)
    static var draw = Draw(length: 1.0)
    
    static var turnLeft = TurnLeft(angle: 90)
    static var turnRight = TurnRight(angle: 90)
    
    static var branch = Branch()
    static var endBranch = EndBranch()
    
    // 3D ONLY
    static var pitchUp = PitchUp(angle: 30)
    static var pitchDown = PitchDown(angle: 30)
    
    static var rollRight = RollRight(angle: 90)
    static var rollLeft = RollLeft(angle: 90)
    
    static var spinToFlat = SpinToFlat()
    
    static var cylinder = Cylinder(length: 1, radius: 0.1, color: nil)
    static var cone = Cone(length: 1, radiusTop: 0, radiusBottom: 0.1, color: nil)
    static var sphere = Sphere(radius: 0.1, color: nil)
}

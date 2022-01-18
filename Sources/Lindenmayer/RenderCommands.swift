//
//  RenderCommands.swift
//
//  Created by Joseph Heck on 12/15/21.
//

import Foundation
import SwiftUI // for the `Angle` type

// MARK: - REPRESENTATION TYPES FOR RENDERING -

/// A struct that represents a color using red, green, blue, and alpha values.
public struct ColorRepresentation: Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    /// Creates a new color representation using the RGB values you provide.
    /// - Parameters:
    ///   - r: The red value, from 0 to 1.0.
    ///   - g: The green value, from 0 to 1.0
    ///   - b: The blue value, from 0 to 1.0
    public init(r: Double, g: Double, b: Double) {
        precondition(r <= 1.0 && g <= 1.0 && b <= 1.0)
        red = r
        green = g
        blue = b
        alpha = 1.0
    }
    
    /// Creates a new color representation using the red, green, blue and alpha values you provide.
    /// - Parameters:
    ///   - red: The red value, from 0 to 1.0.
    ///   - green: The green value, from 0 to 1.0.
    ///   - blue: The blue value, from 0 to 1.0.
    ///   - alpha: The alpha value, from 0 to 1.0.
    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        precondition(red <= 1.0 && green <= 1.0 && blue <= 1.0 && alpha <= 1.0)
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    static var black: ColorRepresentation {
        return ColorRepresentation(r: 0, g: 0, b: 0)
    }
}


/// An enumeration that identifies the types of turtle commands and provides a raw string value associated with those types.
///
/// The values for these strings was inspired by the turtle commands as described in [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf) in the appendix, page 209.
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
    case rollToHorizontal = "$" // aka @V
    case spinVerticalTropism = "e" // NOTE(heckj): un-implemented
    // extensions for 3D objects
    case cylinder = "||"
    case cone = "/\\"
    case sphere = "o"
}

// MARK: - RENDERING COMMAND PROTOCOLS -


/// A type that represents a module to provide a 2D representation of an L-system.
///
/// The ``GraphicsContextRenderer`` uses 2D render commands to draw onto a canvas.
public protocol TwoDRenderCmd {
    /// Use a single character or very short string for the name, as it's used in textual descriptions of the state of an L-system.
    var name: String { get }
}

/// A type that represents a module to provide a 3D representation of an L-system.
///
/// The ``SceneKitRenderer`` uses 3D render commands to draw onto a canvas.
public protocol ThreeDRenderCmd {
    /// Use a single character or very short string for the name, as it's used in textual descriptions of the state of an L-system.
    var name: String { get }
}

// MARK: - RENDERING COMMANDS -

/// A collection of render commands, both 2D and 3D, built into Lindenmayer.
public enum RenderCommand {
    // MARK: - BUILT-IN 2D & 3D FOCUSED MODULES -
    
    /// A value that indicates the start of a branch.
    ///
    /// Renderers typically use this as a marker to save the current state on a stack.
    public struct Branch: TwoDRenderCmd, ThreeDRenderCmd {
        public var name: String = TurtleCodes.branch.rawValue
        public init() {}
    }
    
    /// A value that indicates the end of a branch.
    ///
    /// Renderers typically use this as a marker to pop back to the previously stored state.
    public struct EndBranch: TwoDRenderCmd, ThreeDRenderCmd {
        public var name: String = TurtleCodes.endBranch.rawValue
        public init() {}
    }
    
    /// A value that indicates the state of the drawing should move forward in it's current heading by the amount you provide.
    public struct Move: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.move.rawValue

        public let length: Double
        public init(length: Double) {
            self.length = length
        }
    }
    
    /// A value that indicates to draw a line forward by the length you provide.
    public struct Draw: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.draw.rawValue

        public let length: Double
        public init(length: Double) {
            self.length = length
        }
    }
    
    /// A value that indicates the state of the drawing should turn left by the angle you provide.
    public struct TurnLeft: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.leftTurn.rawValue

        public let angle: Angle
        public init(angle: Angle) {
            self.angle = angle
        }
    }

    /// A value that indicates the state of the drawing should turn right by the angle you provide.
    public struct TurnRight: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.rightTurn.rawValue

        public let angle: Angle
        public init(angle: Angle) {
            self.angle = angle
        }
    }
    
    /// A value that indicates the state of the drawing should ignore this module.
    public struct Ignore: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.ignore.rawValue
        public init() {}
    }
    
    /// A value that indicates the state of the drawing should update it's drawing width to the value you provide.
    public struct SetLineWidth: TwoDRenderCmd {
        public let name = TurtleCodes.setLineWidth.rawValue
        public let width: Double
        public init(width: Double) {
            self.width = width
        }
    }
    
    /// A value that indicates the state of the drawing should update it's drawing color to the color representation you provide.
    public struct SetColor: TwoDRenderCmd {
        public let name = TurtleCodes.setColor.rawValue
        public let representation: ColorRepresentation
        public init(representation: ColorRepresentation) {
            self.representation = representation
        }
    }
    
    /// A value that indicates the state of the renderer should pitch upward from its current heading by the angle you provide.
    public struct PitchUp: ThreeDRenderCmd {
        public let name = TurtleCodes.pitchUp.rawValue
        public let angle: Angle
        public init(angle: Angle) {
            self.angle = angle
        }
    }

    /// A value that indicates the state of the renderer should pitch downward from its current heading by the angle you provide.
    public struct PitchDown: ThreeDRenderCmd {
        public let name = TurtleCodes.pitchDown.rawValue
        public let angle: Angle
        public init(angle: Angle) {
            self.angle = angle
        }
    }

    /// A value that indicates the state of the renderer should roll to the right around its current heading by the angle you provide.
    public struct RollRight: ThreeDRenderCmd {
        public let name = TurtleCodes.rollRight.rawValue
        public let angle: Angle
        public init(angle: Angle) {
            self.angle = angle
        }
    }

    /// A value that indicates the state of the renderer should roll to the left around its current heading by the angle you provide.
    public struct RollLeft: ThreeDRenderCmd {
        public let name = TurtleCodes.rollLeft.rawValue
        public let angle: Angle
        public init(angle: Angle) {
            self.angle = angle
        }
    }
    
    /// A value that indicates the state of the renderer should roll around its current heading so that the upward vector is as vertical as possible.
    public struct RollToHorizontal: ThreeDRenderCmd {
        public let name = TurtleCodes.rollToHorizontal.rawValue
    }
    
    /// A value that indicates the renderer should create a 3D cylinder of the radius, length, and color representation that you provide.
    ///
    /// The renderer is expected to also move forward, updating it's state to a position at the end of the cylinder.
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

    /// A value that indicates the renderer should create a 3D cylinder of the length, top radius, bottom radius, and color representation that you provide at the current location.
    ///
    /// The renderer is expected to also move forward, updating it's state to a position at the end of the cone.
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
    
    /// A value that indicates the rendered should create a 3D sphere of the radius you provide at the current location.
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
    /// A value that indicates to set the line width of the renderer to 1.0.
    public static var setLineWidth = SetLineWidth(width: 1)
    /// A value that indicates to set the color representation for the renderer to black.
    public static var setColor = SetColor(representation: ColorRepresentation(r: 0.0, g: 0.0, b: 0.0))

    // 2D and 3D
    /// A value that indicates the renderer should move forward by a length of 1.0.
    public static var move = Move(length: 1.0)
    /// A value that indicates the renderer should draw a line forward at a length of 1.0.
    public static var draw = Draw(length: 1.0)
    
    /// A value that indicates the renderer should turn left by 90°.
    public static var turnLeft = TurnLeft(angle: .degrees(90))
    /// A value that indicates the renderer should turn right by 90°.
    public static var turnRight = TurnRight(angle: .degrees(90))
    /// A value that indicates the start of a branch.
    public static var branch = Branch()
    /// A value that indicates the end of a branch.
    public static var endBranch = EndBranch()

    // 3D ONLY
    /// A value that indicates the renderer should pitch up by 30°.
    public static var pitchUp = PitchUp(angle: .degrees(30))
    /// A value that indicates the renderer should pitch down by 30°.
    public static var pitchDown = PitchDown(angle: .degrees(30))

    /// A value that indicates the renderer should roll right by 90°.
    public static var rollRight = RollRight(angle: .degrees(90))
    /// A value that indicates the renderer should roll left by 90°.
    public static var rollLeft = RollLeft(angle: .degrees(90))

    /// A value that indicates the state of the renderer should roll around its current heading so that the upward vector is as vertical as possible.
    public static var rollToHorizontal = RollToHorizontal()

    /// A value that indicates the renderer should display a cylinder of length 1.0 and radius 0.1, moving forward by 1.0.
    public static var cylinder = Cylinder(length: 1, radius: 0.1)
    /// A value that indicates the renderer should display a cone of length 1.0, bottom radius of 0.1, top radius of 0, and moving forward by 1.0.
    public static var cone = Cone(length: 1, radiusTop: 0, radiusBottom: 0.1)
    /// A value that indicates the renderer should display a sphere of radius 0.1.
    public static var sphere = Sphere(radius: 0.1)
}

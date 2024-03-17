//
//  RenderCommands.swift
//
//  Created by Joseph Heck on 12/15/21.
//

import Foundation

// MARK: - REPRESENTATION TYPES FOR RENDERING -

/// A struct that represents a color using red, green, blue, and alpha values.
///
/// ## Topics
///
/// ### Creating a Color Representation
///
/// - ``init(r:g:b:)``
/// - ``init(red:green:blue:alpha:)``
///
public struct ColorRepresentation: Equatable, Sendable {
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
///
/// ## Topics
///
/// ### Common Codes
///
/// - ``move``
/// - ``draw``
/// - ``branch``
/// - ``endBranch``
/// - ``leftTurn``
/// - ``rightTurn``
/// - ``ignore``
/// - ``prune``
///
/// ### 2D Specific Codes
///
/// - ``setColor``
/// - ``setLineWidth``
///
/// ### 3D Specific Movement Codes
///
/// - ``pitchUp``
/// - ``pitchDown``
/// - ``rollLeft``
/// - ``rollRight``
/// - ``rollUpToVertical``
/// - ``spinVerticalTropism``
/// - ``spinGravityTropism``
///
/// ### 3D Specific Object Codes
///
/// - ``cylinder``
/// - ``cone``
/// - ``sphere``
///
public enum TurtleCodes: String, Sendable {
    // 2D
    /// The string representation for ``RenderCommand/SetLineWidth-swift.struct``
    case setLineWidth = "!"
    /// The string representation for ``RenderCommand/SetColor-swift.struct``
    case setColor = "'"
    // 2D & 3D
    /// The string representation for ``RenderCommand/Branch-swift.struct``
    case branch = "["
    /// The string representation for ``RenderCommand/EndBranch-swift.struct``
    case endBranch = "]"
    /// The string representation for ``RenderCommand/Move-swift.struct``
    case move = "f"
    /// The string representation for ``RenderCommand/Draw-swift.struct``
    case draw = "F"
    /// The string representation for ``RenderCommand/TurnRight-swift.struct``
    case rightTurn = "-"
    /// The string representation for ``RenderCommand/TurnLeft-swift.struct``
    case leftTurn = "+"
    /// The string representation for ``RenderCommand/Ignore``
    case ignore = " "
    /// The reserved string representation for an unimplemented render command.
    case prune = "%" // NOTE(heckj): un-implemented
    // 3D
    /// The string representation for ``RenderCommand/RollLeft-swift.struct``
    case rollLeft = "\\"
    /// The string representation for ``RenderCommand/RollRight-swift.struct``
    case rollRight = "/"
    /// The string representation for ``RenderCommand/PitchUp-swift.struct``
    case pitchUp = "^"
    /// The string representation for ``RenderCommand/PitchDown-swift.struct``
    case pitchDown = "&"
    /// The string representation for ``RenderCommand/RollUpToVertical-swift.struct``
    case rollUpToVertical = "$" // aka @V
    /// The reserved string representation for an unimplemented render command.
    case spinVerticalTropism = "e" // NOTE(heckj): un-implemented
    /// The reserved string representation for an unimplemented render command.
    case spinGravityTropism = "v" // NOTE(heckj): un-implemented
    // extensions for 3D objects
    /// The string representation for ``RenderCommand/Cylinder-swift.struct``
    case cylinder = "||"
    /// The string representation for ``RenderCommand/Cone-swift.struct``
    case cone = "/\\"
    /// The string representation for ``RenderCommand/Sphere-swift.struct``
    case sphere = "o"
}

// MARK: - RENDERING COMMAND PROTOCOLS -

/// A type that represents a 2D rendered representation or a renderer command for a module within an L-System.
///
/// The ``GraphicsContextRenderer`` uses ``RenderCommand`` instances that are marked with this protocol as  2D render commands to draw onto a canvas.
///
/// ## Topics
///
/// ### Inspecting a 2D Render Command
///
/// - ``name``
///
public protocol TwoDRenderCmd: Sendable {
    /// Use a single character or very short string for the name, as it's used in textual descriptions of the state of an L-system.
    var name: String { get }
}

/// A type that represents a 3D rendered representation or a renderer command for a module within an L-System.
///
/// The ``SceneKitRenderer`` uses ``RenderCommand`` instances that are marked with this protocol as 3D render commands to draw into a scene..
///
/// ## Topics
///
/// ### Inspecting a 2D Render Command
///
/// - ``name``
///
public protocol ThreeDRenderCmd: Sendable {
    /// Use a single character or very short string for the name, as it's used in textual descriptions of the state of an L-system.
    var name: String { get }
}

// MARK: - RENDERING COMMANDS -

/// A collection of render commands, both 2D and 3D, built into Lindenmayer.
///
/// ## Topics
///
/// ### Common 2D and 3D Render Commands
///
/// - ``RenderCommand/Draw-swift.struct``
/// - ``RenderCommand/draw-swift.type.property``
/// - ``RenderCommand/Move-swift.struct``
/// - ``RenderCommand/move-swift.type.property``
/// - ``RenderCommand/Branch-swift.struct``
/// - ``RenderCommand/branch-swift.type.property``
/// - ``RenderCommand/EndBranch-swift.struct``
/// - ``RenderCommand/endBranch-swift.type.property``
/// - ``RenderCommand/TurnLeft-swift.struct``
/// - ``RenderCommand/turnLeft-swift.type.property``
/// - ``RenderCommand/TurnRight-swift.struct``
/// - ``RenderCommand/turnRight-swift.type.property``
/// - ``RenderCommand/Ignore``
///
/// ### 2D Render Commands
///
/// - ``RenderCommand/SetColor-swift.struct``
/// - ``RenderCommand/setColor-swift.type.property``
/// - ``RenderCommand/SetLineWidth-swift.struct``
/// - ``RenderCommand/setLineWidth-swift.type.property``
///
/// ### 3D Render Movement Commands
///
/// - ``RenderCommand/PitchUp-swift.struct``
/// - ``RenderCommand/pitchUp-swift.type.property``
/// - ``RenderCommand/PitchDown-swift.struct``
/// - ``RenderCommand/pitchDown-swift.type.property``
/// - ``RenderCommand/RollLeft-swift.struct``
/// - ``RenderCommand/rollLeft-swift.type.property``
/// - ``RenderCommand/RollRight-swift.struct``
/// - ``RenderCommand/rollRight-swift.type.property``
/// - ``RenderCommand/RollUpToVertical-swift.struct``
/// - ``RenderCommand/rollUpToVertical-swift.type.property``
///
/// ### 3D Render Object Commands
///
/// - ``RenderCommand/Cylinder-swift.struct``
/// - ``RenderCommand/cylinder-swift.type.property``
/// - ``RenderCommand/Cone-swift.struct``
/// - ``RenderCommand/cone-swift.type.property``
/// - ``RenderCommand/Sphere-swift.struct``
/// - ``RenderCommand/sphere-swift.type.property``

public enum RenderCommand: Sendable {
    // MARK: - BUILT-IN 2D & 3D FOCUSED MODULES -

    /// A value that indicates the start of a branch.
    ///
    /// Renderers typically use this as a marker to save the current state on a stack.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/Branch-swift.struct/init()``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/Branch-swift.struct/name``
    public struct Branch: TwoDRenderCmd, ThreeDRenderCmd {
        public var name: String = TurtleCodes.branch.rawValue
        public init() {}
    }

    /// A value that indicates the end of a branch.
    ///
    /// Renderers typically use this as a marker to pop back to the previously stored state.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/EndBranch-swift.struct/init()``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/EndBranch-swift.struct/name``
    public struct EndBranch: TwoDRenderCmd, ThreeDRenderCmd {
        public var name: String = TurtleCodes.endBranch.rawValue
        public init() {}
    }

    /// A value that indicates the state of the drawing should move forward in it's current heading by the amount you provide.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/Move-swift.struct/init(length:)``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/Move-swift.struct/name``
    /// - ``RenderCommand/Move-swift.struct/length``
    public struct Move: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.move.rawValue

        public let length: Double
        public init(length: Double) {
            self.length = length
        }
    }

    /// A value that indicates to draw a line forward by the length you provide.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/Draw-swift.struct/init(length:)``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/Draw-swift.struct/name``
    /// - ``RenderCommand/Draw-swift.struct/length``
    public struct Draw: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.draw.rawValue

        public let length: Double
        public init(length: Double) {
            self.length = length
        }
    }

    /// A value that indicates the state of the drawing should turn left by the angle you provide.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/TurnLeft-swift.struct/init(angle:)``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/TurnLeft-swift.struct/name``
    /// - ``RenderCommand/TurnLeft-swift.struct/angle``
    public struct TurnLeft: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.leftTurn.rawValue

        public let angle: Angle
        public init(angle: Angle) {
            self.angle = angle
        }
    }

    /// A value that indicates the state of the drawing should turn right by the angle you provide.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/TurnRight-swift.struct/init(angle:)``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/TurnRight-swift.struct/name``
    /// - ``RenderCommand/TurnRight-swift.struct/angle``
    public struct TurnRight: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.rightTurn.rawValue

        public let angle: Angle
        public init(angle: Angle) {
            self.angle = angle
        }
    }

    /// A value that indicates the state of the drawing should ignore this module.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/Ignore/init()``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/Ignore/name``
    public struct Ignore: TwoDRenderCmd, ThreeDRenderCmd {
        public let name: String = TurtleCodes.ignore.rawValue
        public init() {}
    }

    /// A value that indicates the state of the drawing should update it's drawing width to the value you provide.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/SetLineWidth-swift.struct/init(width:)``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/SetLineWidth-swift.struct/name``
    /// - ``RenderCommand/SetLineWidth-swift.struct/width``
    ///
    public struct SetLineWidth: TwoDRenderCmd {
        public let name = TurtleCodes.setLineWidth.rawValue
        public let width: Double
        public init(width: Double) {
            self.width = width
        }
    }

    /// A value that indicates the state of the drawing should update it's drawing color to the color representation you provide.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/SetColor-swift.struct/init(representation:)``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/SetColor-swift.struct/name``
    /// - ``RenderCommand/SetColor-swift.struct/representation``
    public struct SetColor: TwoDRenderCmd {
        public let name = TurtleCodes.setColor.rawValue
        public let representation: ColorRepresentation
        public init(representation: ColorRepresentation) {
            self.representation = representation
        }
    }

    /// A value that indicates the state of the renderer should pitch upward from its current heading by the angle you provide.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/PitchUp-swift.struct/init(angle:)``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/PitchUp-swift.struct/name``
    /// - ``RenderCommand/PitchUp-swift.struct/angle``
    public struct PitchUp: ThreeDRenderCmd {
        public let name = TurtleCodes.pitchUp.rawValue
        public let angle: Angle
        public init(angle: Angle) {
            self.angle = angle
        }
    }

    /// A value that indicates the state of the renderer should pitch downward from its current heading by the angle you provide.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/PitchDown-swift.struct/init(angle:)``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/PitchDown-swift.struct/name``
    /// - ``RenderCommand/PitchDown-swift.struct/angle``
    public struct PitchDown: ThreeDRenderCmd {
        public let name = TurtleCodes.pitchDown.rawValue
        public let angle: Angle
        public init(angle: Angle) {
            self.angle = angle
        }
    }

    /// A value that indicates the state of the renderer should roll to the right around its current heading by the angle you provide.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/RollRight-swift.struct/init(angle:)``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/RollRight-swift.struct/name``
    /// - ``RenderCommand/RollRight-swift.struct/angle``
    public struct RollRight: ThreeDRenderCmd {
        public let name = TurtleCodes.rollRight.rawValue
        public let angle: Angle
        public init(angle: Angle) {
            self.angle = angle
        }
    }

    /// A value that indicates the state of the renderer should roll to the left around its current heading by the angle you provide.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/RollLeft-swift.struct/init(angle:)``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/RollLeft-swift.struct/name``
    /// - ``RenderCommand/RollLeft-swift.struct/angle``
    public struct RollLeft: ThreeDRenderCmd {
        public let name = TurtleCodes.rollLeft.rawValue
        public let angle: Angle
        public init(angle: Angle) {
            self.angle = angle
        }
    }

    /// A value that indicates the state of the renderer should roll around its current heading so that the upward vector is as vertical as possible.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/RollUpToVertical-swift.struct/init()``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/RollUpToVertical-swift.struct/name``
    public struct RollUpToVertical: ThreeDRenderCmd {
        public let name = TurtleCodes.rollUpToVertical.rawValue
        public init() {}
    }

    /// A value that indicates the renderer should create a 3D cylinder of the radius, length, and color representation that you provide.
    ///
    /// The renderer is expected to also move forward, updating it's state to a position at the end of the cylinder.
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/Cylinder-swift.struct/init(length:radius:color:)``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/Cylinder-swift.struct/name``
    /// - ``RenderCommand/Cylinder-swift.struct/length``
    /// - ``RenderCommand/Cylinder-swift.struct/radius``
    /// - ``RenderCommand/Cylinder-swift.struct/color``
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
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/Cone-swift.struct/init(length:radiusTop:radiusBottom:color:)``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/Cone-swift.struct/name``
    /// - ``RenderCommand/Cone-swift.struct/length``
    /// - ``RenderCommand/Cone-swift.struct/radiusTop``
    /// - ``RenderCommand/Cone-swift.struct/radiusBottom``
    /// - ``RenderCommand/Cone-swift.struct/color``
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
    ///
    /// ## Topics
    ///
    /// ### Creating a Move Command
    ///
    /// - ``RenderCommand/Sphere-swift.struct/init(radius:color:)``
    ///
    /// ### Inspecting a Move Command
    ///
    /// - ``RenderCommand/Sphere-swift.struct/name``
    /// - ``RenderCommand/Sphere-swift.struct/radius``
    /// - ``RenderCommand/Sphere-swift.struct/color``
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
    public static let setLineWidth = SetLineWidth(width: 1)
    /// A value that indicates to set the color representation for the renderer to black.
    public static let setColor = SetColor(representation: ColorRepresentation(r: 0.0, g: 0.0, b: 0.0))

    // 2D and 3D
    /// A value that indicates the renderer should move forward by a length of 1.0.
    public static let move = Move(length: 1.0)
    /// A value that indicates the renderer should draw a line forward at a length of 1.0.
    public static let draw = Draw(length: 1.0)

    /// A value that indicates the renderer should turn left by 90°.
    public static let turnLeft = TurnLeft(angle: .degrees(90))
    /// A value that indicates the renderer should turn right by 90°.
    public static let turnRight = TurnRight(angle: .degrees(90))
    /// A value that indicates the start of a branch.
    public static let branch = Branch()
    /// A value that indicates the end of a branch.
    public static let endBranch = EndBranch()

    // 3D ONLY
    /// A value that indicates the renderer should pitch up by 30°.
    public static let pitchUp = PitchUp(angle: .degrees(30))
    /// A value that indicates the renderer should pitch down by 30°.
    public static let pitchDown = PitchDown(angle: .degrees(30))

    /// A value that indicates the renderer should roll right by 90°.
    public static let rollRight = RollRight(angle: .degrees(90))
    /// A value that indicates the renderer should roll left by 90°.
    public static let rollLeft = RollLeft(angle: .degrees(90))

    /// A value that indicates the state of the renderer should roll around its current heading so that the upward vector is as vertical as possible.
    public static let rollUpToVertical = RollUpToVertical()

    /// A value that indicates the renderer should display a cylinder of length 1.0 and radius 0.1, moving forward by 1.0.
    public static let cylinder = Cylinder(length: 1, radius: 0.1)
    /// A value that indicates the renderer should display a cone of length 1.0, bottom radius of 0.1, top radius of 0, and moving forward by 1.0.
    public static let cone = Cone(length: 1, radiusTop: 0, radiusBottom: 0.1)
    /// A value that indicates the renderer should display a sphere of radius 0.1.
    public static let sphere = Sphere(radius: 0.1)
}

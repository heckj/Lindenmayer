//
//  RenderCommands.swift
//
//  Created by Joseph Heck on 12/15/21.
//

import Foundation

// MARK: - RENDERING/REPRESENTATION -

/// The direction to turn when defining a new rendering direction.
public enum TurnDirection: String {
    case right = "-"
    case left = "+"
}

/// The direction to roll in 3D space when determining a new rendering direction.
public enum RollDirection: String {
    case left = "\\"
    case right = "/"
}

/// The vertical direction to bend when determining a new rendering direction.
public enum PitchDirection: String {
    case up = "^"
    case down = "&"
}

/// A struct that represents a color using red, green, blue, and alpha values.
public struct ColorRepresentation: Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    public init(r: Double, g: Double, b: Double) {
        self.red = r
        self.green = g
        self.blue = b
        self.alpha = 1.0
    }
    
    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    static var black: ColorRepresentation {
        get {
            return ColorRepresentation(r: 0, g: 0, b: 0)
        }
    }
}

// NOTE(heckj): extensions can't be extended by external developers, so
// if we find we want that, these should instead be set up as static variables
// on a struct, and then we do slightly different case mechanisms.
public enum TwoDRenderCommand : Equatable {
    case move(Double = 1.0) // "f"
    case draw(Double = 1.0) // "F"
    case turn(TurnDirection, Double = 90)
    case saveState // "["
    case restoreState // "]"
    case setLineWidth(Double = 1.0)
    case setLineColor(ColorRepresentation = ColorRepresentation(r: 0.0, g: 0.0, b: 0.0))
    case ignore
}

public enum ThreeDRenderCommand : Equatable {
    case pitch(PitchDirection, Double = 30) // rotation around X axis - positive values pitch up
    case roll(RollDirection, Double = 30) // rotation around Z axis - positive values roll to the left
    case yaw(TurnDirection, Double = 90) // rotation around Y axis - positive values turn to the left
    case levelOut // "@V" - rotates the current direction so that the +Y axis aligns to vertical
    case move(Double = 1.0) // "f"
    case cylinder(Double = 1.0, Double = 0.1, ColorRepresentation?) // "F" -> cylinder: length, radius
    case cone(Double = 1.0, Double = 0.1, Double = 0.1, ColorRepresentation?) // "F" -> frustrum/cone setup with length, topradius, bottomradius
    case sphere(Double = 0.1, ColorRepresentation?) // "o" sphere: radius
    case saveState // "["
    case restoreState // "]"
    case ignore
}


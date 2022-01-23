//
//  GraphicsContextRenderer.swift
//
//
//  Created by Joseph Heck on 12/12/21.
//

import CoreGraphics
import SwiftUI

struct PathState {
    var angle: Angle
    var position: CGPoint
    var lineWidth: Double
    var lineColor: ColorRepresentation

    init() {
        self.init(Angle(degrees: -90), .zero, 1.0, ColorRepresentation.black)
    }

    init(_ angle: Angle, _ position: CGPoint, _ lineWidth: Double, _ lineColor: ColorRepresentation) {
        self.angle = angle
        self.position = position
        self.lineWidth = lineWidth
        self.lineColor = lineColor
    }
}

// convenience for making a SwiftUI Color from the Color Representation struct
extension ColorRepresentation {
    /// The SwiftUI color from the color representation.
    var color: SwiftUI.Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

/// A renderer that generates a 2D graphical representation of an L-system.
public struct GraphicsContextRenderer {
    let unitLength: Double

    enum TurnDirection {
        case left
        case right
    }

    /// Creates a new graphics context renderer with a base length of 1.
    /// - Parameter unitLength: A value that scales move and draw rendering commands.
    public init(unitLength: Double = 1) {
        self.unitLength = unitLength
    }

    /// Draws the L-System into the SwiftUI graphics context you provide.
    ///
    /// - Parameters:
    ///   - lsystem: The L-System to draw.
    ///   - context: The SwiftUI graphics context into which to draw.
    ///   - size: The optional size of the available graphics context. If provided, the function pre-calculates the size of the rendered L-system and adjusts the drawing to fill the space available.
    @available(macOS 12.0, iOS 15.0, *)
    public func draw(_ lsystem: LSystem, into context: inout GraphicsContext, ofSize size: CGSize? = nil) {
        if let size = size {
            // This is less pretty, because we have to process the whole damn thing to figure out the end-result
            // size prior to running the commands... grrr.
            let boundingBox = calcBoundingRect(system: lsystem)
            // print("Bounding box of complete path: \(boundingBox)")

            // Next, scale the path to fit snuggly in our path
            let scale = min(size.width / boundingBox.width, size.height / boundingBox.height)
            // print("Setting uniform scale factor of: \(scale)")
            context.scaleBy(x: scale, y: scale)

            // Translate the context based on the bounding box minimums
            context.translateBy(x: -boundingBox.minX, y: -boundingBox.minY)
            // print("translating x by \(-boundingBox.minX) and y by \(-boundingBox.minY)")
        }

        var state: [PathState] = []
        var currentState = PathState()

        for module in lsystem.state {
            for cmd in module.render2D {
                switch cmd.name {
                case TurtleCodes.move.rawValue:
                    if let cmd = cmd as? RenderCommand.Move {
                        currentState = updatedStateByMoving(currentState, distance: unitLength * cmd.length)
                    }
                case TurtleCodes.draw.rawValue:
                    if let cmd = cmd as? RenderCommand.Draw {
                        let path = CGMutablePath()
                        path.move(to: currentState.position)
                        currentState = updatedStateByMoving(currentState, distance: unitLength * cmd.length)
                        path.addLine(to: currentState.position)
                        context.stroke(
                            Path(path),
                            with: GraphicsContext.Shading.color(currentState.lineColor.color),
                            lineWidth: currentState.lineWidth
                        )
                    }
                case TurtleCodes.branch.rawValue:
                    state.append(currentState)
                case TurtleCodes.endBranch.rawValue:
                    currentState = state.removeLast()
                case TurtleCodes.setLineWidth.rawValue:
                    if let cmd = cmd as? RenderCommand.SetLineWidth {
                        currentState = updatedStateWithLineWidth(currentState, lineWidth: cmd.width)
                    }
                case TurtleCodes.setColor.rawValue:
                    if let cmd = cmd as? RenderCommand.SetColor {
                        currentState = updatedStateWithLineColor(currentState, lineColor: cmd.representation)
                    }
                case TurtleCodes.leftTurn.rawValue:
                    if let cmd = cmd as? RenderCommand.TurnLeft {
                        currentState = updatedStateByTurning(currentState, angle: cmd.angle, direction: .left)
                    }
                case TurtleCodes.rightTurn.rawValue:
                    if let cmd = cmd as? RenderCommand.TurnRight {
                        currentState = updatedStateByTurning(currentState, angle: cmd.angle, direction: .right)
                    }
                default: // ignore
                    break
                }
            }
        }
    }

    /// Returns a Core Graphics rectangle after processing the L-System you provide to identify the boundaries of the 2D rendering.
    /// - Parameter system: The L-System to process.
    /// - Returns: The CGRect that represents the boundaries of the draw commands.
    public func calcBoundingRect(system: LSystem) -> CGRect {
        var stateStack: [PathState] = []
        var currentState = PathState()
        var minY: Double = 0
        var maxY: Double = 0
        var minX: Double = 0
        var maxX: Double = 0

        for module in system.state {
            for cmd in module.render2D {
                switch cmd.name {
                case TurtleCodes.move.rawValue:
                    if let cmd = cmd as? RenderCommand.Move {
                        currentState = updatedStateByMoving(currentState, distance: unitLength * cmd.length)
                    }
                case TurtleCodes.draw.rawValue:
                    if let cmd = cmd as? RenderCommand.Draw {
                        currentState = updatedStateByMoving(currentState, distance: unitLength * cmd.length)
                    }
                case TurtleCodes.branch.rawValue:
                    stateStack.append(currentState)
                case TurtleCodes.endBranch.rawValue:
                    currentState = stateStack.removeLast()
                case TurtleCodes.leftTurn.rawValue:
                    if let cmd = cmd as? RenderCommand.TurnLeft {
                        currentState = updatedStateByTurning(currentState, angle: cmd.angle, direction: .left)
                    }
                case TurtleCodes.rightTurn.rawValue:
                    if let cmd = cmd as? RenderCommand.TurnRight {
                        currentState = updatedStateByTurning(currentState, angle: cmd.angle, direction: .right)
                    }
                default: // ignore
                    break
                }
                minY = min(currentState.position.y, minY)
                minX = min(currentState.position.x, minX)
                maxY = max(currentState.position.y, maxY)
                maxX = max(currentState.position.x, maxX)
                // print("current location: [\(currentState.position.x), \(currentState.position.y)]")
                // print("Minimums: [\(minX), \(minY)]")
                // print("Maximums: [\(maxX), \(maxY)]")
            }
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    /// Returns a Core Graphics path representing the set of modules, ignoring line weights and colors.
    /// - Parameters:
    ///   - modules: The modules that make up the state of an LSystem.
    ///   - destinationRect: An optional rectangle that, if provided, the path will be scaled into.
    /// - Returns: The path that draws the 2D representation of the provided LSystem modules.
    func path(modules: [Module], forRect destinationRect: CGRect? = nil) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))

        var state: [PathState] = []
        var currentState = PathState()

        for module in modules {
            for cmd in module.render2D {
                switch cmd.name {
                case TurtleCodes.move.rawValue:
                    if let cmd = cmd as? RenderCommand.Move {
                        currentState = updatedStateByMoving(currentState, distance: unitLength * cmd.length)
                        path.move(to: currentState.position)
                    }
                case TurtleCodes.draw.rawValue:
                    if let cmd = cmd as? RenderCommand.Draw {
                        currentState = updatedStateByMoving(currentState, distance: unitLength * cmd.length)
                        path.addLine(to: currentState.position)
                    }
                case TurtleCodes.branch.rawValue:
                    state.append(currentState)
                case TurtleCodes.endBranch.rawValue:
                    currentState = state.removeLast()
                    path.move(to: currentState.position)
                case TurtleCodes.leftTurn.rawValue:
                    if let cmd = cmd as? RenderCommand.TurnLeft {
                        currentState = updatedStateByTurning(currentState, angle: cmd.angle, direction: .left)
                    }
                case TurtleCodes.rightTurn.rawValue:
                    if let cmd = cmd as? RenderCommand.TurnRight {
                        currentState = updatedStateByTurning(currentState, angle: cmd.angle, direction: .right)
                    }
                default: // ignore
                    break
                }
            }
        }

        guard let destinationRect = destinationRect else {
            return path
        }

        // Fit the path into our bounds
        var pathRect = path.boundingBox
        let containerRect = destinationRect.insetBy(dx: CGFloat(unitLength), dy: CGFloat(unitLength))

        // First make sure the path is aligned with our origin
        var transform = CGAffineTransform(translationX: -pathRect.minX, y: -pathRect.minY)
        var transformedPath = path.copy(using: &transform)!

        // Next, scale the path to fit snuggly in our path
        pathRect = transformedPath.boundingBoxOfPath
        let scale = min(containerRect.width / pathRect.width, containerRect.height / pathRect.height)
        transform = CGAffineTransform(scaleX: scale, y: scale)
        transformedPath = transformedPath.copy(using: &transform)!

        // Finally, move the path to the correct origin
        transform = CGAffineTransform(translationX: containerRect.minX, y: containerRect.minY)
        transformedPath = transformedPath.copy(using: &transform)!

        return transformedPath
    }

    // MARK: - Private

    func updatedStateByMoving(_ state: PathState, distance: Double) -> PathState {
        let x = state.position.x + CGFloat(distance * cos(state.angle.radians))
        let y = state.position.y + CGFloat(distance * sin(state.angle.radians))

        return PathState(state.angle, CGPoint(x: x, y: y), state.lineWidth, state.lineColor)
    }

    func updatedStateWithLineWidth(_ state: PathState, lineWidth: Double) -> PathState {
        return PathState(state.angle, state.position, lineWidth, state.lineColor)
    }

    func updatedStateWithLineColor(_ state: PathState, lineColor: ColorRepresentation) -> PathState {
        return PathState(state.angle, state.position, state.lineWidth, lineColor)
    }

    func updatedStateByTurning(_ state: PathState, angle: Angle, direction: TurnDirection)
        -> PathState
    {
        if direction == .left {
            return PathState(state.angle - angle, state.position, state.lineWidth, state.lineColor)
        }

        return PathState(state.angle + angle, state.position, state.lineWidth, state.lineColor)
    }
}

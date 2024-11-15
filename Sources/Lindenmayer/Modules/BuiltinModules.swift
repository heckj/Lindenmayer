//
//  BuiltinModules.swift
//
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation

/// A namespace for a collection of built-in modules for use in L-systems.
///
///
/// ## Topics
///
/// ### Built-in Modules
///
/// - ``Modules/Move``
/// - ``Modules/Draw``
/// - ``Modules/Branch``
/// - ``Modules/EndBranch``
/// - ``Modules/TurnLeft``
/// - ``Modules/TurnRight``
/// - ``Modules/PitchUp``
/// - ``Modules/PitchDown``
/// - ``Modules/RollLeft``
/// - ``Modules/RollRight``
/// - ``Modules/RollUpToVertical``
///
public enum Modules: Sendable {}

public extension Modules {
    // MARK: - Built-in Modules that are effectively wrappers around specific rendering commands

    /// A module that informs a renderer to turn left while rendering the L-system.
    struct TurnLeft: Module {
        public let name = RenderCommand.turnLeft.name
        public let angle: Angle
        public var render2D: [any TwoDRenderCmd] {
            [RenderCommand.TurnLeft(angle: angle)]
        }

        public var render3D: any ThreeDRenderCmd {
            RenderCommand.TurnLeft(angle: angle)
        }

        public init(angle: Angle = Angle.degrees(90)) {
            self.angle = angle
        }
    }

    /// A module that informs a renderer to turn right while rendering the L-system.
    struct TurnRight: Module {
        public let name = RenderCommand.turnRight.name
        public let angle: Angle
        public var render2D: [any TwoDRenderCmd] {
            [RenderCommand.TurnRight(angle: angle)]
        }

        public var render3D: any ThreeDRenderCmd {
            RenderCommand.TurnRight(angle: angle)
        }

        public init(angle: Angle = Angle.degrees(90)) {
            self.angle = angle
        }
    }

    /// A module that informs a renderer to draw a line along the current heading while rendering the L-system.
    struct Draw: Module {
        public let name = RenderCommand.draw.name
        public let length: Double
        public var render2D: [any TwoDRenderCmd] {
            [RenderCommand.Draw(length: length)]
        }

        public var render3D: any ThreeDRenderCmd {
            RenderCommand.Draw(length: length)
        }

        public init(length: Double = 1) {
            self.length = length
        }
    }

    /// A module that informs a renderer to move forward along the current heading without other representation while rendering the L-system.
    struct Move: Module {
        public let name = RenderCommand.move.name
        public let length: Double
        public var render2D: [any TwoDRenderCmd] {
            [RenderCommand.Move(length: length)]
        }

        public var render3D: any ThreeDRenderCmd {
            RenderCommand.Move(length: length)
        }

        public init(length: Double = 1) {
            self.length = length
        }
    }

    /// A module that informs a renderer that the L-system representation should branch.
    struct Branch: Module {
        public let name = RenderCommand.branch.name
        public var render2D: [any TwoDRenderCmd] {
            [RenderCommand.Branch()]
        }

        public var render3D: any ThreeDRenderCmd {
            RenderCommand.Branch()
        }

        public init() {}
    }

    /// A module that informs a renderer that the branch of the L-system branch representation is complete.
    struct EndBranch: Module {
        public let name = RenderCommand.endBranch.name

        public var render2D: [any TwoDRenderCmd] {
            [RenderCommand.EndBranch()]
        }

        public var render3D: any ThreeDRenderCmd {
            RenderCommand.EndBranch()
        }

        public init() {}
    }

    /// A module that informs a renderer to change the heading by rolling around the current axis to the left.
    struct RollLeft: Module {
        public let name = RenderCommand.rollLeft.name
        public let angle: Angle
        public var render2D: [any TwoDRenderCmd] {
            []
        }

        public var render3D: any ThreeDRenderCmd {
            RenderCommand.RollLeft(angle: angle)
        }

        public init(angle: Angle = .degrees(90)) {
            self.angle = angle
        }
    }

    /// A module that informs a renderer to change the heading by rolling around the current axis to the right.
    struct RollRight: Module {
        public let name = RenderCommand.rollRight.name
        public let angle: Angle
        public var render2D: [any TwoDRenderCmd] {
            []
        }

        public var render3D: any ThreeDRenderCmd {
            RenderCommand.RollRight(angle: angle)
        }

        public init(angle: Angle = .degrees(90)) {
            self.angle = angle
        }
    }

    /// A module that informs a renderer to change the heading by pitching up.
    struct PitchUp: Module {
        public let name = RenderCommand.pitchUp.name
        public let angle: Angle
        public var render2D: [any TwoDRenderCmd] {
            []
        }

        public var render3D: any ThreeDRenderCmd {
            RenderCommand.PitchUp(angle: angle)
        }

        public init(angle: Angle = .degrees(30)) {
            self.angle = angle
        }
    }

    /// A module that informs a renderer to change the heading by pitching down.
    struct PitchDown: Module {
        public let name = RenderCommand.pitchDown.name
        public let angle: Angle
        public var render2D: [any TwoDRenderCmd] {
            []
        }

        public var render3D: any ThreeDRenderCmd {
            RenderCommand.PitchDown(angle: angle)
        }

        public init(angle: Angle = .degrees(30)) {
            self.angle = angle
        }
    }

    /// A module that informs the renderer to roll around its current heading so that the upward vector is as vertical as possible.
    struct RollUpToVertical: Module {
        public let name = RenderCommand.rollUpToVertical.name
        public var render2D: [any TwoDRenderCmd] {
            []
        }

        public var render3D: any ThreeDRenderCmd {
            RenderCommand.rollUpToVertical
        }

        public init() {}
    }
}

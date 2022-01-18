//
//  BuiltinModules.swift
//  X5336
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation
import SwiftUI // for the 'Angle' type

/// A collection of built-in modules for use in LSystems
public enum Modules {}

public extension Modules {
    // MARK: - An Example module -

    struct Internode: Module {
        // This is the kind of thing that I want external developers using the library to be able to create to represent elements within their L-system.
        public var name = "I"
        public var render2D: [TwoDRenderCmd] = [RenderCommand.Draw(length: 10)] // draws a line 10 units long
        public init() {}
    }

    // MARK: - Built-in Modules that are effectively wrappers around specific rendering commands

    struct TurnLeft: Module {
        public let name = RenderCommand.turnLeft.name
        public let angle: Angle
        public var render2D: [TwoDRenderCmd] {
            [RenderCommand.TurnLeft(angle: angle)]
        }

        public var render3D: ThreeDRenderCmd {
            RenderCommand.TurnLeft(angle: angle)
        }

        public init(angle: Angle = Angle.degrees(90)) {
            self.angle = angle
        }
    }

    struct TurnRight: Module {
        public let name = RenderCommand.turnRight.name
        public let angle: Angle
        public var render2D: [TwoDRenderCmd] {
            [RenderCommand.TurnRight(angle: angle)]
        }

        public var render3D: ThreeDRenderCmd {
            RenderCommand.TurnRight(angle: angle)
        }

        public init(angle: Angle = .degrees(90)) {
            self.angle = angle
        }
    }

    struct Draw: Module {
        public let name = RenderCommand.draw.name
        public let length: Double
        public var render2D: [TwoDRenderCmd] {
            [RenderCommand.Draw(length: length)]
        }

        public var render3D: ThreeDRenderCmd {
            RenderCommand.Draw(length: length)
        }

        public init(length: Double = 1) {
            self.length = length
        }
    }

    struct Move: Module {
        public let name = RenderCommand.move.name
        public let length: Double
        public var render2D: [TwoDRenderCmd] {
            [RenderCommand.Move(length: length)]
        }

        public var render3D: ThreeDRenderCmd {
            RenderCommand.Move(length: length)
        }

        public init(length: Double = 1) {
            self.length = length
        }
    }

    struct Branch: Module {
        public let name = RenderCommand.branch.name
        public var render2D: [TwoDRenderCmd] {
            [RenderCommand.Branch()]
        }

        public var render3D: ThreeDRenderCmd {
            RenderCommand.Branch()
        }

        public init() {}
    }

    struct EndBranch: Module {
        public let name = RenderCommand.endBranch.name

        public var render2D: [TwoDRenderCmd] {
            [RenderCommand.EndBranch()]
        }

        public var render3D: ThreeDRenderCmd {
            RenderCommand.EndBranch()
        }

        public init() {}
    }

    struct RollLeft: Module {
        public let name = RenderCommand.rollLeft.name
        public let angle: Angle
        public var render2D: [TwoDRenderCmd] {
            []
        }

        public var render3D: ThreeDRenderCmd {
            RenderCommand.RollLeft(angle: angle)
        }

        public init(angle: Angle = .degrees(90)) {
            self.angle = angle
        }
    }

    struct RollRight: Module {
        public let name = RenderCommand.rollRight.name
        public let angle: Angle
        public var render2D: [TwoDRenderCmd] {
            []
        }

        public var render3D: ThreeDRenderCmd {
            RenderCommand.RollRight(angle: angle)
        }

        public init(angle: Angle = .degrees(90)) {
            self.angle = angle
        }
    }

    struct PitchUp: Module {
        public let name = RenderCommand.pitchUp.name
        public let angle: Angle
        public var render2D: [TwoDRenderCmd] {
            []
        }

        public var render3D: ThreeDRenderCmd {
            RenderCommand.PitchUp(angle: angle)
        }

        public init(angle: Angle = .degrees(30)) {
            self.angle = angle
        }
    }

    struct PitchDown: Module {
        public let name = RenderCommand.pitchDown.name
        public let angle: Angle
        public var render2D: [TwoDRenderCmd] {
            []
        }

        public var render3D: ThreeDRenderCmd {
            RenderCommand.PitchDown(angle: angle)
        }

        public init(angle: Angle = .degrees(30)) {
            self.angle = angle
        }
    }

    struct LevelOut: Module {
        public let name = RenderCommand.rollToHorizontal.name
        public var render2D: [TwoDRenderCmd] {
            []
        }

        public var render3D: ThreeDRenderCmd {
            RenderCommand.rollToHorizontal
        }

        public init() {}
    }
}

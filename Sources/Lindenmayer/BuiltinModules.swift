//
//  BuiltinModules.swift
//  X5336
//
//  Created by Joseph Heck on 12/12/21.
//

import Foundation

/// A collection of built-in modules for use in LSystems
public enum Modules {}

public extension Modules {
    // MARK: - EXAMPLE MODULE -

    struct Internode: Module {
        // This is the kind of thing that I want external developers using the library to be able to create to represent elements within their L-system.
        public var name = "I"
        public var render2D: [TwoDRenderCommand] = [.draw(10)] // draws a line 10 units long
    }

    static var internode = Internode()

    // MARK: - BUILT-IN 2D & 3D FOCUSED MODULES -

    struct Branch: Module {
        public var name = "["
        public var render2D: [TwoDRenderCommand] = [.saveState]
        public var render3D: ThreeDRenderCommand = .saveState
    }

    static var branch = Branch()

    struct EndBranch: Module {
        public var name = "]"
        public var render2D: [TwoDRenderCommand] = [.restoreState]
        public var render3D: ThreeDRenderCommand = .restoreState
    }

    static var endbranch = EndBranch()

    // MARK: - BUILT-IN 3D FOCUSED MODULES -

    struct PitchDown: Module {
        public var name = "&"
        var angle: Double
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.pitch(.down, angle)
        }

        /// Angle to turn (2D) or yaw (3D) in a left direction.
        /// - Parameter angle: angle, in degrees, to turn.
        init(_ angle: Double = 90) {
            self.angle = angle
        }
    }

    static var pitchDown = PitchDown()

    struct PitchUp: Module {
        public var name = "^"
        var angle: Double
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.pitch(.up, angle)
        }

        /// Angle to turn (2D) or yaw (3D) in a left direction.
        /// - Parameter angle: angle, in degrees, to turn.
        init(_ angle: Double = 90) {
            self.angle = angle
        }
    }

    static var pitchUp = PitchUp()

    struct RollLeft: Module {
        public var name = "\\"
        var angle: Double
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.roll(.left, angle)
        }

        /// Angle to roll (3D) in a left direction.
        /// - Parameter angle: angle, in degrees, to roll.
        init(_ angle: Double = 90) {
            self.angle = angle
        }
    }

    static var rollleft = RollLeft()

    struct RollRight: Module {
        public var name = "/"
        var angle: Double
        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.roll(.right, angle)
        }

        /// Angle to roll (3D) in a right direction.
        /// - Parameter angle: angle, in degrees, to roll.
        init(_ angle: Double = 90) {
            self.angle = angle
        }
    }

    static var rollright = RollRight()

    struct LevelOut: Module {
        public var name = "@V"
        public var render3D: ThreeDRenderCommand = .levelOut
    }

    // MARK: - BUILT-IN 2D & 3D FOCUSED MODULES -

    struct TurnLeft: Module {
        public var name = "-"
        var angle: Double
        public var render2D: [TwoDRenderCommand] {
            [.turn(.left, angle)]
        }

        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.yaw(.left, angle)
        }

        /// Angle to turn (2D) or yaw (3D) in a left direction.
        /// - Parameter angle: angle, in degrees, to turn.
        init(_ angle: Double = 90) {
            self.angle = angle
        }
    }

    static var turnleft = TurnLeft()

    struct TurnRight: Module {
        public var name = "+"
        var angle: Double
        public var render2D: [TwoDRenderCommand] {
            [.turn(.right, angle)]
        }

        public var render3D: ThreeDRenderCommand {
            ThreeDRenderCommand.yaw(.right, angle)
        }

        /// Angle to turn (2D) or yaw (3D) in a right direction.
        /// - Parameter angle: angle, in degrees, to turn.
        init(_ angle: Double = 90) {
            self.angle = angle
        }
    }

    static var turnright = TurnRight()

    struct Move: Module {
        public var name = "f"
        var length: Double
        public var render2D: [TwoDRenderCommand] {
            [.move(length)]
        }

        init(_ length: Double = 1.0) {
            self.length = length
        }
    }

    static var move = Move()

    struct Draw: Module {
        public var name = "F"
        var length: Double
        public var render2D: [TwoDRenderCommand] {
            [.draw(length)]
        }

        init(_ length: Double = 1.0) {
            self.length = length
        }
    }

    static var draw = Draw()
}

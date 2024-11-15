//
//  RNGWrapper.swift
//
//
//  Created by Joseph Heck on 12/15/21.
//

import Foundation

/// A class that provides probabilistic functions based on the seedable psuedo-random number generator used to create it.
///
/// ## Topics
///
/// ### Creating a Random Number Generator Wrapper
///
/// - ``RNGWrapper/init(_:)``
///
/// ### Inspecting a Random Number Generator Wrapper
///
/// - ``RNGWrapper/seed``
/// - ``RNGWrapper/position``
///
/// ### Resetting the Seed of a Random Number Generator Wrapper
///
/// - ``RNGWrapper/resetRNG(seed:)``
///
public actor RNGWrapper<PRNG>: Sendable where PRNG: SeededRandomNumberGenerator {
    private var _prng: PRNG
    #if DEBUG
        var _invokeCount: UInt64 = 0
    #endif
    // access to the underlying PRNG state

    public var seed: UInt64 {
        _prng.seed
    }

    public var position: UInt64 {
        _prng.position
    }

    public func resetRNG() {
        let originalSeed = _prng.seed
        _prng = PRNG(seed: originalSeed)
        #if DEBUG
            _invokeCount = 0
        #endif
    }

    /// Creates a new random number generator wrapper class with the random number generator you provide.
    /// - Parameter prng: A random number generator.
    public init(_ prng: PRNG) {
        _prng = prng
    }

    /// Returns a random float value within the range you provide.
    /// - Parameter range: The range of possible values for the float.
    func randomFloat(in range: ClosedRange<Float>) -> Float {
        #if DEBUG
            _invokeCount += 1
        #endif
        return Float.random(in: range, using: &_prng)
    }

    /// Returns a random integer from within the range you provide.
    /// - Parameter range: The range of possible values for the integer.
    func randomInt(in range: ClosedRange<Int>) -> Int {
        #if DEBUG
            _invokeCount += 1
        #endif
        return Int.random(in: range, using: &_prng)
    }

    /// Returns a single module randomly selected from the list you provide.
    /// - Parameter from: The sequence of modules to choose from.
    func select(_ from: [any Module]) -> any Module {
        #if DEBUG
            _invokeCount += 1
        #endif
        return from.randomElement(using: &_prng)!
    }

    /// Returns a random Boolean value of roughly equal odds.
    ///
    /// Also known as a "coin-toss".
    func randomBool() -> Bool {
        #if DEBUG
            _invokeCount += 1
        #endif
        return Bool.random(using: &_prng)
    }

    /// Returns a Boolean value that indicates if the randomly selected value between 0.0 and 1.0 is less than the the probability you provide.
    /// - Parameter prob: The probability, between 0.0 and 1.0, of the result being true.
    func p(_ prob: Float) -> Bool {
        // ensure that the provided probability is between 0.0 and 1.0
        precondition(prob > 0.0 && prob < 1.0)
        let selectedProb = randomFloat(in: 0.0 ... 1.0)
        return selectedProb <= prob
    }

    /// Returns a random float value between 0.0 and 1.0.
    func p() -> Float {
        #if DEBUG
            _invokeCount += 1
        #endif
        return Float.random(in: 0.0 ... 1.0, using: &_prng)
    }
}

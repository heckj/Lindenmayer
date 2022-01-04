//
//  RNGWrapper.swift
//
//
//  Created by Joseph Heck on 12/15/21.
//

import Foundation

/// A class that provides probabilistic functions based on the seedable psuedo-random number generator used to create it.
public final class RNGWrapper<PRNG> where PRNG: RandomNumberGenerator {
    var _prng: PRNG
    var _invokeCount: UInt64 = 0
    
    /// Creates a new random number generator wrapper class with the random number generator you provide.
    /// - Parameter prng: A random number generator.
    public init(_ prng: PRNG) {
        _prng = prng
    }

    /// Returns a random float value within the range you provide.
    /// - Parameter range: The range of possible values for the float.
    func randomFloat(in range: ClosedRange<Float>) -> Float {
        _invokeCount += 1
        return Float.random(in: range, using: &_prng)
    }

    /// Returns a random integer from within the range you provide.
    /// - Parameter range: The range of possible values for the integer.
    func randomInt(in range: ClosedRange<Int>) -> Int {
        _invokeCount += 1
        return Int.random(in: range, using: &_prng)
    }

    /// Returns a single module randomly selected from the list you provide.
    /// - Parameter from: The sequence of modules to choose from.
    func select(_ from: [Module]) -> Module {
        _invokeCount += 1
        return from.randomElement(using: &_prng)!
    }

    /// Returns a random Boolean value of roughly equal odds.
    ///
    /// Also known as a "coin-toss".
    func randomBool() -> Bool {
        _invokeCount += 1
        return Bool.random(using: &_prng)
    }

    /// Returns a Boolean value that indicates if the randomly selected value between 0.0 and 1.0 is less than the the probability you provide.
    /// - Parameter prob: The probability, between 0.0 and 1.0, of the result being true.
    func p(_ prob: Float) -> Bool {
        // ensure that the provided probability is between 0.0 and 1.0
        precondition(prob > 0.0 && prob < 1.0)
        let selectedProb = randomFloat(in: 0.0 ... 1.0)
        return (selectedProb <= prob)
    }

    /// Returns a random float value between 0.0 and 1.0.
    func p() -> Float {
        _invokeCount += 1
        return Float.random(in: 0.0 ... 1.0, using: &_prng)
    }
}

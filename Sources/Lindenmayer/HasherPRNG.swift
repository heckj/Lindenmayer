//
//  HasherPRNG.swift
//
//
//  Created by Joseph Heck on 12/15/21.
//

import Foundation

/// A type that represents a psuedo-random number generator that you can seed.
///
/// The protocol includes a position property that represents a location within the space of random numbers that this protocol generates deterministically.
/// With a given seed and position, the random numbers should be completely deterministic.
public protocol SeededPseudoRandomNumberGenerator: RandomNumberGenerator {
    /// The seed for the random number generator.
    var seed: UInt64 { get }
    /// The position from which to provide the next value within the sequence of random numbers the seed generates.
    var position: UInt64 { get set }

    /// Creates a new pseudo-random number generator with the seed you provide.
    init(seed: UInt64)
}

/// A struct that provides probabilistic functions based on a seedable psuedo-random number generator that you provide.
public final class Chaos<PRNG> where PRNG: RandomNumberGenerator {
    var _prng: PRNG

    public init(_ prng: PRNG) {
        _prng = prng
    }

    /// Returns a random float value within the range you provide.
    /// - Parameter range: The range of possible values for the float.
    func randomFloat(in range: ClosedRange<Float>) -> Float {
        Float.random(in: range, using: &_prng)
    }

    /// Returns a random integer from within the range you provide.
    /// - Parameter range: The range of possible values for the integer.
    func randomInt(in range: ClosedRange<Int>) -> Int {
        Int.random(in: range, using: &_prng)
    }

    /// Returns a single module randomly selected from the list you provide.
    /// - Parameter from: The sequence of modules to choose from.
    func select(_ from: [Module]) -> Module {
        return from.randomElement(using: &_prng)!
    }

    /// Returns a random Boolean value of roughly equal odds.
    ///
    /// Also known as a "coin-toss".
    func randomBool() -> Bool {
        Bool.random(using: &_prng)
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
        return Float.random(in: 0.0 ... 1.0, using: &_prng)
    }

}

/// A seeded pseudo-random number generator that uses Foundation's Hash function as a noise function.
///
/// Inspiration for this class comes from the GDC 2017 video [Noise-Based RNG](https://youtu.be/LWFzPP8ZbdU), which suggests
/// that noise functions result in very effect PRNG generators, are exceptionally fast, and generate
/// consistent and deterministic, random numbers.
public struct HasherPRNG: SeededPseudoRandomNumberGenerator {
    var _seed: UInt64

    /// The current positoin within the noise space that is used to determine the next pseudo-random value.
    public var position: UInt64 = 0

    /// The seed when creating this pseudo-random number generator.
    public var seed: UInt64 {
        _seed
    }

    /// Creates a new pseudo-random number generator with the seed you provide.
    /// - Parameter seed: The seed value.
    public init(seed: UInt64) {
        _seed = seed
    }

    /// Returns the next random Integer.
    public mutating func randomInt() -> Int {
        var hasher = Hasher()
        hasher.combine(seed)
        hasher.combine(position)
        let hashValue = hasher.finalize()
        position += 1
        return hashValue
    }

    /// Returns the next random integer as an UInt64.
    public mutating func next() -> UInt64 {
        var hasher = Hasher()
        hasher.combine(seed)
        hasher.combine(position)
        let hashValue = hasher.finalize()
        position += 1
        return UInt64(truncatingIfNeeded: hashValue)
    }
}

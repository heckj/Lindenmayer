//
//  SeededRandomNumberGenerator.swift
//
//  Created by Joseph Heck on 1/1/22.
//

import Foundation

/// A type that represents a random number generator that you can seed.
///
/// The protocol includes an adjustable position property that represents the current location within the space of random numbers that the random number generates.
/// The seed value is preserved and unchanged, allowing the seeded random number generator to be interrogated and replicated.
/// When applied to a pseudo-random number generator, with a given seed and position, the next random number should be  completely deterministic.
public protocol SeededRandomNumberGenerator: RandomNumberGenerator, Sendable {
    /// The seed for the random number generator.
    var seed: UInt64 { get }

    /// An adjustable position from which influences the next random value that the seed generates.
    var position: UInt64 { get set }

    /// Creates a new pseudo-random number generator with the seed you provide.
    init(seed: UInt64)
}

//
//  HasherPRNG.swift
//  X5336
//
//  Created by Joseph Heck on 12/15/21.
//

import Foundation

/// A seeded pseudo-random number generator based on Foundation's Hash function.
///
/// Inspiration for this class comes from the GDC 2017 video [Noise-Based RNG](https://youtu.be/LWFzPP8ZbdU), which suggests
/// that noise functions result in very effect PRNG generators, are exceptionally fast, and generate
/// consistent and deterministic, random numbers.
public final class HasherPRNG: RandomNumberGenerator {
    var hasher: Hasher
    var _seed: UInt32

    /// The current positoin within the noise space that is used to determine the next pseudo-random value.
    public var position: Int = 0
    
    /// The seed when creating this pseudo-random number generator.
    public var seed: UInt32 {
        get {
            _seed
        }
    }
    
    /// Creates a new pseudo-random number generator with the seed you provide.
    /// - Parameter seed: The seed value.
    public init(seed: UInt32) {
        self.hasher = Hasher()
        self._seed = seed
    }
    
    /// Returns the next random Integer.
    public func randomInt() -> Int {
        hasher.combine(seed)
        hasher.combine(position)
        let hashValue = hasher.finalize()
        position += 1
        return hashValue
    }
    
    /// Returns the next random integer as an UInt64.
    public func next() -> UInt64 {
        hasher.combine(seed)
        hasher.combine(position)
        let hashValue = hasher.finalize()
        position += 1
        return UInt64(truncatingIfNeeded: hashValue)
    }
}


// Adopted from https://github.com/mattgallagher/CwlUtils/blob/0bfc4587d01cfc796b6c7e118fc631333dd8ab33/Sources/CwlUtils/CwlRandom.swift
//    ISC License
//
//    Copyright © 2017 Matt Gallagher ( http://cocoawithlove.com ). All rights reserved.
//
//    Permission to use, copy, modify, and/or distribute this software for any
//    purpose with or without fee is hereby granted, provided that the above
//    copyright notice and this permission notice appear in all copies.
//
//    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//    WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//    MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//    SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//    WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//    ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//    IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/// A pseudo-random number generator that produces random numbers based on an initial seed.
///
/// The algorithm for the generation is xoshiro256, based on the [public domain implementation](http://xoshiro.di.unimi.it).
public struct Xoshiro: SeededRandomNumberGenerator, Sendable {
    /// The initial seed for pseuo-random number generation.
    public let seed: UInt64

    /// The current position of the generator.
    public var position: UInt64

    public typealias StateType = (UInt64, UInt64, UInt64, UInt64)
    private var state: StateType = (0, 0, 0, 0)

    /// Creates a new pseudo-random number generator from the seed value you provide.
    /// - Parameter seed: A seed value.
    public init(seed: UInt64) {
        self.seed = seed
        position = 0
        state = (seed, seed, seed, seed)
    }

    /// Returns the next pseudo-random number.
    public mutating func next() -> UInt64 {
        /*  Written in 2016 by David Blackman and Sebastiano Vigna (vigna@acm.org)

         To the extent possible under law, the author has dedicated all copyright
         and related and neighboring rights to this software to the public domain
         worldwide. This software is distributed without any warranty.

         See <http://creativecommons.org/publicdomain/zero/1.0/>.
         shima-u.ac.jp (remove spaces)
         */

        // Derived from public domain implementation of xoshiro256** here:
        // http://xoshiro.di.unimi.it
        // by David Blackman and Sebastiano Vigna
        let x = state.1 &* 5
        let result = ((x &<< 7) | (x &>> 57)) &* 9
        let t = state.1 &<< 17
        state.2 ^= state.0
        state.3 ^= state.1
        state.1 ^= state.2
        state.0 ^= state.3
        state.2 ^= t
        state.3 = (state.3 &<< 45) | (state.3 &>> 19)
        position += 1
        return result
    }
}

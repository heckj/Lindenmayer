# Change Log

## [0.5.0](https://github.com/heckj/Lindenmayer/releases/tag/0.5.0) (2021-12-23)

The initial release of Lindenmayer.

The library supports creating context-free and contextual parametric L-systems. Built-in modules support 2D and basic 3D visualizations, and some reference implementations of previously described L-systems.

The API is by no means finished, complete, or in a final form. There are several places where I'm considering how to make creating L-systems written in the Swift language more ergonomic, and additional features that I want to add for broader support (such as stochastic production rules).

This edition is suitable for experimentation, and I certainly welcome feedback in the [discussion section](https://github.com/heckj/Lindenmayer/discussions) of the [Github repository](https://github.com/heckj/Lindenmayer/).

## [0.7.0](https://github.com/heckj/Lindenmayer/releases/tag/0.7.0) (2022-1-2)

**BREAKING CHANGES**

Writing rules ergonomic updates:

The process of writing LSystems has been improved by including factory/wrapper methods on the various types of LSystems (basic, RNG, Parameters, RNG+Parameters), and now all the rules are explicitly typed. This in turn allows for the closures that produce the rewriting for the relevant modules to be explicitly typed, so there's no longer a need to down-cast from the existential `Module` type into the specific kind of module in order to use the types parameters when computing what replaces it.

The rules all now also have additional evaluation criteria enabled through an optional (typed) closure so that you can choose if rules are activated not only by the types they match, but in addition with a closure that you provide that can interrogate the modules that were matched.

## [0.7.1](https://github.com/heckj/Lindenmayer/releases/tag/0.7.1) (2022-1-13)

* module cleanup, normalizing rendering commands in https://github.com/heckj/Lindenmayer/pull/23
* Faster iteration in https://github.com/heckj/Lindenmayer/pull/24
* Debug view in https://github.com/heckj/Lindenmayer/pull/28

**Full Changelog**: https://github.com/heckj/Lindenmayer/compare/0.7.0...0.7.1

## [0.7.2](https://github.com/heckj/Lindenmayer/releases/tag/0.7.2) (2022-1-31)

* updating 3D rendering by @heckj in https://github.com/heckj/Lindenmayer/pull/30
* Roll to vertical by @heckj in https://github.com/heckj/Lindenmayer/pull/32
* Updating documentation for Lindenmayer by @heckj in https://github.com/heckj/Lindenmayer/pull/31
* final tweaks to resource locations by @heckj in https://github.com/heckj/Lindenmayer/pull/34
* fixes for updates in dependency modules that are pre-release

**Full Changelog**: https://github.com/heckj/Lindenmayer/compare/0.7.1...0.7.2

## [0.7.3](https://github.com/heckj/Lindenmayer/releases/tag/0.7.3) (2022-806)

* removing Squirrel3 dependency by @heckj in #36, which allows for Lindenmayer to be used within Swift Playgrounds as it's now all pure-swift code (no C-based dependencies)

**Full Changelog**: https://github.com/heckj/Lindenmayer/compare/0.7.2...0.7.3

## [0.8.0](https://github.com/heckj/Lindenmayer/releases/tag/0.8.0) (2024-04-18)

Swift6 compatibility/strict concurrency update

When I originally created this package, async/await wasn't yet available. In supporting strict concurrency and the upcoming Swift 6 release, I've updated the Swift language support to require at least Swift 5.8, and changed the API to utilize async/await on the modules that produce results, with either a custom definition file for the Lindenmayer system, or leveraging the stochastic (random choices) features available in some of the Lindenmayer systems.

**Full Changelog**: https://github.com/heckj/Lindenmayer/compare/0.7.3...0.8.0

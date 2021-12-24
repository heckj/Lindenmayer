# Lindenmayer

[![Build](https://github.com/heckj/Lindenmayer/actions/workflows/swift.yml/badge.svg)](https://github.com/heckj/Lindenmayer/actions/workflows/swift.yml)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20|%20Mac%20-lightgray.svg)]()
[![Swift 5.5](https://img.shields.io/badge/swift-5.5-red.svg?style=flat)](https://developer.apple.com/swift)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Twitter](https://img.shields.io/badge/twitter-@heckj-blue.svg)](http://twitter.com/heckj)

The package provides a library you can expand upon to develop your own [Lindenmayer systems](https://en.wikipedia.org/wiki/L-system), directly in the Swift programming language.
While the package includes a number example L-systems, the primary intent is to allow you to create L-systems with rules and modules that you define.
This implementation provides support for context sensitive, and parametric grammars when creating your L-system.

The library provides 2D and 3D representation rendering of a current L-system states, including some SwiftUI views that you can use to display either 2D or 3D results:
- The 2D representation uses [Canvas](http://developer.apple.com/documentation/swiftui/Canvas) and [GraphicsContext](https://developer.apple.com/documentation/swiftui/graphicscontext) from [SwiftUI](https://developer.apple.com/documentation/swiftui) on Apple platforms.
- The 3D representation uses [SceneKit](https://developer.apple.com/documentation/scenekit) on Apple platforms.

The repository has [Discussions](https://github.com/heckj/Lindenmayer/discussions) enabled if you have questions, as well as [issues logged for planned improvements](https://github.com/heckj/Lindenmayer/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement). 

Contributions are welcome - as discussion, feedback, questions, or code.

## Inspiration

A combination of influences led to this development, initial as an experiment and general exploration.
One part was the [lindenmayer swift playground](https://github.com/henrinormak/lindenmayer) by [@henrinormak](https://twitter.com/henrinormak), which implements a great single-character representation which is perfect for exploring fractal systems.
That, in turn, was built on the work of Aristid Lindenmayer in the book [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/#abop).
The research that Aristid Lindenmayer started continues to be expanded by [Professor Przemyslaw Prusinkiewicz](https://pages.cpsc.ucalgary.ca/~pwp) with generous publications of research papers on the site [Algorithmic Botany](http://algorithmicbotany.org).

A couple of the papers expand on the tooling to create and evaluate L-systems, and their advances allow for interesting new capabilities to be expressed in the L-systems:

- [The Design and Implementation of the L+C Modeling Language](http://algorithmicbotany.org/papers/l+c.tcs2003.html) (R Karwowski 2003)
- [Parametric L-systems and Their Application to the Modelling and Visualization of Plants](http://algorithmicbotany.org/papers/hanan.dis1992.html) (J Hanan 1992)

The features that I was most interested in leveraging:

- Parameters within an L-system's modules and exposing them to grammar evaluation and production choices (parametric L-systems).
- The introduction of random values with those parameters (stochastic grammars).

While this project can be implemented using an interpreter, I wanted to see how far I could leverage the Swift language.
This project attempts to follow in the conceptual footsteps of the L+C language to create a mechanism to create L-systems that compile down to machine code for efficiency of execution.

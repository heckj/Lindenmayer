# ``Lindenmayer``

Lindenmayer provides a library to develop and run your own Lindenmayer Systems.

## Overview

The package includes the core types to support you in building your own Lindenmayer systems (also known as L-systems), and a number examples sourced from Wikipedia and research papers.
The library provides types and APIs enable you to create L-systems with rules and modules that you define, and renderers to generate 2D and 3D representations of the results.

The 2D renderer uses [Canvas](http://developer.apple.com/documentation/swiftui/Canvas) and [GraphicsContext](https://developer.apple.com/documentation/swiftui/graphicscontext) from [SwiftUI](https://developer.apple.com/documentation/swiftui) on Apple platforms.
The 3D renderer uses [SceneKit](https://developer.apple.com/documentation/scenekit) on Apple platforms.
The related package `LindenmayerViews` provides SwiftUI views that present the results of the renderers.

The API provides support for both context free and context sensitive L-system grammars, as well as parametric grammars.

To get support for using this package, see the [Discussions on Github](https://github.com/heckj/Lindenmayer/discussions) for questions and community feedback, or the [Github issue tracker](https://github.com/heckj/Lindenmayer/issues).
For more information about L-systems, see the Wikipedia page [L-system](https://en.wikipedia.org/wiki/L-system).

## Topics

### Creating L-Systems

- ``Lindenmayer``
- ``LSystemBasic``
- ``LSystemRNG``
- ``LSystemDefinesRNG``

- ``LSystem``
- ``ParametersWrapper``
- ``RNGWrapper``

- ``Modules``
- ``Module``
- ``RenderCommand``
- ``TurtleCodes``
- ``TwoDRenderCmd``
- ``ThreeDRenderCmd``
- ``ColorRepresentation``

- ``Rule``
- ``RewriteRuleDirect``
- ``RewriteRuleLeftDirect``
- ``RewriteRuleDirectRight``
- ``RewriteRuleLeftDirectRight``

- ``RewriteRuleDirectRNG``
- ``RewriteRuleLeftDirectRNG``
- ``RewriteRuleDirectRightRNG``
- ``RewriteRuleLeftDirectRightRNG``

- ``RewriteRuleDirectDefines``
- ``RewriteRuleLeftDirectDefines``
- ``RewriteRuleDirectRightDefines``
- ``RewriteRuleLeftDirectRightDefines``

- ``RewriteRuleDirectDefinesRNG``
- ``RewriteRuleLeftDirectDefinesRNG``
- ``RewriteRuleDirectRightDefinesRNG``
- ``RewriteRuleLeftDirectRightDefinesRNG``

- ``ModuleSet``
- ``SimpleAngle``
- ``Angle``

### Rendering L-Systems

- ``GraphicsContextRenderer``
- ``SceneKitRenderer``

### Debugging L-Systems

- ``DebugModule``
- ``Examples2D``
- ``Detailed2DExamples``
- ``Examples3D``
- ``Detailed3DExamples``

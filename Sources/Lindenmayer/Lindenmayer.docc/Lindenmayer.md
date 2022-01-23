# ``Lindenmayer``

Lindenmayer provides a library to develop and run your own Lindenmayer Systems.

## Overview

Lindenmayer systems (also known as L-systems) are formalized rewriting tools used to create recursive fractals and organic shapes.
The simplest form of an L-system uses a sequence of single characters, and a set of rules it applies to each element of the sequence, replacing it with one or more new elements. 
The sequence of elements are then interpreted, often using a turtle graphics metaphor, into a visual representation.

This library implements a more advanced form L-system, known as a parametric, contextual L-system, inspired by book [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
The library includes types and protocols to support building your own Lindenmayer systems and a number examples sourced from [Wikipedia's L-system page](https://en.wikipedia.org/wiki/L-system) and [research papers](http://algorithmicbotany.org/papers/) hosted at [Algorithmic Botany](http://algorithmicbotany.org/).

While the simplest forms of L-systems use single characters, this library defines the ``Module`` protocol, which represents one of the elements.
In addition to a number of built-in ``Modules``, you can define your own modules with properties that are made available to rewriting rules.

To get support for using this package, see the [Discussions on Github](https://github.com/heckj/Lindenmayer/discussions) for questions and community feedback, or the [Github issue tracker](https://github.com/heckj/Lindenmayer/issues).

## Topics

### Lindenmayer systems

- <doc:Creating_L-systems>

- ``LSystemBasic``
- ``LSystemRNG``
- ``ParameterizedRandonContextualLSystem``
- ``LSystem``
- ``ModuleSet``
- ``RNGWrapper``
- ``ParametersWrapper``

### Modules

- ``Modules``
- ``Module``
- ``DebugModule``
- ``RenderCommand``
- ``TurtleCodes``
- ``TwoDRenderCmd``
- ``ThreeDRenderCmd``
- ``ColorRepresentation``
- ``SimpleAngle``
- ``Angle``

### Rules 

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

### Renderers

- ``GraphicsContextRenderer``
- ``SceneKitRenderer``

### Example L-systems

- ``Examples2D``
- ``Detailed2DExamples``
- ``Examples3D``
- ``Detailed3DExamples``

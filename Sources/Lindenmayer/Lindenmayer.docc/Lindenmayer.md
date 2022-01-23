# ``Lindenmayer``

Lindenmayer provides a library to develop and run your own Lindenmayer Systems.

## Overview

Lindenmayer systems (also known as L-systems) are formalized rewriting tools used to create recursive fractals and organic shapes.
The simplest forms for L-systems using a sequence of single characters, and a set of rules that are processed over the sequence to replace each element with one or more new elements. 
The sequence of elements are then interpreted, often using a turtle graphics metaphor, into a visual representation.

This library implements a more complex form of L-systems, known as a parametric, contextual L-system, as inspired by book [The Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf).
The library includes the core types to support you in building your own Lindenmayer systems (also known as L-systems), and a number examples sourced from Wikipedia and research papers.

While the simplest forms of L-systems use single characters, this library defines ``Module``, which represents one of the elements, and can include properties with values.
In addition to a number of built-in ``Modules``, you can define your own modules with your own properties which are made available to rewriting rules.

To get support for using this package, see the [Discussions on Github](https://github.com/heckj/Lindenmayer/discussions) for questions and community feedback, or the [Github issue tracker](https://github.com/heckj/Lindenmayer/issues).
For more information about L-systems, see the Wikipedia page [L-system](https://en.wikipedia.org/wiki/L-system).

## Topics

### Creating L-systems

- <doc:Creating_L-systems>

### Types of L-Systems

- ``LSystemBasic``
- ``LSystemRNG``
- ``LSystemDefinesRNG``
- ``LSystem``
- ``ParametersWrapper``
- ``RNGWrapper``
- ``ModuleSet``

### Modules

- ``Modules``
- ``Module``
- ``RenderCommand``
- ``TurtleCodes``
- ``TwoDRenderCmd``
- ``ThreeDRenderCmd``
- ``ColorRepresentation``

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

- ``SimpleAngle``
- ``Angle``

### Rendering L-systems

- ``GraphicsContextRenderer``
- ``SceneKitRenderer``

### Debugging L-systems

- ``DebugModule``

### Example L-systems
- ``Examples2D``
- ``Detailed2DExamples``
- ``Examples3D``
- ``Detailed3DExamples``

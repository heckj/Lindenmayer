# Creating L-systems

Create systems that grow and evolve.

## Overview

The elements that make up an L-system are modules, defined in Lindenmayer as structs that conform to the ``Module`` protocol.

To create an L-system, you provide it with at least one module as a starting point, called `axiom`, and one or more rules.
An L-system maintains its state as a sequence of modules, and when you invoke `evolve`, the L-system iterates through all of the modules in it's state, attempting to invoke one of the rules.
The set of rules within an L-system are evaluated, and the first one matching is used.
If no rules match, then the module is ignored and left in it's current place.
If a rule matches, then the L-system invokes its `produce` closure, and replaces the module with the set of modules that closure returns.

### Creating your First L-System

To create an L-system, define the modules you require and call one of the `create` initializers on ``LSystem``, such as ``LSystem/create(_:)-12ubu``, providing it with the module, or modules, that make up the starting set for your L-system.
The following example illustrates defining two modules, `A` and `B`, and providing an instance of one to start the L-system:

```
struct A: Module {
    public var name = "A"
}

struct B: Module {
    public var name = "B"
}

var algae = Lsystem.create(A())
```

The working logic of an L-system is captured in its rules. 
Use the `rewrite` function, which returns an new L-system after adding the rule you defined to its list of rules.
When you define a rule, provide it with the type of module that it should match and a closure that produces a list of modules. 
The following example adds a rule that matches to the module `A`, and replaces any instance of `A` with an instance of `A` followed by an instance of `B`:

```
algae = algae.rewrite(A.self) { _ in
    [a, b]
}
```

A convenient way to define an L-system is chaining the rules one after another.
The full algae example, for example:

```
let algae = LSystem.create(A())
    .rewrite(A.self) { _ in
        [A(), B()]
    }
    .rewrite(B.self) { _ in
        [A()]
    }
```

### Evolving an L-system

When you call `evolve` on an L-system, it iterates through its state, applying the rules, and generates a new L-system with the updated state.
You can also call `evolved(iterations:)` to repeatedly evolve the L-system.

Read the state of an L-system through its `state` property, which returns an array of ``Module``.
The instances returned from the array are existential types (meaning they are some type that conforms to ``Module``), so expect to interact with them through the properties defined within the ``Module`` protocol, or by converting the type to an explicit type to access any additional properties your module's type may include.

Be aware that many L-systems extend the length of the state geometrically as they evolve, so calls to `evolve` may be quite expensive and take noticeable, or considerable, time and memory.

### Displaying an L-system

Two renderers are included with the Lindenmayer library, ``GraphicsContextRenderer`` for rendering into a SwiftUI [`Canvas`](https://developer.apple.com/documentation/swiftui/Canvas) view, and ``SceneKitRenderer`` for generating a SceneKit [`SCNScene`](https://developer.apple.com/documentation/scenekit/scnscene).
Pass an instance of the L-system to a renderer, which reads through the `state` and generates a visual representation based on the relevant ``RenderCommand`` that are associated with each Module.
The default implementation for either ``Module/render2D-1c1hi`` or ``Module/render3D-2t57p`` of ``Module`` is ``RenderCommand/Ignore``, which renderers ignore.

The ``GraphicsContextRenderer`` reads the `render2D` property, and draws the representation by using the ``RenderCommand`` returned from the property as turtle graphics commands.
The ``SceneKitRenderer`` reads the `render3D` property, adding the 3D element and/or updating the state of the renderer, to generate the SceneKit scene.
Lindenmayer comes with a number of built-in modules that you can use, either as a representation of your own modules as a ``RenderCommand``, or by including them in the set of modules returned by one of your rules.
See ``Modules`` for the set of 2D and 3D built-in modules that the library includes.

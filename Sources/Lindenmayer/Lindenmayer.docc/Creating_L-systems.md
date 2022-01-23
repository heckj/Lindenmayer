# Creating L-systems

<!--@START_MENU_TOKEN@-->Summary<!--@END_MENU_TOKEN@-->

## Overview

The L-systems support a seedable random number generator, to support including randomness in the rule rewriting, and seedable to allow it to also be explicitly deterministic.
When you create a rule with a random number generator, the random number generator is provided to the closures you write when defining rules.
The L-systems also support including a type with parameters that you can use as general definitions or as a container for values.
Like the random number generator, when you create an L-system with a definition type, it is provided to the closures you write when defining rules.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->

# data-oriented
An example of a data-oriented gun engine

## A few notes about the design philosophy
Types are declared in a module. Modules provide functions to operate on that type, as well as supporting types that have no associative function. All types are assumed immutable outside of their module. This means that all type mutability can only occur within the module they are defined in. This allows us to better reason about our code.

The usage of `not` is heavily avoided, especially in if statements. It is clearer to use `==`

## A few notes about file organization
Files should be organized in this format:
```
Type and linting modifiers

Service imports

Service defined variables (like Players.LocalPlayer)

Required modules

Module level constants

Module type(s)

Module header

Module functions

For non-module scripts: function calls

For module-scripts: return statement
```

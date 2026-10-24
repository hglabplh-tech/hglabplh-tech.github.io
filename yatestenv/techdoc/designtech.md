- [GoTo Index](../index.html)
 
# Design and technical documentation

The design of `YATestEnvironment`is complex. One part of the application implements added-on checks for parameters and return values, e.g., whether a string is in a correct email, IP, or URL format.

The other part reflects namespaces, classes, and packages in Clojure, Java, Kotlin, Scala, and Python, and transforms the results into a unified map format. This result is later used to define tests and test data. The reflection is defined as its own package so that the output can be used in different projects as well.

The tests and test data are generated from the reflection data and from use case definitions or test matrices.

This part also has features for mocking functions during test runs. Use this feature with care; it should be used only to mock external logic from other libraries. If you need mocking for your project functions, something in your design may be wrong. 

The other feature is the spy for functions or methods; the spy executes the original function unchanged and collects only runtime data, e.g., the number of calls to a function and the dynamic parameter or return value types. It can be used if the types of the functions cannot be distinguished statically. 

- [Detailed technical documentation](./internals.html) 
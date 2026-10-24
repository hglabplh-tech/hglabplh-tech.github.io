- [GoTo Index](../index.html)
- [Design and Tech Documentation](./designtech.html)

# The technical documentation manual

## The add-ons for developing applications

### Clojure `active-data`: more realms and how they work:

For `active-data`, there is a realm -> `realm/restricted` which can be used to define additional realms. In the original `active-data` copy, this realm must be used with caution. I fixed the validation issue in my copy and submitted a change request.
My copy/fork, which is always updated with the latest development in `active-data` can be found here:
- [My fork of `active-data`](https://github.com/hglabplh-tech/active-data)


## The reflection module

### Reflection of our different languages

Reflecting namespaces/classes/functions is the first step in gathering data about the application's interfaces, which is later used to generate tests or test data aligned with the interfaces' contracts.

This reflection is written for each of our languages in the language itself by using the reflection/inspection mechanisms of the language itself. Then we transform the results into a unified JSON format across languages. In addition, there is för each language, an area where language-specific reflection values can take place.

#### Clojure

In Clojure, we consider not only standard metadata. It is recommended to use `schema` and/or `active data` to define function contracts, variable and parameter types and ranges, as well as records of `active-data` for compound data. The advantage is that `schema and active-data` definitions can be used to check input and output correctness at runtime.  

### How unified reflection data is collected and emitted


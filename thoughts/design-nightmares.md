- [GoTo top](../index.html)
- [GoTo index](./index.html)
- [GoTo Next](./timelines.html)
- [Go Back](./index.html)

# Nightmares of design and coding fails

## Nightmares in Java

### 1\. An Inner Class with its own logic in an Annotation

The first example of an architectural nightmare in Java is an inner class with its own logic in an Annotation. This bad pattern leads to wrong associations. The inner class is automatically static. It is not instantiated with the Annotation. Since an Annotation is a completely passive construct that should only attribute a Class, Method, or Parameter, the inner class is misplaced here. The logic for deciding what to do with an annotation must live in an external Top-level class. Here are some key reasons why this is a very bad idea:

#### Why the Compiler Allows It

Annotations in Java are actually specialized forms of interfaces under the hood. Because Java allows standard interfaces to contain nested `static` classes, the compiler blindly extends that same rule to annotations. The nested class `BadIdea` is implicitly static and public, meaning it behaves like any ordinary outer class, just grouped under the annotation's namespace syntax `(MethodDescriberBad.BadIdea)`.

##### 1\.  Annotations are Strictly Immutable Metadata

Annotations are designed to be static, read-only configuration blueprints for compilers, frameworks, or reflection engines. They describe code structure before execution. Inserting a mutable class `(int counter = 0)` that changes values dynamically at runtime creates a massive paradox: **mutable state living inside an immutable metadata marker**.

##### 2\. False Sense of Scoping and Encapsulation

Developers looking at this code might mistakenly assume that each method annotated with @MethodDescriberBad gets its own isolated instance of BadIdea.

-  **The Reality:** The class BadIdea is just a loose blueprint. It has no physical binding to the individual methods where the annotation is placed.
-  To actually use it, a developer would still have to manually type `new MethodDescriberBad.BadIdea(X)`. The nesting provides no architectural automation; it is just an awkward folder structure.

##### 3\. Serious Thread-Safety Risks

Annotations are read at runtime several times by many frameworks for testing (JUnit), transaction handling (i.e., Isolation Levels) using databases inside application containers, and so on. This happens in asynchronous mode. The problem with the inner class is that, in that case, the state can change in parallel without protection against asynchronous access, which can lead to unpredictable results in the worst case.

Here is a code example that compiles and works, but it may be the greatest nightmare ever:

**DO NOT DO IT**

```java
@Target(value = {ElementType.METHOD})
@Retention(value = RetentionPolicy.RUNTIME)
public @interface MethodDescriberBad {
    Category category() default Category.APIS;

    String shortDescription() default "::to-describe::";

    String[] execSteps() default {};

    static class BadIdea {
        int counter = 0;

        BadIdea(int count) {
            this.counter = count;
        }

        public int increment() {
            return this.counter++;
        }

        public int decrement() {
            return this.counter--;
        }

        public int counter() {
            return this.counter;
        }
    }
}
```

- Harald Glab-Plhak
- Computer Science since 1992
- &copy; Harald Glab-Plhak (2026)


- [GoTo top](../index.html)
- [GoTo index](./index.html)
- [GoTo Next](./timelines.html)
- [Go Back](./index.html)

# Nightmares of design and coding fails

## Nightmares in Java

### 1\. An Inner Class with its own logic in an Annotation

The first example of an architectural nightmare in Java is an inner class with its own logic in an Annotation. This bad pattern creates incorrect associations. The inner class is automatically static. It is not instantiated with the Annotation. Since an Annotation is a completely passive construct that should only attribute a Class, Method, or Parameter, the inner class is misplaced here. The logic for deciding what to do with an annotation must live in an external Top-level class. Here are some key reasons why this is a very bad idea:

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
### 2\. An Inner Class in a Record except being a Record

It can make sense to nest a record inside a record, especially for generating JSON or other things from it. 

This is no problem:

```java
public record GoodRecordDesign (String name, InnerRecord details) {
    // This nested record is implicitly static!
    public record InnerRecord(int id, String description) {}
}
```


But nesting classes, interfaces, or enums inside a record is a bad idea. Here is a small explanation why.



#### Why Nesting inside a Record leads to Poor Design

1. **Violates the Single Responsibility Principle (SRP)**: A record's sole job is to be a transparent, immutable data carrier ("dumb data"). The moment you start nesting classes, enums, or interfaces inside it, the record becomes a "kitchen sink" mixing data definitions with architectural behavior.
2. **Confuses Mutability Expectations**: Records are strictly immutable. If you nest a traditional class inside a record, that inner class can have mutable fields. This creates a confusing hybrid object that looks immutable from the outside but can change state on the inside.
3. **Reduces Readability and Reusability**: Nesting classes inside a record forces other parts of your application to write deeply nested types (e.g., OuterRecord.InnerClass). If another part of your application needs to use that inner class independently, it is awkwardly tied to the record.


```java
public record PoorRecordDesign(String username, SecurityContext security) {

    // 1. A traditional static nested class (allowed)
    // Note: Writing 'static' is optional; it is static by default.
    public static class SecurityContext {
        private String token;

        public SecurityContext(String token) { this.token = token; }
        public String getToken() { return token; }
    }

    // 2. An inner enum (allowed & implicitly static)
    public enum AccountStatus {
        ACTIVE, SUSPENDED, DELETED
    }

    // 3. An inner interface (allowed & implicitly static)
    public interface Validator {
        boolean validate(UserProfile profile);
    }
}
```

### 3\. An Inner Class in an Enumeration except being a Record

Nesting classes inside a Java enum is not a good idea. It leads to similar complications as nesting any class in a record. One exception makes this strategy a powerful, clean tool for implementing enum-value logic.

#### 1\. The useful exception:

```java
public enum PaymentProcessor {
    CREDIT_CARD(payload -> "Processing credit card token: " + payload),
    PAYPAL(payload -> "Redirecting to PayPal for: " + payload),
    CRYPTO(payload -> "Verifying blockchain ledger for: " + payload);

    // 1. NESTED INTERFACE: Defines the behavior strategy
    // Highly acceptable because it is tightly bound ONLY to this enum's domain
    @FunctionalInterface
    private interface ActionStrategy {
        String execute(String payload);
    }

    private final ActionStrategy strategy;

    // Constructor assigns the strategy to the constant
    PaymentProcessor(ActionStrategy strategy) {
        this.strategy = strategy;
    }

    // Public method exposes the execution cleanly
    public String process(String data) {
        return strategy.execute(data);
    }
}
```

This is useful because the inner interface is used only with the enum values, which define the strategy interface as a value. The interface works only on the enumeration values to find the right strategy, nothing else. 

So the strategy interface has a direct relation to he enum values. The other situations, like defining interfaces and other classes inside an enumeration. This is a bad design decision. Enumerations are a classic way to enumerate values and give them names for more readable code. A pure enumeration looks like that

```java
public enum ConnectionStates {
	CREATED,
	CONNECTED,
	REJECTED,
	SERVER_ERROR,
	REDIRECTED,
	WAIT_STATE,
	CLOSED,
	NONE;		
}
```

Java extended this pure definition of enums by allowing users to add custom values and methods. 

```java
public enum ConnectionStates {
    CREATED("created", 100),
    CONNECTED("connected", 200),
    REJECTED("rejected", 401), // Fixed description bug and added missing comma
    SERVER_ERROR("server-error", 500),
    REDIRECTED("redirected", 201),
    WAIT_STATE("wait-for-processing", 0),
    CLOSED("closed", 0),       // Added missing comma
    NONE("none", -1);          // Semicolon properly terminates the constants list

    private final String description;
    private final int httpCode;

    // Enum constructors must be private (or package-private)
    ConnectionStates(String description, int httpCode) {
        this.description = description;
        this.httpCode = httpCode;
    }

    public String description() {
        return this.description;
    }
	
    public int httpCode() {
        return this.httpCode;
    }

    public static ConnectionStates findByDescription(String description) {
        if (description == null) {
            return ConnectionStates.NONE;
        }
        for (ConnectionStates state : ConnectionStates.values()) {
            // Null-safe comparison pattern
            if (description.equals(state.description())) {
                return state;
            }
        }
        return ConnectionStates.NONE;
    }	
}
``` 

**NOTE:** Copyright statement
- Harald Glab-Plhak
- Computer Science since 1992
- &copy; Harald Glab-Plhak 2026


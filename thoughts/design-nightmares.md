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

So the strategy interface has a direct relation to he enum values. Other approaches, like defining interfaces and other classes inside an enumeration, are also bad. This is a bad design decision. Enumerations are a classic way to enumerate values and give them names for more readable code. A pure enumeration looks like that

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

A bad example using inner classes and methods in an enum is shown here:

```java

import java.util.ArrayList;
import java.util.List;

public enum OrderStatusBad {
    PENDING("Pending"),
    PAID("Paid"),
    SHIPPED("Shipped");

    // 1. BAD: Mutable field inside an enum singleton!
    // Every thread in the application shares and overwrites this counter.
    private String label;
    private int transitionCount = 0;

    // 2. BAD: Mutable static collection hidden inside the enum
    private static final List<String> AUDIT_LOG = new ArrayList<>();

    OrderStatusBad(String label) {
        this.label = label;
    }

    // 3. BAD: Setter mutating the singleton's state at runtime
    public void setLabel(String newLabel) {
        this.label = newLabel; // Thread-safety nightmare!
    }

    // 4. BAD: Heavy side effects, I/O, and state mutation mixed into enum logic
    public void processOrderAndNotify(String orderId) {
        this.transitionCount++; // Race condition under concurrent requests
        AUDIT_LOG.add("Order " + orderId + " moved to " + this.name());
        
        // Enums should never contain infrastructure/persistence logic
        System.out.println("Connecting to SMTP server to email customer about " + orderId);
    }

    // 5. BAD: Nested mutable inner class living inside a fixed constant type
    public static class StatusTracker {
        private int activeErrors = 0;

        public void recordError() {
            this.activeErrors++;
        }

        public int getActiveErrors() {
            return activeErrors;
        }
    }
}


```
This is bad design because it is not clear what happens here, the logic is mixed up, and an enum constant's behavior can change at runtime. Here is the explanation in detail:

- **Broken Singleton Immutability:** Enum constants (PENDING, PAID, SHIPPED) exist only once per JVM classloader. Adding setters (setLabel) or mutable counters (transitionCount++) means one user's request silently mutates the enum constant for every other user in the system.
- **Race Conditions & Memory Leaks:** Unsynchronized writes to transitionCount and unbounded growth in private static final List<String> AUDIT_LOG cause concurrency bugs and memory leaks in long-running applications.
- **Violates Single Responsibility (God Enum):** Mixing domain states (PAID) with infrastructure concerns (sending emails or writing audit logs) makes the enum impossible to unit test without triggering side effects.
- **Misleading Inner Class (StatusTracker):** Nesting a stateful StatusTracker class inside OrderStatusBad implies it tracks individual enum transitions automatically, when in reality it is just an unrelated mutable class awkwardly glued onto the enum's namespace.

How to refactor this cleanly:

- **Keep Enum Fields private final:** Only store immutable metadata (such as private final String label;) initialized via the constructor.
- **Move Business & I/O Logic to a Service:** Extract processOrderAndNotify into a dedicated OrderWorkflowService class that accepts OrderStatus as a parameter.
-  **Move StatusTracker to Its Own File:** Make StatusTracker a separate class in the same package rather than nesting it inside the enum.


### 4\. Execution fall-through in a switch statement

There are many different ways to handle logic in a Java switch statement. There is a classic switch, like in ANSI C, which it is influenced by. And there is a new switch statement with a `"functional"` touch -> the result of the switch statement can be directly assigned to a variable with the type of the result. This is sometimes confusing. So my first proposal is to use the same kind of switch statement throughout the application so development stays clean and straightforward.

The point with the original switch is that the break statement is necessary to get the awaited continuation. To use case statements without break, I implemented grouping values, for example, weekends and weekdays. Here is a positive example: 


```java
int day = 2; // 1 = Monday, 7 = Sunday

switch (day) {
    case 1:
    case 2: // Matches here and intentionally falls through...
    case 3:
    case 4:
    case 5: // ...all the way down to the shared weekday logic!
        System.out.println("It is a weekday. Time to work!");
        break;
    case 6: // Matches Saturday and falls through to Sunday
    case 7:
        System.out.println("It is the weekend. Time to relax!");
        break;
    default:
        System.out.println("Invalid day number.");
        break;
}
// Output:
// It is a weekday. Time to work!
```

The advantage of this logic can also lead to the disadvantage of a forgotten break. This makes the construction dangerous and was one reason to introduce the new switch statement; see below.
But first, a failing logic to see the disadvantage:

```java
String userRole = "VIEWER";
boolean canEditContent = false;
boolean canViewContent = false;

switch (userRole) {
    case "VIEWER":
        canViewContent = true;
        // BUG: Forgot to add 'break;' here! Execution falls straight through...
    case "EDITOR":
        canEditContent = true; // ...and accidentally grants edit permissions to a Viewer!
        break;
    case "ADMIN":
        canViewContent = true;
        canEditContent = true;
        break;
    default:
        System.out.println("Unknown role");
        break;
}

System.out.println("Can View: " + canViewContent); // true
System.out.println("Can Edit: " + canEditContent); // true (WRONG! Should be false)
```

And now our weekdays example with the new switch logic:


```java

int day = 2; // 1 = Monday, 7 = Sunday

switch (day) {
    case 1, 2, 3, 4, 5 -> System.out.println("It is a weekday. Time to work!");
    case 6, 7 -> System.out.println("It is the weekend. Time to relax!");
    default -> System.out.println("Invalid day number.");
}
// Output:
// It is a weekday. Time to work!

```

And a simple example which also shows that the switch can be used in an assignment and which shows the new keyword `yield`, working like a break but in addition returns the value: 

```java
public record AccessPolicy(boolean canRead, boolean canWrite, boolean canDelete, String reason) {}

public class AuthEvaluator {

    public static AccessPolicy evaluateAccess(String role, boolean isMfaVerified, boolean isOwner) {
        return switch (role) {
            case "GUEST" -> new AccessPolicy(true, false, false, "Public read-only access.");

            case "VIEWER", "AUDITOR" -> new AccessPolicy(true, false, false, "Verified read-only role.");

            case "CONTRIBUTOR" -> {
                // Multi-line block requires 'yield' to return the AccessPolicy value
                if (!isOwner) {
                    yield new AccessPolicy(true, false, false, "Contributors can only edit their own resources.");
                }
                yield new AccessPolicy(true, true, false, "Owner edit access granted.");
            }

            case "ADMIN", "SUPER_ADMIN" -> {
                // Using 'yield' after a multi-step security check
                if (!isMfaVerified) {
                    System.out.println("Security Alert: Admin attempted access without MFA.");
                    yield new AccessPolicy(true, false, false, "Downgraded to read-only: MFA required.");
                }
                yield new AccessPolicy(true, true, true, "Full administrative access granted.");
            }

            default -> new AccessPolicy(false, false, false, "Access denied: Unrecognized role.");
        };
    }

    public static void main(String[] args) {
        AccessPolicy policy = evaluateAccess("ADMIN", false, false);
        System.out.println(policy);
        // Output: AccessPolicy[canRead=true, canWrite=false, canDelete=false, reason=Downgraded to read-only: MFA required.]
    }
}
```

In these examples, the progress is clear. It started with the classic switch, where continuation in a switch/case depends on the programmer setting the correct break statements so that execution fall-through occurs only intentionally.

In early versions, switch in Java supported only integral types like int and char. Over the years, enums and Strings, and later other objects, have been supported. 
The logic of the modernized switch, in an LTS version, was introduced with Java 17. The reasons were clear. A switch with break statements as essential triggers for continuation is not easy to handle. Good code quality is not easy to achieve with it.
With the new version, the compiler implicitly inserts break statements, and grouping is easy by providing multiple values in a switch case.

```java
public class DayChecker {

    public enum Day {
        MONDAY,
        TUESDAY,
        WEDNESDAY,
        THURSDAY,
        FRIDAY,
        SATURDAY,
        SUNDAY
    }

    public static String checkDayByNumber(int day) {
        return switch (day) {
            case 1, 2, 3, 4, 5 -> "It is a weekday. Time to work!";
            case 6, 7 -> "It is the weekend. Time to relax!";
            default -> "Invalid day number.";
        };
    }

    public static String checkDayByEnum(Day day) {
        return switch (day) {
            case MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY -> "It is a weekday. Time to work!";
            case SATURDAY, SUNDAY -> "It is the weekend. Time to relax!";
        };
    }

    public static void main(String[] args) {
        String messageFromInt = checkDayByNumber(2);
        String messageFromEnum = checkDayByEnum(Day.TUESDAY);

        System.out.println("From int:  " + messageFromInt);
        System.out.println("From enum: " + messageFromEnum);
    }
}
```
Here, in this well-known example, the advantages are clear. First, it uses less code for the same thing, and the break is implicit. The fact that you can pass a list of values, as well as a single value, allows grouping. The flow of control is clear. Another advantage is that you can easily assign the result to a variable. Instead of one assignment with the old switch, it looks like:

```java
int day = 2; // 1 = Monday, 7 = Sunday
String message;

switch (day) {
    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
        message = "It is a weekday. Time to work!";
        break;
    case 6:
    case 7:
        message = "It is the weekend. Time to relax!";
        break;
    default:
        message = "Invalid day number.";
        break;
}

System.out.println(message);
// Output:
// It is a weekday. Time to work!
``` 
So, to avoid pitfalls, I strongly recommend that if you use Java 17+, you also use the new switch, and if you use Java 8, avoid fall-through whenever you can.

### 5\. Wrong or too much use of `continue`and `break`:

Another thing that is not valuable for a clean design is the usage of `break` and `continue` in places where it is not necessary, or, like a `break` in an inner loop with a label to the outer loop:

```java
 int target = 99;

        outerLoop: // Label attached to the outer loop
        for (int row = 0; row < matrix.length; row++) {
            for (int col = 0; col < matrix[row].length; col++) {
                System.out.println("Checking [" + row + "][" + col + "] = " + matrix[row][col]);

                if (matrix[row][col] == target) {
                    System.out.println("Target " + target + " found! Exiting both loops.");
                    break outerLoop; // Exits the outer loop immediately, skipping row 2 completely
                }
            }
        }
```
This is a poor design because it is nearly as confusing as a GOTO in BASIC. If you need this for your logic, better redesign it into an extracted helper method like:

```java

public record Position(int row, int col) {}

    public static Optional<Position> findTarget(int[][] matrix, int target) {
        for (int row = 0; row < matrix.length; row++) {
            for (int col = 0; col < matrix[row].length; col++) {
                System.out.println("Checking [" + row + "][" + col + "] = " + matrix[row][col]);

                if (matrix[row][col] == target) {
                    System.out.println("Target " + target + " found! Exiting cleanly.");
                    return Optional.of(new Position(row, col)); // Exits both loops and returns the result
                }
            }
        }
        return Optional.empty();
    }

````

Or, if you like to avoid nested loops and make it more functional style, use the `stream-interface` like here:

```java
 public static Optional<Position> findTarget(int[][] matrix, int target) {
        return IntStream.range(0, matrix.length)
                .boxed()
                .flatMap(row -> IntStream.range(0, matrix[row].length)
                        .filter(col -> matrix[row][col] == target)
                        .mapToObj(col -> new Position(row, col)))
                .findFirst(); // Short-circuits immediately on the first match
    }
```
Another statement that can cause trouble if used is `continue` or both `continue` and `break` in the same logic, like here:

----- will be continued soon ----- 
**NOTE:** Copyright statement
- Harald Glab-Plhak
- Computer Science since 1992
- &copy; Harald Glab-Plhak 2026


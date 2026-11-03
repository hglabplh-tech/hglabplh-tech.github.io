- [GoTo Top](../index.html)
- [GoTo Index](./index.html)


# Technical design check supporting Domain Driven Design and defensive programming

This feature is a technical check for clean code that is nearly free of side effects and other issues that make clean code impossible, such as too many method/function parameters, missing type checking and hints, overly deep class nesting, and more.

The idea is to get clean, clear interfaces to the application logic and library functions. 

The checks differ across language paradigms. For example, the object-oriented paradigm is different from the functional paradigm. Here are some examples of useful checks:

# YATestEnvironment — Design Quality Rules

The following tables consolidate the design rules we discussed for Java, Clojure, Scala, Kotlin, and Python. They include object-oriented, functional, mixed-paradigm, defensive-programming, and technical architecture rules that support Domain-Driven Design (DDD).

#### 1\. Object-Oriented Design Rules

| Rule | Description | Default |
|--------|--------|--------|
| `OOP.NESTED_SELF_SUBTYPE` | Nested type extends or implements its enclosing type | Warning |
| `OOP.MAX_NESTING_DEPTH` | More than two levels of nested types | Warning |
| `OOP.PUBLIC_NESTED_IMPLEMENTATION` | Public implementation class nested in an API interface or class | Recommendation |
| `OOP.NESTED_OUTER_COUPLING` | Nested class accesses excessive state of its enclosing instance | Warning |
| `OOP.NESTED_OUTER_MUTATION` | Nested class modifies state of its enclosing instance | Warning |
| `OOP.PREFER_STATIC_NESTED_CLASS` | Non-static inner class does not require an enclosing instance | Warning |
| `OOP.PREFER_TOP_LEVEL_CLASS` | Independently reusable nested class should be top-level | Recommendation |
| `OOP.PREFER_FINAL_CLASS` | Class is inheritable without an explicit extension requirement | Recommendation |
| `OOP.PREFER_FINAL_FIELDS` | Fields are mutable without an identified need | Warning |
| `OOP.AVOID_PUBLIC_SETTERS` | Public setters expose unnecessary mutable state | Warning |
| `OOP.EXTERNAL_API_ABSTRACTION` | External API depends directly on implementations instead of suitable abstractions | Warning |
| `OOP.PREFER_COMPOSITION` | Inheritance is used where composition would provide clearer separation | Recommendation |
| `OOP.MAX_INHERITANCE_DEPTH` | Inheritance hierarchy exceeds three levels | Warning |
| `OOP.IMMUTABLE_VALUE_OBJECT` | Value object contains mutable state or exposes mutable data | Warning |
| `OOP.BUILDER_PATTERN` | Complex object construction should use a builder, factory, or parameter object | Recommendation |

#### 2\. Functional Programming Rules

| Rule | Description | Default |
|--------|--------|--------|
| `FP.MAX_FUNCTION_ARGUMENTS` | More than two function-valued parameters or excessive callback dependencies | Warning |
| `FP.PREFER_PURITY` | Domain function has undeclared or unnecessary side effects | Warning |
| `FP.CALL_DEPTH` | Configured business workflow exceeds three nested call levels | Warning |
| `FP.MAX_CALLBACK_DEPTH` | Callback chain exceeds two nested levels | Warning |
| `FP.CALLBACK_REENTRY` | Callback re-enters an earlier function, creating difficult-to-follow execution | Warning |
| `FP.TAIL_RECURSION` | Non-tail recursion could be replaced with tail recursion or iteration | Recommendation |
| `FP.MUTUAL_RECURSION` | Functions form potentially problematic recursive call cycles | Warning |
| `FP.PREFER_IMMUTABLE_COLLECTIONS` | Mutable collections are used without a justified requirement | Warning |
| `FP.RETURN_NEW_VALUES` | Function mutates input data instead of returning a new value | Warning |
| `FP.CONTROLLED_STATE` | Atoms, refs, agents, or other mutable state are used outside designated boundaries | Warning |
| `FP.EFFECT_BOUNDARIES` | I/O or external effects occur inside designated pure domain logic | Error |
| `FP.DETERMINISTIC_FUNCTIONS` | Function violates an explicitly declared determinism contract | Warning |
| `FP.LAZY_SEQUENCE_EFFECTS` | Side effects inside lazy operations may execute at unexpected times | Warning |
| `FP.AVOID_UNNECESSARY_MACROS` | Macro is used where an ordinary function would suffice | Recommendation |
| `FP.EXCESSIVE_DESTRUCTURING` | Complex destructuring hides too many dependencies or parameters | Recommendation |

#### 3\. Common and Mixed-Paradigm Rules

| Rule | Description | Default |
|--------|--------|--------|
| `COMMON.MAX_PARAMETERS` | Function, method, or constructor has more than five parameters | Warning |
| `COMMON.PUBLIC_CONTRACTS` | Public API lacks sufficient input or return type contracts | Warning |
| `COMMON.TYPE_SAFETY` | Unnecessarily broad or untyped parameters reduce type safety | Warning |
| `COMMON.MAX_FUNCTION_LENGTH` | Function exceeds 30 logical lines | Recommendation |
| `COMMON.CYCLOMATIC_COMPLEXITY` | Cyclomatic complexity exceeds 10 | Warning |
| `COMMON.FUNCTION_COHESION` | Function performs unrelated responsibilities | Recommendation |
| `COMMON.IMMUTABILITY` | Unnecessary mutable state exists in a value-oriented component | Warning |
| `COMMON.EXPLICIT_DEPENDENCIES` | Function or class relies on hidden global dependencies | Warning |
| `COMMON.CONTRACT_VALIDATION` | Declared constraints are not validated where enforcement is required | Warning |
| `COMMON.CUSTOM_PREDICATES` | Configured custom predicate or schema constraint is violated | Configurable |

#### 4\. Architecture and DDD-Supporting Technical Rules

| Rule | Description | Default |
|--------|--------|--------|
| `ARCH.NO_CYCLIC_DEPENDENCIES` | Cyclic dependencies exist between modules or namespaces | Error |
| `ARCH.EXTERNAL_CALLS_VIA_CONTRACT` | External caller bypasses a declared API contract | Error |
| `ARCH.NO_INTERNAL_PACKAGE_ACCESS` | External modules access internal implementation packages | Error |
| `ARCH.API_CONTRACT_COVERAGE` | Declared external API is missing required contracts | Warning |
| `ARCH.NAMESPACE_COUPLING` | Excessive dependencies between namespaces or modules | Warning |
| `ARCH.LAYER_BOUNDARIES` | Dependencies violate configured architectural layer boundaries | Error |
| `DDD.BOUNDED_CONTEXT_BOUNDARIES` | Technical dependencies cross configured bounded-context boundaries improperly | Warning |
| `DDD.AGGREGATE_ENCAPSULATION` | External code bypasses declared aggregate access boundaries | Warning |
| `DDD.DOMAIN_INFRASTRUCTURE_SEPARATION` | Domain logic depends directly on infrastructure implementations | Warning |
| `DDD.DOMAIN_INVARIANT_CONTRACTS` | Declared domain invariants lack required validation or tests | Warning |

These DDD-related rules check technical properties that can support a domain-driven architecture. They do not independently establish whether the domain model is conceptually correct.

#### 5\. Defensive Programming Rules

| Rule | Description | Default |
|--------|--------|--------|
| `DEF.INPUT_VALIDATION` | External inputs lack required validation | Warning |
| `DEF.NULL_SAFETY` | Nullable values are used without adequate handling | Warning |
| `DEF.ERROR_HANDLING` | Errors are ignored, swallowed, or handled inconsistently | Warning |
| `DEF.FAIL_FAST` | Invalid states are not rejected at designated boundaries | Recommendation |
| `DEF.RESOURCE_MANAGEMENT` | Resources may not be closed or released correctly | Warning |
| `DEF.MUTABLE_ARGUMENTS` | Method modifies caller-owned mutable arguments unexpectedly | Warning |
| `DEF.DEFENSIVE_COPIES` | Mutable internal data is exposed without defensive copying | Warning |
| `DEF.THREAD_SAFETY` | Shared mutable state lacks adequate synchronization or confinement | Warning |
| `DEF.HIDDEN_SIDE_EFFECTS` | Method performs effects not declared by its contract | Warning |

#### 6\. Analysis requirements

| Analysis method | Applicable checks |
|--------|--------|
| Reflection | Types, modifiers, visibility, parameter counts, interfaces |
| AST / source analysis | Recursion, nesting, macros, source-level type declarations |
| ASM / bytecode analysis | Field access, outer-instance coupling, method dependencies, mutation |
| Runtime spy | Observed call depth, callback execution, state changes |
| Prismatic Schema / Active Data | Type constraints, predicates, contract validation |
| Dependency graph | Cycles, module boundaries, coupling, architecture |
| Test execution | Behavioral contracts, invariants, immutability, deterministic behavior |

**Important\:** All these rules should be configurable by the architect or development team. Their default severities are proposed starting values, not universal coding standards. Rules that cannot be reliably verified from the available evidence should return `UNKNOWN` rather than incorrectly reporting success or failure.

In addition, some rules will be checked via real function calls with a spy to observe behavior, call count, and nesting in a real context. This leads to a better weight of the attribute tested and to a more expressive result:

#### The feature will initially look like

- YATestEnvironment — Runtime Behavior Analysis

Collect runtime observations per test scenario and evaluate them against configured expectations.

| Observation | What to collect | Evaluation criteria and possible findings |
|---|---|---|
| Call count | Calls per function and per scenario | Identify unexpected repetition, redundant work, or violations of configured call limits. |
| Parameter values | Arguments at entry and relevant changes to mutable arguments | Record actual input usage, boundary cases, and unexpected mutation. |
| Recursion | Call path, depth, repeated arguments, and termination outcome | Identify direct or mutual recursion, lack of progress toward a base case, failure to terminate for the tested input, and excessive depth. Evaluate compliance with the side-effect contract. Record tail recursion separately; it is not required for every correct recursive function. |
| Valid parameters | Returned values, exceptions, state changes, and external calls | Check whether the function fulfills its contract for the valid inputs exercised. |
| Invalid parameters | Rejection point, exception or error result, and effects before rejection | Check whether invalid input is handled as required, including whether rejection occurs before prohibited effects. |
| Calls to other packages | Target package, frequency, call path, and architectural boundary crossed | Identify excessive interaction or violations of configured package boundaries. Measure calls per operation or scenario, such as repository calls during one checkout. |
| Distinct package dependencies | Number and identity of distinct packages called per function or scenario | Identify broad coupling. Evaluate separately from call frequency, using context and configurable limits. |
| Test inputs and expected outcomes | Valid and invalid inputs supplied by the test runner, with expected results and effects | The spy observes execution; the test runner supplies inputs and checks expected outcomes. Combine both sources to evaluate behavior. |
| Finding evidence | Scenario, input, observed execution, expected constraint, and evidence source | Produce concrete findings, such as: With an invalid quantity of −1, `placeOrder` called the payment package twice before rejecting the input. Expected: reject the input before making any payment calls. |

All thresholds and expectations are configurable. Runtime findings apply to the scenarios and inputs exercised; a successful observation does not establish correctness for untested inputs, branches, or concurrent execution. One main challenge is defining rules for the spy functionality to capture the results of specific behaviors for a test. There has to be a rule for every time one test spies on a behavior subset. 


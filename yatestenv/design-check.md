- [GoTo Top](../index.html)
- [GoTo Index](./index.html)


# Technical design check supporting Domain-Driven Design and defensive programming

This feature is a technical check for clean code that is nearly free of side effects and other issues that make clean code impossible, such as too many method/function parameters, missing type checking and hints, overly deep class nesting, and more.

The goal is clean, clear interfaces to application logic and library functions. 

The checks differ across language paradigms. For example, the object-oriented paradigm is different from the functional paradigm. Here are some examples of useful checks:

# YATestEnvironment — Design Quality Rules

The following tables consolidate the design rules we discussed for Java, Clojure, Scala, Kotlin, and Python. They include object-oriented, functional, mixed-paradigm, defensive-programming, and technical architecture rules that support Domain-Driven Design (DDD).
# Design and Code Quality Catalog

Updated: 8 November 2026

This catalog covers object-oriented, functional, architectural, and defensive design checks, with language-specific guidance for Java, Kotlin, and Scala. Language-specific constructs from other ecosystems remain applicable only where supported.

## Interpretation and configuration

- **Recommendation:** a design-review candidate requiring contextual judgment.
- **Warning:** a likely problem supported by evidence.
- **Error:** a violation of an explicitly configured boundary or contract.
- **Configurable:** severity is supplied by project policy.

Thresholds are configurable defaults. Findings must identify the applicable language, compiler version, platform, project policy, and evidence where these affect the result. Do not apply a rule to an unsupported construct or treat a compiler error as an additional design finding.

## 1. Object-Oriented Programming Rules

| Rule | Description | Default |
|---|---|---|
| `OOP.NESTED_SELF_SUBTYPE` | Nested type extends or implements its enclosing type without an intentional variant or extension role. Exempt justified sealed hierarchies, algebraic data types, and compiler-generated enum cases. | Warning |
| `OOP.MAX_NESTING_DEPTH` | More than two levels of nested types. | Warning |
| `OOP.PUBLIC_NESTED_IMPLEMENTATION` | Public implementation class nested in an API interface or class without an intentional public role. | Recommendation |
| `OOP.NESTED_OUTER_COUPLING` | Nested class accesses excessive state of its enclosing instance. | Warning |
| `OOP.NESTED_OUTER_MUTATION` | Nested class modifies state of its enclosing instance. | Warning |
| `OOP.PREFER_STATIC_NESTED_CLASS` | Nested class requires an enclosing instance without an identified need; apply the language-specific treatment below. | Warning |
| `OOP.PREFER_TOP_LEVEL_CLASS` | Independently reusable nested class should be top-level when nesting provides no justified ownership, namespace, or type-safety benefit. | Recommendation |
| `OOP.ENUM_NESTED_TYPE_COHESION` | Class nested in an enum or its associated companion has responsibilities unrelated to the enum's values, behavior, or closely associated representation. | Recommendation |
| `OOP.ANNOTATION_NESTED_IMPLEMENTATION` | Class nested in an annotation, or in its associated companion where supported, declares application or business logic or serves as an independently managed bean without a direct supporting role for the annotation. | Recommendation |
| `OOP.RECORD_NESTED_TYPE_COHESION` | Class nested in a Java record has responsibilities unrelated to constructing, validating, interpreting, or representing the record's data. | Recommendation |
| `OOP.DATA_TYPE_NESTED_COHESION` | Class nested in a Kotlin data class or Scala case class, or its associated companion, has responsibilities unrelated to the enclosing data model. | Recommendation |
| `OOP.COMPANION_COHESION` | Kotlin companion object or Scala companion object contains responsibilities unrelated to its associated type, such as an independent service or application workflow. | Recommendation |
| `OOP.PREFER_FINAL_CLASS` | Class is inheritable without an explicit extension requirement. | Recommendation |
| `OOP.PREFER_FINAL_FIELDS` | Fields are mutable without an identified need. | Warning |
| `OOP.AVOID_PUBLIC_SETTERS` | Public setters expose unnecessary mutable state. | Warning |
| `OOP.EXTERNAL_API_ABSTRACTION` | External API depends directly on implementations instead of suitable abstractions. | Warning |
| `OOP.PREFER_COMPOSITION` | Inheritance is used where composition would provide clearer separation. | Recommendation |
| `OOP.MAX_INHERITANCE_DEPTH` | Inheritance hierarchy exceeds three levels. | Warning |
| `OOP.IMMUTABLE_VALUE_OBJECT` | Value object contains mutable state or exposes mutable data. | Warning |
| `OOP.BUILDER_PATTERN` | Complex object construction should use a builder, factory, or parameter object. | Recommendation |

### 1.1 Cohesion and justified nesting

Nesting alone is not a violation. Evaluate responsibilities, consumers, dependencies, visibility, lifecycle, and the intended domain model. The presence of methods, public visibility, or lack of access to enclosing state does not by itself prove that a nested type is misplaced.

Allow directly associated helpers, builders, factories, validators, parsers, serializers, deserializers, and representation types. Their placement must be justified by their relationship to the enclosing type. JSON support is one valid example, not the only valid exception.

An independently managed bean is a review signal, not an automatic violation. Determine whether its lifecycle and responsibility belong to the enclosing type. Honor documented exceptions and configured framework conventions.

### 1.2 Java enums, annotations, and records

- **Enums:** allow helpers supporting enum values and behavior. Do not flag enum constants with class bodies merely because they contain logic.
- **Annotations:** allow directly associated validation and metadata support. Member classes declared in annotation interfaces are implicitly public and static; assess intentional API exposure, and do not recommend adding `static` to an already implicitly static declaration.
- **Records:** allow related construction, validation, and representation helpers. Records are final: a nested class cannot subclass its enclosing record or add record components to it. Use composition, such as a wrapper or DTO, to combine a record with additional data.

Language basis: [Java classes, enums, and records](https://docs.oracle.com/javase/specs/jls/se26/html/jls-8.html), [Java interface member types](https://docs.oracle.com/javase/specs/jls/se24/html/jls-9.html#jls-9.5).

### 1.3 Kotlin adaptations

- Ordinary nested classes do not require an outer instance. For `OOP.PREFER_STATIC_NESTED_CLASS`, recommend removing unnecessary `inner`; Kotlin does not use Java's `static` modifier for this purpose.
- Apply enum cohesion checks to helpers in an `enum class` and its companion. Allow behavior implemented by enum entries.
- Apply data-type cohesion checks to helpers in data classes and their companions. A data class can contain a nested class even though the data class itself cannot be declared `inner`.
- Companion factories and directly related support are legitimate. A companion can also intentionally implement an interface; that alone is not a violation.
- Apply annotation-related checks only to declarations supported by the target compiler. Do not assume that Java annotation nesting rules carry over to Kotlin. Compiler-rejected declarations should receive the compiler diagnostic, not another design finding.
- Allow nested implementations that intentionally represent variants of a sealed class or interface. Do not warn solely because they implement their enclosing type.
- Classes are final by default. Apply `OOP.PREFER_FINAL_CLASS` only where inheritance is actually enabled, accounting for configured compiler plugins and framework requirements.
- Data classes do not guarantee deep immutability. `val` prevents property reassignment but does not make referenced objects immutable; generated `copy()` is shallow.

Language basis: [Nested and inner classes](https://kotlinlang.org/docs/nested-classes.html), [Enum classes](https://kotlinlang.org/docs/enum-classes.html), [Data classes](https://kotlinlang.org/docs/data-classes.html), [Companion objects](https://kotlinlang.org/docs/object-declarations.html), [Sealed hierarchies](https://kotlinlang.org/docs/sealed-classes.html), [Declaration specification](https://kotlinlang.org/spec/declarations.html).

### 1.4 Scala adaptations

- Inner classes can intentionally provide path-dependent types tied to an enclosing instance. This can prevent mixing values from different owners. Preserve that guarantee when assessing outer-instance coupling or relocation.
- Scala does not use Java's `static` nested-class modifier. For `OOP.PREFER_STATIC_NESTED_CLASS`, assess relocation to a companion or top level only after checking instance-dependent semantics; do not offer an automatic modifier replacement.
- Scala companions are idiomatic locations for factories, extractors, related helper types, and associated type-class instances, including appropriate `given` definitions. Logic in a companion is not inherently a problem.
- Apply data-type cohesion checks to case classes and their companions. Case classes do not guarantee deep immutability: assess mutable properties and referenced mutable objects separately.
- Apply native enum checks to Scala 3 enums and their companions. Scala 2 enumeration patterns require separate recognition; do not assume native Scala 3 syntax or semantics.
- Allow intentional sealed variants and algebraic data types. Compiler-generated enum cases and subtype relationships must not trigger nesting or self-subtype findings.
- Scala annotation classes differ from Java annotation interfaces. Allow implementation required by the supported annotation or macro mechanism; assess unrelated application responsibilities separately.

Language basis: [Inner classes and path-dependent types](https://docs.scala-lang.org/tour/inner-classes.html), [Companion objects](https://docs.scala-lang.org/tour/singleton-objects.html), [Case classes](https://docs.scala-lang.org/tour/case-classes.html), [Scala 3 enums](https://docs.scala-lang.org/scala3/reference/enums/enums.html), [Algebraic data types](https://docs.scala-lang.org/scala3/reference/enums/adts.html), [Enum translation](https://docs.scala-lang.org/scala3/reference/enums/desugarEnums.html).

### 1.5 Intentional nested variants

For example, these Kotlin declarations intentionally group the variants of `Result` and must not trigger `OOP.NESTED_SELF_SUBTYPE` merely for implementing their enclosing interface:

```kotlin
sealed interface Result {
    data class Success(val value: String) : Result
    data class Failure(val message: String) : Result
}
```

## 2. Functional Programming Rules

| Rule | Description | Default |
|---|---|---|
| `FP.MAX_FUNCTION_ARGUMENTS` | More than two function-valued parameters or excessive callback dependencies. | Warning |
| `FP.PREFER_PURITY` | Domain function has undeclared or unnecessary side effects. | Warning |
| `FP.CALL_DEPTH` | Configured business workflow exceeds three nested call levels. | Warning |
| `FP.MAX_CALLBACK_DEPTH` | Callback chain exceeds two nested levels. | Warning |
| `FP.CALLBACK_REENTRY` | Callback re-enters an earlier function, creating difficult-to-follow execution. | Warning |
| `FP.TAIL_RECURSION` | Non-tail recursion could be replaced with tail recursion or iteration. | Recommendation |
| `FP.MUTUAL_RECURSION` | Functions form potentially problematic recursive call cycles. | Warning |
| `FP.PREFER_IMMUTABLE_COLLECTIONS` | Mutable collections are used without a justified requirement. | Warning |
| `FP.RETURN_NEW_VALUES` | Function mutates input data instead of returning a new value. | Warning |
| `FP.CONTROLLED_STATE` | Atoms, refs, agents, or other mutable state are used outside designated boundaries. | Warning |
| `FP.EFFECT_BOUNDARIES` | I/O or external effects occur inside designated pure domain logic. | Error |
| `FP.DETERMINISTIC_FUNCTIONS` | Function violates an explicitly declared determinism contract. | Warning |
| `FP.LAZY_SEQUENCE_EFFECTS` | Side effects inside lazy operations may execute at unexpected times. | Warning |
| `FP.AVOID_UNNECESSARY_MACROS` | Macro is used where an ordinary function would suffice. | Recommendation |
| `FP.EXCESSIVE_DESTRUCTURING` | Complex destructuring hides too many dependencies or parameters. | Recommendation |

Apply language-specific rules only where their constructs exist. Tail recursion recommendations must account for compiler and runtime support; do not assume tail-call optimization. Do not equate Kotlin read-only collection interfaces with guaranteed immutable storage. Distinguish executing an effect from constructing a value that describes a deferred effect.

## 3. Common and Mixed-Paradigm Rules

| Rule | Description | Default |
|---|---|---|
| `COMMON.MAX_PARAMETERS` | Function, method, or constructor has more than five parameters. | Warning |
| `COMMON.PUBLIC_CONTRACTS` | Public API lacks sufficient input or return type contracts. | Warning |
| `COMMON.TYPE_SAFETY` | Unnecessarily broad or untyped parameters reduce type safety. | Warning |
| `COMMON.MAX_FUNCTION_LENGTH` | Function exceeds 30 logical lines. | Recommendation |
| `COMMON.CYCLOMATIC_COMPLEXITY` | Cyclomatic complexity exceeds 10. | Warning |
| `COMMON.FUNCTION_COHESION` | Function performs unrelated responsibilities. | Recommendation |
| `COMMON.IMMUTABILITY` | Unnecessary mutable state exists in a value-oriented component. | Warning |
| `COMMON.EXPLICIT_DEPENDENCIES` | Function or class relies on hidden global dependencies. | Warning |
| `COMMON.CONTRACT_VALIDATION` | Declared constraints are not validated where enforcement is required. | Warning |
| `COMMON.CUSTOM_PREDICATES` | Configured custom predicate or schema constraint is violated. | Configurable |

Recognize contracts already expressed by the language's type system. Do not require redundant annotations or runtime validation when the required constraint is already enforced at the relevant boundary.

## 4. Architecture and DDD-Supporting Technical Rules

| Rule | Description | Default |
|---|---|---|
| `ARCH.NO_CYCLIC_DEPENDENCIES` | Cyclic dependencies exist between modules or namespaces. | Error |
| `ARCH.EXTERNAL_CALLS_VIA_CONTRACT` | External caller bypasses a declared API contract. | Error |
| `ARCH.NO_INTERNAL_PACKAGE_ACCESS` | External modules access internal implementation packages. | Error |
| `ARCH.API_CONTRACT_COVERAGE` | Declared external API is missing required contracts. | Warning |
| `ARCH.NAMESPACE_COUPLING` | Excessive dependencies between namespaces or modules. | Warning |
| `ARCH.LAYER_BOUNDARIES` | Dependencies violate configured architectural layer boundaries. | Error |
| `DDD.BOUNDED_CONTEXT_BOUNDARIES` | Technical dependencies cross configured bounded-context boundaries improperly. | Warning |
| `DDD.AGGREGATE_ENCAPSULATION` | External code bypasses declared aggregate access boundaries. | Warning |
| `DDD.DOMAIN_INFRASTRUCTURE_SEPARATION` | Domain logic depends directly on infrastructure implementations. | Warning |
| `DDD.DOMAIN_INVARIANT_CONTRACTS` | Declared domain invariants lack required validation or tests. | Warning |

These DDD-related rules check technical properties that can support a domain-driven architecture. They do not independently establish whether the domain model is conceptually correct. Define architectural dependency direction and module boundaries explicitly rather than inferring them solely from package names.

## 5. Defensive Programming Rules

| Rule | Description | Default |
|---|---|---|
| `DEF.INPUT_VALIDATION` | External inputs lack required validation. | Warning |
| `DEF.NULL_SAFETY` | Nullable values are used without adequate handling. | Warning |
| `DEF.ERROR_HANDLING` | Errors are ignored, swallowed, or handled inconsistently. | Warning |
| `DEF.FAIL_FAST` | Invalid states are not rejected at designated boundaries. | Recommendation |
| `DEF.RESOURCE_MANAGEMENT` | Resources may not be closed or released correctly. | Warning |
| `DEF.MUTABLE_ARGUMENTS` | Method modifies caller-owned mutable arguments unexpectedly. | Warning |
| `DEF.DEFENSIVE_COPIES` | Mutable internal data is exposed without defensive copying. | Warning |
| `DEF.THREAD_SAFETY` | Shared mutable state lacks adequate synchronization or confinement. | Warning |
| `DEF.HIDDEN_SIDE_EFFECTS` | Method performs effects not declared by its contract. | Warning |

## 6. Analysis Requirements

| Analysis method | Applicable checks and limitations |
|---|---|
| Reflection | Types, modifiers, visibility, parameter counts, interfaces, and available runtime annotations. Reflection alone cannot recover all source-level intent. |
| AST / source analysis | Recursion, nesting, macros where supported, source declarations, framework annotations, and candidate responsibility violations. Use the target language's parser and semantic model. |
| Compiler semantic information | Resolved symbols, types, companion relationships, sealed variants, instance-dependent types, and generated declarations. Use compiler-compatible tooling, such as Scala TASTy inspection where appropriate. |
| ASM / JVM bytecode analysis | Field access, outer-instance coupling, method dependencies, mutation, and compiled relationships on JVM targets. Map generated constructs back to source before reporting. |
| Runtime spy | Observed call depth, callback execution, and state changes. Results apply to observed executions. |
| Prismatic Schema / Active Data | Type constraints, predicates, and contract validation in projects that use these tools. |
| Dependency graph | Cycles, module boundaries, coupling, architecture, and consumers of nested types and companion members. |
| Test execution | Behavioral contracts, invariants, immutability, and deterministic behavior within tested scenarios. |
| Design review / configured policy | Conceptual cohesion, independent responsibility, justified nesting, framework conventions, and documented exceptions. |

Distinguish proven violations from heuristic recommendations. Bytecode transformations and generated artifacts must not create duplicate source findings. JVM bytecode analysis does not cover Kotlin or Scala targets that do not produce JVM bytecode.

## 7. Finding Deduplication

### 7.1 General policy

Emit one finding for the same underlying problem when the proposed correction is substantially the same. A shared source location alone does not make findings duplicates.

Each consolidated finding contains:

- One primary rule ID.
- Related rule IDs as supporting information.
- Combined evidence and affected locations.
- One explanation and suggested correction.
- The highest configured severity among the applicable rules describing that same problem.

Choose the most specific rule as primary. If specificity is equal, prefer an explicit configured contract over a general design preference. If still tied, use a documented, stable project rule order so reports remain deterministic.

Keep separate findings when they describe independent problems requiring different corrections. Apply justified exceptions before grouping findings; an exempt rule must not increase a group's severity.

### 7.2 Overlap handling

| Overlapping rules | Reporting behavior |
|---|---|
| Enum, annotation, record, or data-type cohesion rule + `OOP.PREFER_TOP_LEVEL_CLASS` | Use the enclosing-type-specific rule as primary for the same misplaced class. |
| Enum, annotation, or data-type cohesion rule + `OOP.COMPANION_COHESION` | Use the enclosing-type-specific rule as primary for the same misplaced helper or responsibility. Use companion cohesion for unrelated companion responsibilities not covered more specifically. |
| `OOP.COMPANION_COHESION` + `OOP.PREFER_TOP_LEVEL_CLASS` | Use companion cohesion as primary when both concern the same nested component and correction. |
| Specific nesting or companion cohesion rule + `OOP.PUBLIC_NESTED_IMPLEMENTATION` | Consolidate when both concern exposing the same misplaced implementation. Keep public exposure separate if it remains an independent issue after placement is resolved. |
| `OOP.NESTED_OUTER_MUTATION` + `OOP.NESTED_OUTER_COUPLING` | Use mutation as primary when the same writes are the sole evidence of excessive coupling. Keep excessive reads separate only when independently justified. |
| `OOP.IMMUTABLE_VALUE_OBJECT` + `COMMON.IMMUTABILITY` | Use the value-object rule as primary for the same mutable state. |
| `OOP.IMMUTABLE_VALUE_OBJECT` + `OOP.PREFER_FINAL_FIELDS` | Consolidate when both concern the same unnecessary field reassignment. Keep distinct exposed mutable contents separate when they require a different correction. |
| `DEF.DEFENSIVE_COPIES` + immutability rules | Use defensive copying as primary when the same exposure of mutable data causes all findings. |
| `DEF.MUTABLE_ARGUMENTS` + `FP.RETURN_NEW_VALUES` | Use unexpected mutation of caller-owned data as primary for the same mutation. |
| `FP.EFFECT_BOUNDARIES` + `FP.PREFER_PURITY` + `DEF.HIDDEN_SIDE_EFFECTS` | Use the explicit effect-boundary violation as primary for the same effect. Otherwise choose the most specific applicable contract or purity rule. |
| `DEF.INPUT_VALIDATION` + `COMMON.CONTRACT_VALIDATION` + `DEF.FAIL_FAST` | Consolidate the same missing boundary check. Use contract validation for a declared constraint; otherwise use input validation for external inputs. |
| `DDD.DOMAIN_INVARIANT_CONTRACTS` + general validation rules | Use the domain-invariant rule as primary for the same declared invariant and missing enforcement. |
| `ARCH.API_CONTRACT_COVERAGE` + `COMMON.PUBLIC_CONTRACTS` | Use the architecture rule as primary for the same missing contract on a declared external API. |
| Architecture boundary rules + DDD boundary rules | Consolidate the same dependency violating the same boundary. Use the most specific declared boundary as primary. |
| Multiple analysis methods detect the same violation | Merge their evidence; do not emit separate source, bytecode, and runtime findings. |
| Compiler-generated declarations or translated enum cases | Attribute evidence to the originating source declaration where applicable. Do not report generated copies as separate design violations. |

For example, excessive nesting and unexpected mutation can remain separate findings because they describe different problems. An unrelated helper inside an enum companion should receive one enum-cohesion finding, with companion cohesion and top-level placement attached as related rules where applicable.

## 8. Reporting and Review

Each finding should state what was detected, why it matters in this project, the evidence, and the smallest useful correction. For heuristic cohesion findings, explain the suspected responsibility mismatch rather than presenting conceptual intent as proven.

Support documented suppressions with reasons. Preserve meaningful language idioms, domain variants, instance-dependent type guarantees, and declared framework requirements. The goal is actionable findings without repeated reports of the same underlying issue.

**NOTE:** Copyright statement
- Harald Glab-Plhak
- Computer Science since 1992
- &copy; Harald Glab-Plhak 2026


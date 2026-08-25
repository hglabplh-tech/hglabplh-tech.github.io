# HGPPascal Features

This document describes the first supported feature set for HGPPascal. It is a
living compatibility map: features listed as implemented are covered by the
current lexer, parser, AST, and at least one backend.

## Status Legend

- Implemented: available in the current compiler.
- Partial: parsed or represented, but not complete across all backends.
- Planned: intended for Turbo Pascal compatibility, but not implemented yet.

## Compiler Pipeline

| Feature | Status | Notes |
| --- | --- | --- |
| Pascal lexer | Implemented | Handles identifiers, numbers, strings, comments, symbols, and keywords. |
| Recursive descent parser | Implemented | Produces an AST for the supported Pascal subset. |
| AST-based backend dispatch | Implemented | Targets are selected through the backend registry. |
| CLI target selection | Implemented | `--target c`, `--target pcode`, `--target jvm`, bytecode aliases, `native-m3`, and `native-x86_64`. |
| Debug symbol tables | Implemented | Each backend receives and can emit a compiler symbol table. |
| Runtime call table | Implemented | Built-ins and user routines are represented in one call table. |
| Object call spaces | Implemented | Each object type has its own method call table for later dispatch and optimization passes. |
| Visitor traversal layer | Implemented | `hgppascal.ast.visitor` supports backend-independent AST walks and future optimizer passes. |
| Split descriptors | Implemented | Module, type, callable, closure, runtime, debug, and profile descriptors are separated by responsibility. |
| SECD runtime shape | Implemented | `hgppascal.runtime.secd` models Stack, Environment, Control, and Dump for future closure/VM execution. |
| Numeric runtime engine | Implemented | `hgppascal.runtime.numeric` provides shared arithmetic and mathematical operations for SECD/SSTD and backend runtimes. |
| Heap runtime engine | Implemented | `hgppascal.runtime.heap` manages heap handles, allocated values, records/aggregates, field access, live tracking, and free checks. |
| Optional backend optimization triple | Implemented | `:backend-optimizations` or `--backend-optimizations` enables register allocation, instruction scheduling, then peephole optimization in that fixed order. |
| Test runner | Implemented | Uses `clojure -M:test`. |
| Example compilation coverage | Implemented | Every checked-in example compiles through C, P-Code, and JVM in tests; native backends are covered by GCC build-plan tests. |

## Language Front End

| Feature | Status | Notes |
| --- | --- | --- |
| `program` header | Implemented | Program name is used by the JVM class backend. |
| `uses` clause | Implemented | Programs and units can import built-in runtime units or source-backed project units. |
| `unit` declarations | Implemented | Pascal `unit ... interface ... implementation ... end.` is parsed and linked. |
| Unit interface section | Implemented | Public const/type/var declarations and routine signatures are represented. |
| Unit implementation section | Implemented | Routine bodies, private declarations, and initialization statements are linked into consumers. |
| `const` declarations | Implemented | Constants are emitted by C, P-Code, and JVM backends. |
| `type` declarations | Partial | Alias-like declarations are parsed; deeper semantic handling is planned. |
| `var` declarations | Implemented | Scalars and simple arrays are supported. |
| Record declarations | Implemented | `record ... end` with named fields. |
| Object declarations | Implemented | Turbo Pascal 5.5-style `object ... end` with fields and method signatures. |
| Pointer declarations | Implemented | Turbo Pascal-style `^Type` typed pointers. |
| Compound statements | Implemented | `begin ... end`. |
| Assignment | Implemented | Scalar variables, function return assignment, and array elements. |
| Record field selection | Implemented | `value.field`. |
| Pointer dereference | Implemented | `pointer^` and chained forms like `pointer^.field`. |
| Address-of | Implemented | `@value` for pointer assignment. |
| Procedure calls | Implemented | User routines and supported built-ins. |
| Function calls | Implemented | Value parameters and returned expressions. |
| Function type aliases | Implemented | Pascal-style function values such as `type IntUnary = function(x: integer): integer;`. |
| Lambda expressions | Implemented | Anonymous `function(...): type capture ... begin Result := ... end` expressions. |
| Higher-order function values | Implemented | Function-typed variables and parameters can store, pass, and invoke closures. |
| Method implementations | Implemented | Qualified method bodies such as `procedure Counter.Init(...)`. |
| Method calls | Implemented | Instance calls such as `counter.Init(1)` and `counter.Current()`. |
| `Self` pointer | Implemented | Method bodies receive `Self` as an implicit typed pointer, so `Self^.field` works. |
| Object symbol spaces | Implemented | Each object type has a symbol space containing `Self`, fields, methods, and method calls. |
| Value parameters | Implemented | Procedures and functions accept value parameters. |
| `var` parameters | Partial | Parsed, but backends intentionally reject them for now. |

## Types

| Type | Status | Notes |
| --- | --- | --- |
| `integer` | Implemented | C `int`, JVM `int`, P-Code integer stack values. |
| `real` | Implemented | C `double`, JVM `double`, P-Code real values. |
| `boolean` | Implemented | Boolean literals and boolean operations. |
| `char` | Partial | Type is represented; literal syntax and library support need expansion. |
| `string` | Implemented | Pascal string literals with doubled quote escaping. |
| `string[n]` | Partial | Parsed and emitted by C/P-Code; JVM currently maps strings to `String`. |
| `array[low..high] of type` | Implemented | Pascal lower bounds are preserved through index adjustment. |
| `record ... end` | Implemented | C structs, JVM nested classes, and P-Code record metadata. |
| `object ... end` | Implemented | Record-like storage plus method signatures and backend method metadata. |
| `^Type` | Implemented | Typed pointer support for records and scalar-compatible targets. |
| `function(...): Type` | Implemented | Function-valued type aliases for higher-order values; current backend closure slice supports integer parameters/captures/returns. |
| `nil` | Implemented | Pointer nil literal. |

## Expressions And Operators

| Feature | Status | Notes |
| --- | --- | --- |
| Numeric literals | Implemented | Integer, real, and exponent forms. |
| String literals | Implemented | Single-quoted Pascal strings with doubled quotes. |
| Boolean literals | Implemented | `true` and `false`. |
| Arithmetic operators | Implemented | `+`, `-`, `*`, `/`, `div`, `mod`. |
| Runtime math functions | Implemented | `sqrt`, `sqr`, `pow`/`power`, `abs`, `sin`, `cos`, `tan`, `atan`/`arctan`, `ln`/`log`, `log10`, `exp`, `floor`, `ceil`, `round`, `trunc`, `min`, and `max`. |
| Boolean operators | Implemented | `and`, `or`, `not`. |
| Comparison operators | Implemented | `=`, `<>`, `<`, `<=`, `>`, `>=`. |
| Address operator | Implemented | `@` returns an address/reference value. |
| Pointer dereference operator | Implemented | Postfix `^` in designators. |
| Parenthesized expressions | Implemented | Standard expression grouping. |
| Array indexing | Implemented | Supports one or more parsed indexes where the backend supports arrays. |
| Lambda expressions | Implemented | Pascal-like anonymous functions with explicit capture lists and `Result` return assignment. |
| Function-valued calls | Implemented | Calls through function variables lower to backend closure invocation. |
| Operator precedence metadata | Implemented | AST nodes carry shared precedence values. |
| Numeric tower | Implemented | Shared integer/real promotion rules for backend typing. |

## Statements

| Statement | Status | Notes |
| --- | --- | --- |
| `if ... then ... else` | Implemented | Optional `else`. |
| `while ... do` | Implemented | Emits loops in all current backends. |
| `repeat ... until` | Implemented | Emits post-tested loops. |
| `for ... to ... do` | Implemented | Inclusive Pascal loop semantics. |
| `for ... downto ... do` | Implemented | Inclusive descending loops. |
| Empty statement | Implemented | Accepted where Pascal permits an empty statement. |

## Built-In Procedures

| Built-In | Status | Notes |
| --- | --- | --- |
| `write` | Implemented | C `printf`, JVM `System.out.print`, P-Code `SYS WRITE`. |
| `writeln` | Implemented | C `printf`, JVM `System.out.println`, P-Code `SYS WRITELN`. |
| `readln` | Implemented | C `scanf`, JVM `Scanner`, P-Code `SYS READLN`. |
| `inc` | Implemented | One- or two-argument forms. |
| `dec` | Implemented | One- or two-argument forms. |
| `new` | Implemented | Allocates a typed pointer target where supported. |
| `dispose` | Implemented | Clears/frees a typed pointer target where supported. |
| `halt` | Implemented | Process/runtime exit behavior per backend. |
| Numeric functions | Implemented | Runtime numeric functions are represented in the call table and callable from SECD/SSTD. |

## Backends

| Backend | Status | Output | Notes |
| --- | --- | --- | --- |
| C | Implemented | C99 source | `--target c`; output can be compiled with `cc` or `gcc`. |
| Pascal P-Code | Implemented | Textual stack-machine IR | `--target pcode`; documented in `docs/P_CODE.md`. |
| JVM / Java bytecode | Implemented | `.class` files | `--target jvm`, `bytecode`, `java-bytecode`, or `jvm-bytecode`; documented in `docs/JVM_BACKEND.md`. |
| Apple M3 / arm64 native | Implemented | Native executable via C and GCC | `--target native-m3`, `m3`, `arm64`, or `native-arm64`; pipeline is lexer/parser/AST to C, then GCC. |
| x86_64 native | Implemented | Native executable via C and GCC | `--target native-x86_64`, `x86_64`, `x64`, or `amd64`; pipeline is lexer/parser/AST to C, then GCC. |

## Runtime And Debug Metadata

| Feature | Status | Notes |
| --- | --- | --- |
| C debug symbols | Implemented | Generated C includes an HGPPascal symbol-table comment. |
| P-Code debug symbols | Implemented | Generated P-Code includes symbol-table comments. |
| JVM debug symbols | Implemented | Generated Java source includes symbol-table comments and the result map carries metadata. |
| Backend register allocation | Implemented | Optional first backend optimization pass; C uses virtual C-local allocation, JVM uses local-slot/operand-stack planning, and P-Code uses virtual stack slots. |
| Backend instruction scheduling | Implemented | Optional second backend optimization pass with backend-specific barriers for calls, I/O, environment switching, and SECD/SSTD tags. |
| Backend peephole optimization | Implemented | Optional final pass; C/JVM expose stable hooks and comments, while P-Code also performs conservative stack identity arithmetic simplification. |
| Backend optimization metadata | Implemented | JVM output carries `:optimization-plan`; C/JVM source and P-Code can emit pass trace comments when the option is enabled. |
| Native executable build plans | Implemented | Native backends return generated C, architecture metadata, executable path, and the exact GCC command. |
| Native GCC pipeline | Implemented | CLI native targets write generated C and invoke GCC-compatible compilers with M3/arm64 or x86_64 flags. |
| Pure Java JVM runtime | Implemented | JVM output contains `HGPRuntime`, written as generated Java. |
| Java bytecode aliases | Implemented | The JVM `.class` backend is reachable through bytecode target names and Clojure helper APIs. |
| Runtime call table | Implemented | JVM output embeds runtime/user call metadata. |
| Method call table entries | Implemented | User methods are recorded as `method-procedure` or `method-function`. |
| Object-scoped call tables | Implemented | `program-call-spaces` exposes per-object method call tables with explicit `Self`, source arity, and dispatch arity metadata. |
| Clojure interface functions | Implemented | See `hgppascal.interface` for compile, symbol, and call-table helpers. |
| Method environment switching | Implemented | C and JVM method wrappers call `StoreEnvironment`, method body, then `RestoreEnvironment`; JVM uses a `ThreadLocal` stack. |
| Functional closure runtime | Implemented | C and JVM emit closure values with captured environment maps; JVM runtime is pure generated Java. |
| SSTD functional context | Implemented | Functional calls have explicit Stack/Environment/Call/Dump frame structures in generated runtimes and P-Code tags. |
| SSTD procedure/lambda calls | Implemented | `SSTD_CALL`, `SSTD_CALL_LAMBDA`, one-argument curry/apply, and restore-with-value semantics are represented in the SECD runtime and P-Code. |
| SECD numeric calls | Implemented | `SSTD_NUMERIC` dispatches into the numeric compute engine and pushes the result onto the SECD stack. |
| SECD heap operations | Implemented | `HEAP_ALLOC`, `HEAP_ALLOC_RECORD`, `HEAP_LOAD`, `HEAP_STORE`, `HEAP_LOAD_FIELD`, `HEAP_STORE_FIELD`, and `HEAP_FREE` operate on the SECD heap. |
| P-Code functional tags | Implemented | `MAKE_CLOSURE`, `CAPTURE`, `APPLY`, `SSTD_ENTER`, and `SSTD_LEAVE` represent closure creation and invocation. |
| P-Code runtime block | Implemented | `RUNTIME_BLOCK hgppascal_runtime` advertises SECD, SSTD, NUMERIC, and HEAP engines for executable embedding. |
| Linked runtime executables | Implemented | C, JVM, and native executable outputs carry linked SECD/SSTD/NUMERIC/HEAP runtime support; native GCC links the generated C runtime into the executable. |
| C heap runtime | Implemented | Generated C uses `HGPHeapAlloc`, `HGPHeapFree`, live-count metadata, and heap object headers for `new`/`dispose`. |
| JVM heap runtime | Implemented | Generated Java runtime has a `HEAP` object table, heap IDs on `Ref<T>`, live checks on dereference, and heap-backed `allocate`/`dispose`. |
| P-Code heap tags | Implemented | `HEAP_ALLOC`, `HEAP_FREE`, `HEAP_LOAD`, and `HEAP_STORE` advertise heap behavior to P-Code executable hosts. |
| Unit resolver | Implemented | CLI compilation resolves `uses` files beside the main source; API compilation can pass `:unit-sources`. |
| Unit metadata | Implemented | Linked declarations carry `:unit` and `:visibility` in symbol and call metadata. |
| Descriptor builder | Implemented | Builds module/type/callable/closure/runtime descriptors from resolved ASTs. |
| Debug descriptor hooks | Implemented | Source locations, breakpoints, step mode, and pause checks are represented. |
| Profiling hooks | Implemented | Counters, events, and a simple cost model are available for optimizer and runtime work. |
| Language profiles | Implemented | `:turbo-pascal-55` and `:tp55plus` feature profiles separate compatibility from research extensions. |
| Backend capability contracts | Implemented | C, JVM, and P-Code expose backend-specific debug, profiling, SECD, and descriptor strategies. |
| Research pass catalog | Implemented | Backend-aware candidate passes and feature vectors are produced by the analysis pipeline. |

## Example Coverage

| Example | Covered Features |
| --- | --- |
| `hello.pas` | Program structure, variables, `for`, `writeln`. |
| `control_flow.pas` | Loops, conditionals, `inc`, `dec`, `repeat ... until`. |
| `record_fields.pas` | Record declarations and field selectors. |
| `record_pointer.pas` | Typed pointer alias, address-of, dereference, and `nil`. |
| `pointer_new_dispose.pas` | `new`, `dispose`, pointer nil checks, runtime allocation. |
| `precedence_numeric_tower.pas` | Precedence metadata and integer/real promotion. |
| `runtime_calls.pas` | Built-in runtime procedure lowering. |
| `numeric_runtime.pas` | Numeric compute engine, `sqrt`, `pow`, `round`, `mod`, and linked runtime metadata. |
| `function_call_table.pas` | User-defined functions and call-table metadata. |
| `object_methods.pas` | Object declarations, `Self^`, method implementations, and method calls. |
| `higher_order_lambda.pas` | Function type alias, lambda capture, closure assignment, and higher-order invocation. |
| `unit_uses_demo.pas` | Source-backed `uses`, linked unit functions, and unit initialization. |

## Test Coverage

The test suite covers:

- Lexer handling for comments, strings, and range tokens.
- Parser AST shape for programs, units, arrays, records, objects, pointers, function types, lambda captures, nil, address-of, `Self^`, method calls, and precedence metadata.
- C, P-Code, and JVM output for units, routines, arrays, records, objects, pointers, runtime calls, numeric runtime calls, method environment switching, functional closures, and debug symbols.
- SECD/SSTD numeric execution, one-argument procedure/lambda currying, environment restore, and return-value stack behavior.
- Optional backend optimization order, metadata, CLI/API surface, and P-Code peephole behavior.
- Native M3/arm64 and x86_64 executable build-plan shape, target aliases, architecture flags, and public interface helpers.
- Clojure interface helpers for backend targets, compilation, analysis, symbol tables, flat call tables, and object-scoped call tables.
- Compilation of all checked-in examples through every backend.

## Command Line

```sh
clojure -M:run examples/hello.pas --target c -o out/hello.c
clojure -M:run examples/hello.pas --target pcode -o out/hello.pcode
clojure -M:run examples/hello.pas --target jvm -o out/classes
clojure -M:run examples/record_pointer.pas --target jvm -o out/classes
clojure -M:run examples/pointer_new_dispose.pas --target jvm -o out/classes
clojure -M:run examples/object_methods.pas --target jvm -o out/classes
clojure -M:run examples/higher_order_lambda.pas --target jvm -o out/classes
clojure -M:run examples/numeric_runtime.pas --target native-m3 -o out/numeric-runtime-m3
clojure -M:run examples/unit_uses_demo.pas --target jvm -o out/classes
clojure -M:run examples/hello.pas --target pcode --backend-optimizations -o out/hello.opt.pcode
clojure -M:run examples/hello.pas --target c --backend-optimization-passes register-allocation,peephole -o out/hello.opt.c
clojure -M:run examples/hello.pas --target native-m3 -o out/hello-m3
clojure -M:run examples/hello.pas --target native-x86_64 -o out/hello-x86_64
```

Run tests:

```sh
clojure -M:test
```

## Planned Turbo Pascal Compatibility

| Feature Area | Status | Notes |
| --- | --- | --- |
| Unit finalization | Planned | `finalization` sections and teardown ordering. |
| Advanced records | Planned | Variant records, packed records, and deeper layout controls. |
| Sets | Planned | Pascal set syntax and operations. |
| Enumerations | Planned | Named ordinal values. |
| Subranges | Planned | Range-constrained ordinal types. |
| Advanced pointers | Planned | Untyped pointer arithmetic and fuller low-level compatibility behavior. |
| Fuller procedure variables | Planned | The current closure slice covers integer function values; procedure values, broader signatures, and richer captures are planned. |
| Files | Planned | Typed and untyped file support. |
| `case` statement | Planned | Multi-branch selection. |
| `with` statement | Planned | Record field scope shorthand. |
| Labels and `goto` | Planned | Needed for historical Turbo Pascal compatibility. |
| CRT/DOS/System units | Planned | Compatibility libraries without Borland-owned code. |
| Better diagnostics | Planned | Source ranges, error recovery, and semantic warnings. |

## Compatibility Note

HGPPascal is an independent implementation. Turbo Pascal and Borland names are
used only to describe compatibility goals. The project does not include
Borland source code, manuals, binaries, or copyrighted assets.

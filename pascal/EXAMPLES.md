# HGPPascal Examples

The `examples/` directory contains small programs that exercise the currently
implemented compiler features across the C, P-Code, JVM, and native GCC-backed
build-plan paths.

| Example | Purpose |
| --- | --- |
| `hello.pas` | Minimal program, `for` loop, `writeln`. |
| `control_flow.pas` | `for`, `if`, `repeat`, `inc`, `dec`. |
| `record_fields.pas` | Record declarations and field access. |
| `record_pointer.pas` | Typed pointer assignment with `@`, dereference with `^`, and `nil` checks. |
| `pointer_new_dispose.pas` | Heap-backed `new`, `dispose`, record allocation, pointer dereference, and nil-after-dispose behavior. |
| `precedence_numeric_tower.pas` | Operator precedence and integer/real numeric promotion. |
| `runtime_calls.pas` | Built-in runtime calls: `write`, `writeln`, `inc`, and `dec`. |
| `numeric_runtime.pas` | SECD/SSTD-linked numeric runtime: `sqrt`, `pow`, `round`, and `mod`. |
| `function_call_table.pas` | User-defined functions and call-table metadata. |
| `object_methods.pas` | Turbo Pascal 5.5-style `object`, `Self^`, qualified method bodies, and method calls. |
| `higher_order_lambda.pas` | Function type alias, lambda capture, closure assignment, and higher-order invocation. |
| `unit_uses_demo.pas` | `uses MathUtil`, linked unit routines, and unit initialization. |

`MathUtil.pas` is a supporting unit source for `unit_uses_demo.pas`; it is not
compiled as a standalone program.

The automated test suite compiles every file in this list through C, P-Code,
and JVM. The JVM backend also invokes the JDK compiler and checks for the
expected main `.class` file. Native executable tests validate the M3/arm64 and
x86_64 GCC build plans without requiring a local cross compiler.

Compile any example to C:

```sh
clojure -M:run examples/record_fields.pas --target c -o out/record_fields.c
```

Compile any example to P-Code:

```sh
clojure -M:run examples/object_methods.pas --target pcode -o out/object_methods.pcode
```

Compile any example to JVM classes:

```sh
clojure -M:run examples/function_call_table.pas --target jvm -o out/classes
java -cp out/classes FunctionCallTable

clojure -M:run examples/object_methods.pas --target jvm -o out/classes
java -cp out/classes ObjectMethods

clojure -M:run examples/higher_order_lambda.pas --target jvm -o out/classes
java -cp out/classes HigherOrderLambda

clojure -M:run examples/unit_uses_demo.pas --target jvm -o out/classes
java -cp out/classes UnitUsesDemo
```

Build a native executable through generated C and GCC:

```sh
clojure -M:run examples/hello.pas --target native-m3 -o out/hello-m3
clojure -M:run examples/hello.pas --target native-x86_64 -o out/hello-x86_64
clojure -M:run examples/hello.pas --target native-m3 --native-source out/hello-m3.c -o out/hello-m3
clojure -M:run examples/numeric_runtime.pas --target native-m3 -o out/numeric-runtime-m3
```

Run all example coverage:

```sh
clojure -M:test
```

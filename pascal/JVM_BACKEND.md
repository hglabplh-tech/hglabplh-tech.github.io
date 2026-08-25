# HGPPascal JVM Backend

HGPPascal can generate JVM `.class` files with the `jvm` backend.

```sh
clojure -M:run examples/hello.pas --target jvm -o out/classes
java -cp out/classes Hello
```

The same backend is available through explicit bytecode target aliases:
`bytecode`, `java-bytecode`, and `jvm-bytecode`.

The backend lowers the Pascal AST to Java source internally, compiles that
source with `javax.tools.JavaCompiler`, and writes the resulting `.class`
bytes. This keeps the backend dependency-free while producing real JVM class
files.

## Current Mapping

- Pascal `program` becomes one public final JVM class.
- Program-level variables become static fields.
- Pascal procedures and functions become static methods.
- Turbo Pascal 5.5-style object methods become static methods with an implicit
  `HGPRuntime.Ref<T> self` parameter.
- Pascal `integer`, `real`, `boolean`, `char`, and `string` map to Java
  `int`, `double`, `boolean`, `char`, and `String`.
- Pascal arrays map to Java arrays, with Pascal lower bounds subtracted at each
  indexed access.
- Pascal records map to generated nested Java classes.
- Pascal objects map to generated nested Java classes plus method wrappers.
- Pascal typed pointers map to `HGPRuntime.Ref<T>`.
- Pascal function-valued type aliases map to `HGPRuntime.FunctionValue`.
- Pascal lambda expressions lower to generated static helper methods and
  captured `FunctionValue` instances.
- `readln`, `write`, `writeln`, `new`, `dispose`, pointer nil checks, and
  `halt` are handled by the generated pure Java `HGPRuntime`.
- `inc` and `dec` map to JVM-friendly Java statements.

## Runtime

Every generated JVM class includes a nested `HGPRuntime` class. It contains:

- `Ref<T>` for typed Pascal pointer values.
- Pointer helpers for address, dereference, allocation, and disposal.
- Heap helpers with a `HEAP` table, `HeapObject` metadata, heap IDs on
  `Ref<T>`, and live checks before dereference of heap-backed references.
- `isNil` for Pascal `nil` comparisons against typed pointers.
- `StoreEnvironment` and `RestoreEnvironment` for object-method environment
  switching. The environment stack is stored in a `ThreadLocal`, so parallel
  generated-program executions do not share class/object environment state.
- Console I/O helpers backed by Java standard library classes.
- Numeric compute helpers for `sqrt`, `sqr`, `pow`, `abs`, trigonometric,
  logarithmic, rounding, `div`, and `mod`-style runtime calls.
- A runtime call table containing built-ins and user-defined routines.
- Object-scoped call tables in the backend result metadata. Each object space
  contains the implicit typed `Self` pointer plus method call entries, so later
  optimizer passes can reason about object dispatch without reparsing names.
- `FunctionValue`, `FunctionCode`, and `SSTDFrame` for higher-order function
  values. Lambda calls store captured variables in a Java map and use a
  `ThreadLocal` SSTD dump stack, so functional invocation context is isolated
  per thread.
- One-argument lambda currying through `callLambdaOne`; when the arity is
  satisfied, the runtime rebuilds the callee environment, restores the caller
  frame from the dump, and returns the stack value.

The backend result map includes runtime metadata:

```clojure
{:runtime {:linked? true
           :engines [:secd :sstd :numeric :heap]
           :carrier :generated-java}}
```

## Example Programs

These examples specifically exercise the JVM runtime layer:

```sh
clojure -M:run examples/record_pointer.pas --target jvm -o out/classes
java -cp out/classes RecordPointer

clojure -M:run examples/pointer_new_dispose.pas --target jvm -o out/classes
java -cp out/classes PointerNewDispose

clojure -M:run examples/object_methods.pas --target jvm -o out/classes
java -cp out/classes ObjectMethods

clojure -M:run examples/object_methods.pas --target java-bytecode -o out/classes
java -cp out/classes ObjectMethods

clojure -M:run examples/higher_order_lambda.pas --target jvm -o out/classes
java -cp out/classes HigherOrderLambda
```

The test suite also compiles every example program through the JVM backend and
checks that the expected main `.class` file is produced.

## Limits

The JVM backend supports the same front-end subset as the C and P-Code
backends. By-reference parameters are parsed but not implemented yet for JVM
output. The first higher-order closure slice supports integer parameters,
integer captures, and integer return values; the runtime shape is intentionally
general enough to widen later.

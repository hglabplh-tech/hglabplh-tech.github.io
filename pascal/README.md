
- [GoTo Top](../index.html)
- [GoTo Index](./index.html)
- [GoTo Next](./features.html)

# HGPPascal

HGPPascal is a small Pascal compiler written in Clojure. It currently compiles
a Turbo Pascal-style subset into portable C99, textual Pascal P-Code, or JVM
`.class` files, and can build native M3/arm64 or x86_64 executables through
generated C and GCC.

The project is designed as a GitHub-ready starting point for a larger
Turbo Pascal-compatible compiler, with a real lexer, parser, AST, code
generators, runnable examples, tests, CI, and a legal notice separating
compatibility work from any Borland-owned material.

## Current Compiler Features

See `FEATURES.md` for the fuller feature matrix and compatibility roadmap.
See `docs/ARCHITECTURE.md` for the SECD/Visitor/Descriptor direction.
See `docs/BACKEND_STANDARDS.md` for C, JVM, and P-Code debug/profile contracts.

- Program headers, `uses` clauses, `unit`/`interface`/`implementation`, `const`, `var`, `begin ... end.`
- Integer, real, boolean, string, simple array, record, object, and pointer declarations
- Assignments, procedure/function calls, compound statements
- `if ... then ... else`, `while`, `repeat ... until`, and `for ... to/downto`
- Pascal comments: `{ ... }`, `(* ... *)`, and `// ...`
- Pascal strings with doubled quote escaping
- Record fields, typed pointers, `nil`, `@`, and pointer dereference with `^`
- Turbo Pascal 5.5-style `object` types with fields, methods, `Self^`, and method calls
- Function-valued type aliases, lambda expressions with `capture`, and higher-order calls
- Visitor-based analysis, split descriptors, SECD runtime shape, and debug/profile hooks
- SECD/SSTD-linked numeric runtime with `sqrt`, `pow`, `round`, `mod`, trigonometric, logarithmic, and rounding functions
- Runtime heap management for allocated variables, records, aggregates, handles, dereference checks, and `new`/`dispose`
- Optional backend register allocation, instruction scheduling, and peephole optimization for C, P-Code, and JVM
- Native executable build targets for Apple M3/arm64 and x86_64 through the C backend and GCC
- Operators: `+`, `-`, `*`, `/`, `div`, `mod`, `and`, `or`, `not`, comparisons
- Built-ins: `write`, `writeln`, `readln`, `inc`, `dec`, `new`, `dispose`, `halt`
- Procedures and functions with value parameters

## Turbo Pascal Compatibility Roadmap

- Unit finalization and fuller standard unit compatibility
- Full type system: sets, enumerations, subranges, packed types, and fuller pointer modes
- `case`, `with`, `goto`, labels, packed types, file types
- Fuller procedure variables, broader closure signatures, and by-reference parameter behavior
- Standard CRT/DOS/System compatibility layers
- Better semantic analysis and diagnostics
- Native back ends in addition to C99 output

## Usage

Compile Pascal to C:

```sh
clojure -M:run examples/hello.pas -o out/hello.c
```

Then compile the generated C with your system compiler:

```sh
cc out/hello.c -o out/hello
./out/hello
```

Generate Pascal P-Code:

```sh
clojure -M:run examples/hello.pas --target pcode -o out/hello.pcode
```

The P-Code format is documented in `docs/P_CODE.md`. It uses a readable
stack-machine IR plus explicit HGPPascal extensions for runtime services,
arrays with Pascal lower bounds, and Turbo Pascal-style built-ins.

Generate JVM class files:

```sh
clojure -M:run examples/hello.pas --target jvm -o out/classes
java -cp out/classes Hello
```

The same bytecode backend is also available as `--target bytecode`,
`--target java-bytecode`, or `--target jvm-bytecode`.

The JVM backend is documented in `docs/JVM_BACKEND.md`. It generates Java as
an internal lowering step and uses the JDK compiler to produce real `.class`
files.

Compile a program that uses a source-backed Pascal unit:

```sh
clojure -M:run examples/unit_uses_demo.pas --target c -o out/unit_uses_demo.c
```

The compiler resolves `uses MathUtil;` by loading `MathUtil.pas` next to the
main source file. Programmatic callers can pass unit source strings through the
`:unit-sources` compile option.

Build a native executable through C and GCC:

```sh
clojure -M:run examples/hello.pas --target native-m3 -o out/hello-m3
clojure -M:run examples/hello.pas --target native-x86_64 -o out/hello-x86_64
clojure -M:run examples/numeric_runtime.pas --target native-m3 -o out/numeric-runtime-m3
```

The native pipeline is lexer -> parser -> AST -> unit resolver -> C code ->
GCC. On Apple platforms the generated GCC command uses `-arch arm64` for M3 and
`-arch x86_64` for x86_64. Use `--gcc <command>` to select a GCC-compatible
compiler and `--native-source out/hello.c` to keep the generated C file.

The generated C and JVM outputs include the SECD/SSTD/NUMERIC/HEAP runtime
support inside the artifact. P-Code carries a `RUNTIME_BLOCK
hgppascal_runtime` block so a future P-Code executable host can discover and
invoke the attached runtime engines.

Enable the optional backend optimization triple:

```sh
clojure -M:run examples/hello.pas --target pcode --backend-optimizations -o out/hello.opt.pcode
```

Or enable a canonical-order subset:

```sh
clojure -M:run examples/hello.pas --target c --backend-optimization-passes register-allocation,peephole -o out/hello.opt.c
```

Run the test suite:

```sh
clojure -M:test
```

Or use Leiningen:

```sh
lein test
lein run examples/hello.pas --target c -o out/hello.c
```

## Examples

See `docs/EXAMPLES.md` for the full example guide.

| Example | Feature Focus |
| --- | --- |
| `examples/hello.pas` | Basic program, loop, output |
| `examples/control_flow.pas` | `for`, `if`, `repeat`, `inc`, `dec` |
| `examples/record_fields.pas` | Record type and field access |
| `examples/record_pointer.pas` | Typed pointers, `@`, `^`, `nil` |
| `examples/pointer_new_dispose.pas` | `new`, `dispose`, nil-after-dispose |
| `examples/precedence_numeric_tower.pas` | Operator precedence and real division |
| `examples/runtime_calls.pas` | Runtime built-ins |
| `examples/function_call_table.pas` | User functions and call-table metadata |
| `examples/object_methods.pas` | Turbo Pascal 5.5-style objects, `Self^`, and method calls |
| `examples/higher_order_lambda.pas` | Function type aliases, `capture`, and higher-order lambdas |
| `examples/unit_uses_demo.pas` | `uses`, source-backed units, and unit initialization |

The test suite compiles every example through the C, P-Code, and JVM backends.

## Example

```pascal
program Hello;

var
  i: integer;

begin
  writeln('HGPPascal');
  for i := 1 to 3 do
    writeln('line ', i);
end.
```

## Trademark And Copyright

HGPPascal is independent. It aims for source compatibility with Pascal features
historically associated with Turbo Pascal, but it does not include Borland
source code, manuals, binaries, or copyrighted assets. See `NOTICE.md`.

- Harald Glab-Plhak
- Computer Science since 1992

- &copy; Harald Glab-Plhak (2026)
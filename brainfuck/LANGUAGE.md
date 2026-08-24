# MyLittleLang

MyLittleLang is a small typed language that compiles to standard Brainfuck
with wrapping 8-bit cells. Its compiler performs lexical analysis, parsing,
semantic analysis, feature analysis, tape layout, Brainfuck generation, and
transitive runtime linking.

The canonical grammar is
[`The BNF for the language`](./LANG-DEF.html). This document describes
the language semantics and the supported compiler interfaces.

## Compilation model

```text
MyLittleLang source
  → lexer
  → parser and AST
  → semantic and type analysis
  → feature analysis
  → tape layout and Brainfuck generation
  → minimal runtime dependency closure
  → Brainfuck
```

Declarations are collected globally before code generation, including
declarations written inside structured blocks. Duplicate declarations,
unknown variables, invalid indexes, incompatible types, unknown labels, and
invalid `break` statements are compile-time errors.

The generated program expects a Brainfuck implementation with wrapping 8-bit
cells, byte-oriented input and output, and sufficient tape space. Turing
completeness additionally assumes the conventional theoretically unbounded
tape model.

## Lexical rules

- Keywords and identifiers are case-sensitive.
- Identifiers begin with a letter or `_` and may subsequently contain letters,
  digits, or `_`.
- Simple statements end with `;`.
- `;;` begins a line comment. `#` remains accepted for compatibility.
- `;;;` is one statement delimiter followed by a line comment.
- String literals use double quotes and support C-style simple, octal, and
  hexadecimal byte escapes.

## Types

| Type | Runtime representation | Semantics |
| --- | --- | --- |
| `number` | one cell | unsigned 8-bit value, 0 through 255 |
| `integer` | eight cells | signed 64-bit two's complement |
| `long` | eight cells | distinct signed 64-bit compatibility type |
| `float` | four cells | IEEE-754 binary32 bit pattern |
| `double` | eight cells | IEEE-754 binary64 bit pattern |
| `string` | 64 cells by default | NUL-terminated byte string |

Integer and number arithmetic wraps to the destination width. Integer division
truncates toward zero. Division by zero currently produces zero for
`number`, `integer`, and `long`.

Mixed arithmetic follows this promotion order:

```text
integer → number → float → double
```

`long` is deliberately distinct and is not implicitly mixed with this chain.
Narrowing conversions are rejected.

## Declarations and assignment

Scalar declarations use `dcl`, followed by a type and identifier:

```mll
dcl number counter;
dcl integer total;
dcl long distance;
dcl float ratio;
dcl double precise;
dcl string name;
```

Assignments require a compatible expression:

```mll
counter = 10;
total = -125;
name = "Ada";
```

`string` uses a 64-byte buffer by default. The legacy declaration
`dcl string[20] text;` declares a scalar string with a 20-byte capacity,
including its terminating NUL.

## Arrays

Arrays are structural types. Empty brackets belong to the type, while fixed
positive dimensions follow the identifier:

```mll
dcl string[] names[3];
dcl integer[] values[10];
dcl float[] samples[4];
dcl double[][] matrix[2][5];
```

Arrays use row-major inline layout. Every reference must currently contain one
compile-time integer index for each dimension:

```mll
values[0] = 42;
matrix[1][3] = 0x1.8p+2;
```

Dynamic index expressions, partial array references, whole-array assignment,
and dynamically resized typed arrays are not implemented. The legacy numeric
form `dcl integer[4] values;` remains accepted as a one-dimensional array.

## Expressions

Operators are evaluated in this precedence order, from highest to lowest:

1. Parentheses and postfix methods
2. Power `^`, right-associative
3. Multiplication `*` and division `/`
4. Addition `+` and subtraction `-`
5. One optional comparison

Comparisons are `==`, `!=`, `<`, `<=`, `>`, and `>=`. They produce a
`number` containing `0` or `1`. Zero is false and every nonzero numeric value
is true.

Power is right-associative:

```text
a ^ b ^ c  means  a ^ (b ^ c)
```

The five arithmetic operators are available for `number`, `integer`, and
`long`. Complete floating constant expressions are evaluated by the compiler's
IEEE reference model.

## Floating-point literals

`float` is IEEE-754 binary32 and `double` is binary64. Supported source forms
include decimal fractions, decimal `e`/`E` exponents, and hexadecimal
significands with a mandatory binary `p`/`P` exponent:

```mll
dcl float small;
dcl double exact;

small = 1.25f;
exact = 0x1.921fb54442d18p+1;
```

The suffix `f` or `F` selects binary32. No suffix selects binary64. A suffix
`l` or `L` is recognized but rejected because long-double representation is
platform-dependent.

Literal conversion uses an exact mathematical value followed by direct
rounding to binary32 or binary64 with round-to-nearest, ties-to-even. The
reference model covers signed zero, normal and subnormal values, infinity,
NaN, overflow, underflow, comparisons, and `+ - * / ^`.

Variable-based Float32/Float64 arithmetic, comparisons, input/output
conversion, and their Brainfuck software-FPU emitters are not yet complete.
Such uses produce an explicit compiler error rather than approximate code.
General noninteger reference `pow` currently uses the host `libm`; correct
rounding is therefore not guaranteed for every possible halfway case.

## Strings

Strings are NUL-terminated byte sequences. Source characters are encoded as
UTF-8. Operations stop at the first NUL byte.

`.concat` constructs a checked string expression:

```mll
dcl string first;
dcl string result;

first = "Ada";
result = first.concat(" Lovelace");
```

The compiler rejects a concatenation when the destination capacity cannot
hold the proven maximum result plus its terminating NUL.

`.toNumeric` parses a decimal string in the destination's integer type:

```mll
dcl integer value;
value = "-9987".toNumeric;
```

Invalid text or overflow produces zero.

## Input and output

`in` currently accepts a string destination. It reads bytes through LF,
removes the LF, appends NUL, and drains excess input when the buffer is full:

```mll
dcl string line;
in line;
```

`out` accepts an expression. Strings are written through their first NUL;
integer types are formatted as human-readable decimal text:

```mll
out line;
out 40 + 2;
```

Floating-point input and formatted output remain part of the pending
Brainfuck software-FPU work.

## Structured control flow

### While

```mll
while condition do;
    statements
end;
```

The condition is evaluated before the first iteration and again after every
completed iteration.

### If and else

```mll
if condition then;
    statements
else;
    statements
end;
```

The `else` branch is optional.

### Break

`break;` exits the innermost lexically enclosing `while` or `if` block. A
`break` in an `if` nested inside a loop therefore exits the `if`, not the
surrounding loop. Using `break` outside both constructs is an error.

## Labels and goto

Top-level labels and jumps use these forms:

```mll
start:
label alternative:
goto start;
```

Labels and `goto` are currently restricted to the top level, and a `goto`
must terminate its basic block. When a program contains `goto`, the compiler
emits a program-counter dispatcher. Programs without `goto` receive no
dispatcher runtime.

## Direct Brainfuck and Turing completeness

The statement below embeds Brainfuck commands directly:

```mll
brainfuck ">,[>,]<[.<]";
```

Only `>`, `<`, `+`, `-`, `.`, `,`, `[`, `]`, and whitespace are accepted.
Whitespace is discarded and brackets are validated.

When normal compiled statements follow a direct block, every loop in that
block must restore its starting pointer position, allowing the compiler to
calculate a safe net displacement. A pointer-dynamic block must be the final
top-level statement and cannot be combined with the goto dispatcher.

For every Brainfuck program `P`, this terminal MyLittleLang program:

```text
brainfuck "P";
```

compiles byte-for-byte to `P`. Brainfuck with an unbounded tape is Turing
complete; consequently the full MyLittleLang language is Turing complete under
the same model. The typed subset without direct tape access remains
finite-state.

## Feature analysis and runtime linking

The compiler analyzes the typed AST before generation and records only the
features actually used. Runtime components declare their dependencies, and the
linker computes a deduplicated transitive closure.

Examples of features include `number.div`, `integer.pow`, `long.mul`,
`float32.add`, `array.address`, `io.string.input`, `goto.dispatch`, and
`tape.direct`. Unused Float, string, array, output, or goto components are not
linked automatically.

The Python API `compile_detailed()` exposes the selected feature set and linked
component names for verification.

## Calling the compiler

### Python

Compile one file and write Brainfuck to standard output:

```sh
python3 src/python/mini_compiler.py program.mll
```

Write to a selected file. `.bf` is added when the path has no extension:

```sh
python3 src/python/mini_compiler.py program.mll -o build/program
```

Compile every `*.mll` file below a directory while preserving its relative
subdirectories:

```sh
python3 src/python/mini_compiler.py -d examples -o build/examples
```

Use `-v` for compiler phases and `-h` for help:

```sh
python3 src/python/mini_compiler.py -v program.mll -o program.bf
python3 src/python/mini_compiler.py -h
```

### Java

```sh
mkdir -p build/java
javac -d build/java \
  src/main/java/io/github/hglabplh_tech/mini_bf_comp/MiniCompiler.java

java -cp build/java \
  io.github.hglabplh_tech.mini_bf_comp.MiniCompiler \
  program.mll -o program.bf
```

### Kotlin

Compile the Java core first, then:

```sh
mkdir -p build/kotlin
kotlinc \
  src/main/kotlin/io/github/hglabplh_tech/mini_bf_comp/MiniCompilerKotlin.kt \
  -classpath build/java -d build/kotlin

kotlin -classpath build/java:build/kotlin \
  io.github.hglabplh_tech.mini_bf_comp.MiniCompilerKotlin \
  program.mll -o program.bf
```

### Scala

Compile the Java core first, then:

```sh
scala run --server=false --classpath build/java \
  --main-class io.github.hglabplh_tech.mini_bf_comp.MiniCompilerScala \
  src/main/scala/io/github/hglabplh_tech/mini_bf_comp/MiniCompilerScala.scala \
  -- program.mll -o program.bf
```

### Clojure

Compile the Java core first, then:

```sh
clojure -Sdeps '{:paths ["src/main/clojure" "build/java"]}' \
  -M -m io.github.hglabplh-tech.mini-bf-comp.mini-compiler-clojure \
  program.mll -o program.bf
```

All five command-line entry points use the canonical Python compiler and share
the same options and generated output.

## Python library API

When `src/python` is on `PYTHONPATH`, source text can be compiled directly:

```python
from mini_compiler import compile_source, compile_detailed

brainfuck = compile_source(source)
details = compile_detailed(source)

print(details.features)
print(details.runtime_components)
```

The reference IEEE functions are in `src/python/ieee754.py`. They are intended
for compile-time constants and tests, not as a replacement for generated
Brainfuck runtime behavior.

## Exit status and diagnostics

The CLI returns zero after successful compilation and nonzero after an error.
Diagnostics are written to standard error. With `-v`, phase messages also go
to standard error, so standard output remains valid Brainfuck.

Common errors include:

- duplicate or unknown identifiers;
- type mismatches and unsupported narrowing conversions;
- invalid array dimensions or indexes;
- string-capacity overflow;
- invalid control-flow placement;
- unknown goto labels;
- invalid direct Brainfuck characters or brackets;
- unsupported variable floating-point runtime operations.

## Further references

- [Canonical BNF](bnf/my-little-lang.bnf)
- [Implementation-oriented language notes](LANGUAGE.md)
- [Compiler and project setup](README.md)
- [Example programs](examples/README.md)

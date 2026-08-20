# Brainfuck Fun

## Why this FUN project:

The language BrainFuck is a very minimalistic language it has only a very few 'commands':
   

## Something about the language:

Brainfuck Fun compiles the typed **MyLittleLang** language to standard
wrapping-byte Brainfuck. The language includes unsigned bytes, distinct signed
64-bit integer types, numeric arrays, C-style NUL-terminated strings,
`.concat`, string `.toNumeric`, structured control flow, and block-local
`break`. Source lines may contain `;;` comments.

Read [LANGUAGE.md](LANGUAGE.md) for the complete semantics and
[bnf/my-little-lang.bnf](bnf/my-little-lang.bnf) for the canonical BNF.

## Project layout

```text
bnf/my-little-lang.bnf canonical grammar
examples/example.mll 					   example program
examples/README.md                        guide to the whimsical examples
src/python/mini_compiler.py               canonical compiler and BF runtime generator
src/main/java/.../MiniCompiler.java       Java API and CLI
src/main/kotlin/.../MiniCompilerKotlin.kt Kotlin API and CLI
src/main/scala/.../MiniCompilerScala.scala Scala API and CLI
src/main/clojure/.../*.clj                Clojure API and CLI
```

The Python source contains the canonical lexer, parser, type checker, tape
allocator, string routines, 64-bit software arithmetic, decimal conversion,
and Brainfuck generator. The JVM-language entry points call that canonical
implementation so every language produces identical output. Set
`MY_LITTLE_LANG_PYTHON` when the Python source is not at
`src/python/mini_compiler.py`; set `PYTHON` to select a Python executable.

## Command-line interface

All five entry points accept the same options:

```text
mini-compiler [-h] [-v] [-o PATH] FILE.mll
mini-compiler [-h] [-v] [-o DIRECTORY] -d DIRECTORY
```

- `FILE.mll` compiles one file. Without `-o`, Brainfuck is written to standard
  output. With `-o` or `--out`, it is written to that path; `.bf` is appended
  when the path has no extension.
- `-d DIRECTORY` or `--directory DIRECTORY` recursively finds every `*.mll`
  file. Each source produces a same-named `.bf` file. Without `-o`, outputs are
  written beside their sources. With `-o` or `--out`, the option names an
  output directory and the input directory's relative subtree is preserved.
- A positional input file and `-d` are mutually exclusive. Exactly one input
  mode is required.
- `-v` or `--verbose` prints discovery and compilation phases to standard
  error, leaving generated Brainfuck clean.
- `-h` or `--help` prints the complete command help.

Examples:

```sh
mini-compiler examples/example.mll
mini-compiler examples/example.mll -o build/example
mini-compiler -v -d examples -o build/brainfuck
mini-compiler -h
```

## Python

```sh
python3 src/python/mini_compiler.py examples/example.mll -o example.bf
```

## Java

```sh
mkdir -p build/java
javac -d build/java \
  src/main/java/io/github/hglabplh_tech/mini_bf_comp/MiniCompiler.java

java -cp build/java \
  io.github.hglabplh_tech.mini_bf_comp.MiniCompiler \
  examples/example.mll -o example.bf
```

## Kotlin

Compile the Java entry point first:

```sh
mkdir -p build/kotlin
kotlinc \
  src/main/kotlin/io/github/hglabplh_tech/mini_bf_comp/MiniCompilerKotlin.kt \
  -classpath build/java -d build/kotlin

kotlin -classpath build/java:build/kotlin \
  io.github.hglabplh_tech.mini_bf_comp.MiniCompilerKotlin \
  examples/example.mll -o example.bf
```

## Scala

```sh
scala run --server=false --classpath build/java \
  --main-class io.github.hglabplh_tech.mini_bf_comp.MiniCompilerScala \
  src/main/scala/io/github/hglabplh_tech/mini_bf_comp/MiniCompilerScala.scala \
  -- examples/example.mll -o example.bf
```

## Clojure

```sh
clojure -Sdeps '{:paths ["src/main/clojure" "build/java"]}' \
  -M -m io.github.hglabplh-tech.mini-bf-comp.mini-compiler-clojure \
  examples/example.mll -o example.bf
```

## Notes about generated Brainfuck

The target interpreter must provide wrapping 8-bit cells, byte-oriented I/O,
and enough tape for variables and compiler temporaries. Signed 64-bit values
occupy eight little-endian cells and are manipulated by generated software
routines. As expected for an esoteric target, wide multiplication, power,
decimal parsing, and decimal output can generate large programs and run slowly.


##### (c) Harald Glab-Plhak, 2026


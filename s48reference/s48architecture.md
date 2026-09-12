- [Go top](../index.html)
- [Go index](./index.html)

# Scheme 48 Architecture

Scheme 48 is an implementation of Scheme built around a compact bytecode virtual machine and a substantial system written in Scheme itself. Richard Kelsey and Jonathan Rees developed it as both a practical programming environment and a testbed for language-implementation ideas. Its architecture is unusually instructive because the boundary between high-level language and low-level runtime is explicit: ordinary Scheme implements much of the environment, while **Pre-Scheme**, a statically typed systems dialect of Scheme, implements the virtual machine and can be translated to C.

This document presents a conceptual architecture rather than a version-specific map of every source file or VM instruction. The diagrams and pseudo-instructions are explanatory; they are not literal disassemblies.

## Contents

- [Historical lineage: Lisp to Scheme 48](#historical-lineage-lisp-to-scheme-48)
- [Core Scheme concepts](#core-scheme-concepts)
- [The Scheme 48 module system](#the-scheme-48-module-system)
- [The compiler path](#the-compiler-path)
- [The virtual machine](#the-virtual-machine)
- [Pre-Scheme and translation to native code](#pre-scheme-and-translation-to-native-code)
- [Bootstrapping the system](#bootstrapping-the-system)
- [Runtime value representation](#runtime-value-representation)
- [Garbage collection](#garbage-collection)
- [Continuations](#continuations)
- [Overall layered architecture](#overall-layered-architecture)
- [Compact program walk-through](#compact-program-walk-through)
- [Why the architecture is interesting](#why-the-architecture-is-interesting)

## Historical lineage: Lisp to Scheme 48

Scheme belongs to the Lisp family. Lisp began in the late 1950s around the work of John McCarthy and others. Over time, the family branched into systems including MacLisp, Interlisp, Common Lisp, and Scheme.

Gerald Jay Sussman and Guy L. Steele Jr. created Scheme in the 1970s. It retained Lisp's symbolic expressions, lists, and code-as-data character, but emphasized a deliberately small language built from a few composable ideas: lexical scope, first-class procedures, closures, proper tail recursion, and a precise evaluation model.

Scheme 48 is not a new language in the same sense that Scheme was a new Lisp dialect. It is primarily a **Scheme implementation and programming environment**, with its own module system, compiler, runtime, libraries, debugger, command processor, and concurrency facilities.

```text
Lisp
  │
  ├── MacLisp
  ├── Interlisp
  ├── Common Lisp
  └── other Lisp traditions
  │
  │  Sussman and Steele, 1970s
  ▼
Scheme
  │
  ├── lexical scope
  ├── first-class procedures and closures
  ├── proper tail recursion
  ├── continuations
  └── a deliberately small semantic core
       │
       ├── successive Scheme reports
       │
       ├── other implementations
       │     Chez, MIT/GNU Scheme, Gambit, Guile, ...
       │
       ▼
   Scheme 48
       │
       ├── byte-code virtual machine
       ├── module/package system
       ├── Pre-Scheme
       ├── development environment
       └── foundation for systems such as scsh
```

## Core Scheme concepts

### S-expressions and evaluation

Scheme programs use parenthesized symbolic expressions. A list in operator position normally denotes a procedure call:

```scheme
(+ 1 2)
;; => 3
```

Definitions and special forms use the same surface notation:

```scheme
(define (square x)
  (* x x))

(square 9)
;; => 81
```

The uniform syntax makes parsing comparatively small and gives macros a natural representation to transform.

### Lexical scope, first-class procedures, and closures

Procedures are ordinary values. You can pass a procedure to another procedure, return it as a result, and store it in a data structure. A closure couples executable code with the lexical environment needed by that code.

```scheme
(define (make-adder x)
  (lambda (y)
    (+ x y)))

(define add10
  (make-adder 10))

(add10 5)
;; => 15
```

Conceptually, `add10` contains both the lambda's code and a reference to an environment in which `x` is bound to `10`:

```text
make-adder called with x = 10
             │
             ▼
      ┌───────────────┐
      │ environment   │
      │ x → 10        │◄────────┐
      └───────────────┘         │
                                │
                         ┌──────┴──────┐
                         │ closure     │
                         │ code:       │
                         │ lambda (y)  │
                         │   (+ x y)   │
                         └─────────────┘
```

### Proper tail recursion

In a tail call, the caller has no work left after the callee returns. Scheme requires such calls to execute without consuming an ever-growing chain of continuation frames. A tail-recursive loop can therefore express iteration:

```scheme
(define (factorial n)
  (let loop ((n n) (acc 1))
    (if (= n 0)
        acc
        (loop (- n 1) (* n acc)))))
```

The implementation must recognize the tail position and transfer control without retaining an unnecessary caller frame.

### Dynamic data with automatic storage management

Pairs, lists, vectors, strings, records, closures, and other objects can be allocated without explicit deallocation by the programmer. This convenience depends on a precise runtime representation and a garbage collector.

## The Scheme 48 module system

Scheme's small core does not by itself prescribe how a large program should divide names and implementations. Scheme 48 supplies a module system with several related concepts:

- A **module** describes imported structures, source code, and exported interfaces.
- A **package** is an instantiated module: the environment in which the module's code is evaluated.
- A **structure** is an exported view of selected bindings in a package.
- An **interface** specifies the names, and sometimes binding types, visible through a structure.

```text
                         module description
                    ┌────────────────────────┐
 imported structures│ names visible inside   │
 ──────────────────►│ source/body            │
                    │ exported interfaces    │
                    └───────────┬────────────┘
                                │ instantiate
                                ▼
                    ┌────────────────────────┐
                    │ package                │
                    │ internal environment   │
                    │ public + private names │
                    └───────────┬────────────┘
                                │ selected view
                                ▼
                    ┌────────────────────────┐
                    │ structure              │
                    │ bindings allowed by    │
                    │ its interface          │
                    └────────────────────────┘
```

A small module can be written like this:

```scheme
(define-interface counter-interface
  (export make-counter
          counter-value
          increment-counter!))

(define-structure counters counter-interface
  (open scheme)
  (begin
    (define (make-counter initial)
      (cons 'counter initial))

    (define (counter-value counter)
      (cdr counter))

    (define (increment-counter! counter)
      (set-cdr! counter (+ 1 (cdr counter))))))
```

The implementation can contain private helpers that do not appear in `counter-interface`. Another module can `open` the `counters` structure and see only the exported bindings. Separating specification, instance, and exported view makes multiple implementations and controlled composition possible.

## The compiler path

Scheme 48 does not need to interpret each source expression directly. Its compiler turns Scheme programs into code for the Scheme 48 abstract machine. A simplified path is:

```text
Scheme source text
       │
       ▼
reader
       │
       ▼
S-expression representation
       │
       ▼
syntax and macro processing
       │
       ▼
compiler analysis and transformation
       │
       ▼
templates, constants, and VM byte code
       │
       ▼
Scheme 48 virtual machine
```

For example:

```scheme
(+ (* a b) c)
```

might be explained using pseudo-instructions like these:

```text
load a
load b
call multiply
load c
call add
return
```

These are deliberately generic, not literal Scheme 48 opcodes. Real compilation must also account for lexical-address lookup, calling conventions, arity checks, constants, closures, tail calls, exception paths, and module bindings.

Compiled procedures include code and metadata. A closure adds the captured lexical environment required by a particular procedure instance. Code that is independent of a call can therefore be shared, while captured values remain specific to each closure.

## The virtual machine

The Scheme 48 virtual machine provides the abstract machine on which compiled Scheme code runs. Its responsibilities include:

- dispatching byte-code instructions;
- performing procedure calls and returns;
- maintaining operands and continuation state;
- creating closures and other heap objects;
- implementing or invoking primitive operations;
- representing dynamic Scheme values;
- detecting and reporting exceptional conditions;
- coordinating memory allocation and garbage collection; and
- interfacing with operating-system and C-level facilities.

```text
             compiled Scheme code
                      │
                      ▼
          ┌─────────────────────────┐
          │ Scheme 48 VM            │
          │                         │
          │ instruction dispatcher  │
          │ value operations        │
          │ calls and tail calls    │
          │ continuation state      │
          │ allocation and GC       │
          │ low-level primitives    │
          └────────────┬────────────┘
                       │
                       ▼
              operating system
                 and hardware
```

The VM is a portability boundary. Most of the higher-level implementation targets one defined abstract machine; platform-specific work is concentrated below or around that boundary.

## Pre-Scheme and translation to native code

Pre-Scheme is a statically typed dialect of Scheme for systems programming. It preserves a Scheme-like way of organizing procedures and control flow while restricting dynamic features enough to translate efficiently to C. Scheme 48 uses it to implement the virtual machine.

The essential path is:

```text
Pre-Scheme source
       │
       │ type checking, specialization,
       │ representation decisions, translation
       ▼
generated C
       │
       ▼
C compiler and linker
       │
       ▼
native VM executable
```

Ordinary Scheme assumes dynamic values, automatic allocation, general closures, and runtime type discrimination. Low-level runtime code often needs machine integers, bytes, addresses, memory layouts, and predictable external calls. Pre-Scheme occupies the bridge between those worlds.

It should not be confused with the Scheme-to-bytecode path:

```text
ordinary Scheme ──► Scheme compiler ──► VM byte code ──┐
                                                       │ executed by
Pre-Scheme ───────► Pre-Scheme compiler ──► C ──► VM ─┘
```

Pre-Scheme is therefore not merely an optimization mode for an application. It is a lower-level implementation language used to construct the machine on which the application and much of Scheme 48 execute.

## Bootstrapping the system

Bootstrapping asks how a language implementation can build itself when some of its components are written in that language or a close relative.

At a high level, Scheme 48 divides the problem into two build products:

1. A native VM executable, obtained by translating the Pre-Scheme VM to C and compiling it with a host C toolchain.
2. A Scheme heap image containing compiled Scheme-level system code, libraries, and startup state.

At startup, the native VM loads or resumes the prepared image and begins executing its byte code. Once running, the Scheme-level compiler and development environment can compile or load more Scheme code.

```text
Build time
==========

 Pre-Scheme VM source             Scheme 48 system source
          │                                  │
          ▼                                  ▼
  translate to C                  compile/build heap image
          │                                  │
          ▼                                  ▼
  native VM executable                 system image
          │                                  │
          └──────────────┬───────────────────┘
                         │

Run time
========
                         ▼
              VM resumes/loads image
                         │
                         ▼
       command processor, compiler, libraries,
              debugger, and user programs
```

The exact build procedure depends on the release and host tools, but the architectural idea remains stable: a small native substrate brings up a much richer high-level system.

## Runtime value representation

At Scheme level, values have language-visible kinds:

```text
Scheme value
  ├── number
  ├── boolean
  ├── character
  ├── symbol
  ├── pair
  ├── vector
  ├── string
  ├── record
  ├── procedure/closure
  └── continuation and other runtime objects
```

The VM must encode these values in machine-level storage. A common implementation strategy, and the useful conceptual model here, divides values into:

- **immediate values**, encoded directly in a machine word with distinguishing tag bits; and
- **references to heap objects**, where a tagged value identifies an allocated object's address or descriptor.

The precise tag layout is an implementation detail and may differ by Scheme 48 version and target architecture.

For a pair:

```scheme
(cons 10 20)
```

the abstract view is:

```text
tagged Scheme value
        │
        │ refers to
        ▼
   heap pair object
  ┌───────────────┐
  │ car     │ cdr │
  ├─────────┼─────┤
  │ 10      │ 20  │
  └─────────┴─────┘
```

A closure similarly needs a code/template component and captured environment values:

```text
closure
  ├── executable template/code
  └── captured lexical values
```

The representation layer turns a seemingly uniform Scheme value into a machine word, a heap reference, or a structured runtime object.

## Garbage collection

Idiomatic Scheme creates many objects whose useful lifetimes are not obvious at compile time. Manual deallocation would break the abstraction and become especially difficult for shared structures, closures, and captured continuations.

The garbage collector starts from **roots**—values reachable from active execution state, global/module bindings, and runtime-maintained references—and traces or otherwise identifies objects that remain reachable. Unreachable storage can be reclaimed.

```text
roots
  │
  ├── VM registers and active state
  ├── continuation/stack state
  ├── global and package bindings
  └── protected runtime references
          │
          ▼
     reachable graph
          │
          ├── pairs
          ├── vectors and strings
          ├── records
          ├── closures
          └── continuation objects

reachable objects   ──► preserved
unreachable objects ──► reclaimed
```

GC and value representation cannot be designed independently. The collector must distinguish pointers from immediate values, discover references inside each object layout, update references if objects move, and cooperate with foreign code that temporarily holds Scheme values.

## Continuations

A continuation represents “what remains to be done” at a point in a computation. Consider:

```scheme
(+ 10 (* 3 4))
```

While `(* 3 4)` is being evaluated, the surrounding continuation is roughly:

```text
receive multiplication result
              │
              ▼
           add 10
              │
              ▼
       return final result
```

Scheme exposes continuations through `call-with-current-continuation`, commonly written `call/cc`. A continuation can be captured as a value and invoked to resume the computation at the saved point.

```scheme
(define (find-first predicate items)
  (call/cc
    (lambda (return)
      (for-each
        (lambda (item)
          (if (predicate item)
              (return item)))
        items)
      #f)))
```

Invoking `return` exits immediately to the point represented by the captured continuation. This example uses a continuation as a non-local escape, although continuations can express more general control patterns.

At runtime, a captured continuation must preserve enough execution state to resume correctly. That can involve frames, saved instruction positions, environments, and dynamic context. Because continuations may outlive the call that captured them, the implementation cannot assume that all control state is permanently confined to an ordinary native C stack. Continuation representation, tail-call behavior, exception handling, and garbage collection are therefore closely connected.

## Overall layered architecture

```text
┌───────────────────────────────────────────────────────┐
│ Scheme applications                                  │
│ user programs, application libraries, scsh, tools    │
├───────────────────────────────────────────────────────┤
│ Scheme 48 environment                                │
│ command processor, debugger, libraries, threads, I/O │
│ module descriptions, packages, structures, interfaces│
├───────────────────────────────────────────────────────┤
│ Scheme compiler                                      │
│ reader/syntax → analysis → VM byte code and templates│
├───────────────────────────────────────────────────────┤
│ Scheme 48 virtual machine                            │
│ instruction execution, calls, values, continuations  │
│ allocation, garbage collection, primitives           │
├───────────────────────────────────────────────────────┤
│ Pre-Scheme implementation layer                      │
│ statically typed systems dialect used to express VM  │
├───────────────────────────────────────────────────────┤
│ generated C, C runtime interface, native toolchain    │
├───────────────────────────────────────────────────────┤
│ operating system and hardware                        │
└───────────────────────────────────────────────────────┘
```

This diagram is layered by responsibility, not by claiming that every call crosses every box. For example, compiled Scheme may invoke a primitive implemented by the VM, while Scheme-level I/O code may ultimately use foreign or operating-system services.

## Compact program walk-through

Consider a closure-producing function placed in a module:

```scheme
(define-interface adders-interface
  (export make-adder))

(define-structure adders adders-interface
  (open scheme)
  (begin
    (define (make-adder x)
      (lambda (y)
        (+ x y)))))
```

And client code:

```scheme
(define add10 (make-adder 10))
(add10 5)
;; => 15
```

The journey through the system is approximately:

1. **Configuration:** `define-interface` specifies the public binding. `define-structure` describes a module that imports `scheme`, evaluates its body in a package, and exposes a structure through `adders-interface`.
2. **Reading and syntax:** the reader converts textual forms to Scheme data; syntactic processing resolves the defining and lambda forms in their lexical/module context.
3. **Compilation:** the compiler determines that the inner lambda refers to the free variable `x` and emits VM code plus the information needed to build a closure.
4. **Loading:** compiled templates and constants become reachable in the Scheme 48 image or running environment.
5. **First call:** `(make-adder 10)` executes in the VM and allocates a closure capturing `x = 10`.
6. **Binding:** The closure is stored in the binding for `add10`, which makes it reachable to the collector.
7. **Second call:** `(add10 5)` invokes the closure. The VM sets `y = 5`, retrieves the captured `x = 10`, performs numeric addition, and produces `15`.
8. **Return:** The result is delivered to the current continuation. A tail-position return does not retain an unnecessary frame.
9. **Memory management:** any temporary objects that are no longer reachable may later be reclaimed by the garbage collector. The still-bound `add10` closure remains live.

```text
source module
     │
     ▼
reader + syntax + compiler
     │
     ▼
VM code/template
     │
     ├── call make-adder with 10
     │       │
     │       ▼
     │   closure { code, x = 10 }
     │       │
     │       ▼
     │   bind as add10
     │
     └── call add10 with 5
             │
             ▼
         (+ captured-x y)
             │
             ▼
             15
```

## Why the architecture is interesting

Scheme 48 and Pre-Scheme are architecturally interesting for several related reasons.

### A small substrate supports a rich system

The implementation concentrates low-level mechanisms in a virtual machine while implementing much of the policy and tooling in Scheme. This keeps the trusted, platform-facing substrate conceptually smaller and makes higher layers easier to inspect, modify, and experiment with.

```text
small runtime mechanism
          +
high-level Scheme implementation
          =
rich system largely expressed in itself
```

### The abstraction boundaries are visible

Source language, module configuration, bytecode, VM execution, runtime values, and native services are separate concerns. Studying the points where they meet makes closures, tail calls, GC roots, foreign calls, and continuations concrete rather than purely theoretical.

### Pre-Scheme is a deliberate bridge

Instead of dropping immediately from high-level Scheme into hand-written C, Scheme 48 uses a restricted, statically typed Scheme dialect for systems code and translates it to C. The result combines Scheme-like organization with access to predictable low-level representations and conventional native compilation.

### Modules distinguish several ideas often collapsed into one

Module descriptions, instantiated packages, exported structures, and interfaces are distinct. That vocabulary makes dependency visibility and abstraction boundaries explicit, and supports both controlled static composition and interactive development.

### Advanced control affects the whole runtime

Proper tail calls and first-class continuations are not library decorations. They shape calling conventions, saved execution state, heap management, exceptions, and the relationship between the VM and the native stack. Scheme 48 is therefore a compact place to study how language semantics drive machine architecture.

### It is an expository implementation

Scheme 48 was designed in part as a vehicle for implementation experiments and explanation. Its enduring value is not only that it runs Scheme, but that its structure demonstrates a reusable pattern:

```text
high-level source language
           │
           ▼
compiler and module system
           │
           ▼
small abstract machine
           │
           ▼
systems-language implementation
           │
           ▼
portable native toolchain
```

## Further reading

- [Scheme 48 project home](https://s48.org/) — project overview, releases, manuals, and source distributions.
- [Scheme 48 reference manual](https://www.s48.org/1.9.3/manual/) — command processor, modules, libraries, debugging, and runtime interfaces.
- [Scheme 48 module system](https://www.s48.org/1.9.3/manual/manual-Z-H-5.html) — modules, packages, structures, interfaces, configuration, and linking.
- [Pre-Scheme](https://prescheme.org/) — current information about the Pre-Scheme language and ecosystem.

---

The central idea can be summarized in one sentence: **Scheme 48 uses a small VM, expressed through a Scheme-like systems language, to support a substantially self-hosted Scheme programming environment with explicit modules, managed values, and first-class control.**

**NOTE**: Copyright
- Harald Glab-Plhak
- Computer Science since 1992
- © Harald Glab-Plhak 2026

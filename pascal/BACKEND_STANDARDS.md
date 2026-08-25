# Backend Standards

HGPPascal keeps the language model backend-independent, but each backend has a
different standard shape. Debugging, profiling, and SECD support must respect
that shape.

## C Backend

- Standard target: C99 source.
- Runtime style: dependency-free generated C helpers.
- Debug carrier: symbol-table comments today, source-map records later, DWARF
  through the host C compiler when generated source line mapping matures.
- Profiling carrier: generated counters and runtime hooks around C blocks.
- Optional optimization carrier: virtual register allocation to generated C
  locals, conservative source-level scheduling, and final source peephole hooks.
- SECD carrier: `HGPFunction`, `HGPSSTDFrame`, and thread-local frame depth.
- Numeric carrier: generated `HGPComputeUnary` and `HGPComputeBinary` runtime
  helpers, linked into C and native executable output.
- Heap carrier: generated `HGPHeapObject` headers, `HGPHeapAlloc`,
  `HGPHeapFree`, live-count metadata, and pointer-backed aggregate storage.

The C backend should stay portable. Debug and profiling features are emitted as
plain C structures, comments, or optional generated hooks rather than requiring
a non-standard runtime library.

## Native Executable Backends

- Standard target: native executable produced by GCC-compatible compilation of
  generated C99.
- Targets: `native-m3` for Apple M3/arm64 and `native-x86_64` for x86_64.
- Pipeline: lexer -> parser -> AST -> unit resolver -> C codegen -> GCC.
- Debug carrier: generated C source, symbol-table comments, GCC command
  metadata, and future DWARF-compatible flags.
- Profiling carrier: the same generated C runtime hooks as the C backend,
  compiled directly into the executable.
- Optimization carrier: the C backend optimization path before invoking GCC.
- Runtime linking: SECD, SSTD, NUMERIC, and HEAP support are compiled into the
  executable through the generated C runtime; GCC links the math runtime with
  `-lm` by default.
- Architecture flags: Darwin uses `-arch arm64` or `-arch x86_64`; other
  platforms use GCC-oriented defaults such as `-march=armv8-a` or `-m64`.

The native backends intentionally do not duplicate the C generator. They make
the executable build step explicit and preserve the generated C source so users
can inspect, debug, profile, or recompile it with their preferred GCC-compatible
toolchain.

## JVM Backend

- Standard target: JVM `.class` files, currently via Java source lowering.
- Runtime style: pure nested Java `HGPRuntime`.
- Debug carrier: descriptor metadata and runtime maps today; future direct
  bytecode emission can add `LineNumberTable` and `LocalVariableTable`.
- Profiling carrier: runtime counters, ThreadLocal context, and later JFR/JMX
  compatible hooks when the runtime is externalized.
- Optional optimization carrier: JVM local-slot and operand-stack planning,
  stack-safe scheduling, and a final class-file peephole hook for future direct
  bytecode emission.
- SECD carrier: `FunctionValue`, `SSTDFrame`, and `SSTD_DUMP`.
- Numeric carrier: generated pure Java `computeUnary` and `computeBinary`
  helpers inside `HGPRuntime`.
- Heap carrier: generated `HEAP` table, `HeapObject`, heap IDs on `Ref<T>`,
  and heap-backed `allocate`, `dispose`, and dereference checks.

The JVM backend should follow JVM expectations: strongly typed generated Java,
clear runtime metadata, and a path toward standard class-file debug tables.

## P-Code Backend

- Standard target: HGPPascal textual Pascal P-Code v0.
- Runtime style: explicit stack-machine IR.
- Debug carrier: comments and future source-location records in the stream.
- Profiling carrier: opcode cost models, event tags, and future VM counters.
- Optional optimization carrier: virtual stack slots, stack-effect-preserving
  scheduling, and uppercase/tag-style peephole metadata such as `OPT_PASS
  PEEPHOLE`.
- SECD carrier: `MAKE_CLOSURE`, `CAPTURE`, `APPLY`, `SSTD_ENTER`, `SSTD_LEAVE`.
- Numeric carrier: `NUMERIC` tags and `RUNTIME_BLOCK hgppascal_runtime`.
- Heap carrier: `HEAP_ALLOC`, `HEAP_FREE`, `HEAP_LOAD`, `HEAP_STORE`, and the
  `HEAP` runtime engine entry in `RUNTIME_BLOCK hgppascal_runtime`.

The P-Code backend is the research backend. It can expose compiler-internal
concepts directly as uppercase tags, as long as extensions remain explicit and
stable.

## Runtime And SECD/SSTD Contract

The shared runtime contract has three linked engines:

- `SECD`: Stack, Environment, Control, and Dump state.
- `SSTD`: Stack, Store/Environment, Call, and Dump-style callable invocation.
- `NUMERIC`: arithmetic and mathematical compute engine.
- `HEAP`: handle-based allocation table for scalar values, records, objects,
  arrays, and future aggregate descriptors.

Procedure and lambda calls enter a fresh callee frame. The callee stack is
empty except for the actual call parameters. When the callable returns, the
caller frame is restored from the dump and the return value is pushed onto the
caller stack. One-argument application is represented separately so higher-order
values can be curried until their arity is satisfied.

C and JVM artifacts link this runtime directly into the generated program.
Native executable targets compile that generated C runtime into the executable.
P-Code artifacts attach the runtime contract through `RUNTIME_BLOCK
hgppascal_runtime` so an executable host can discover and call the runtime
block.

Heap references are represented as runtime handles. A heap object stores its
kind, type, value or fields, metadata, and live/free state. Record and object
allocations therefore remain visible to profiling, debugging, and future
garbage-collection experiments instead of being anonymous host allocations.

## Optional Backend Optimization Triple

Backend optimization is opt-in. Existing compile output remains unchanged until
`:backend-optimizations` or `--backend-optimizations` is supplied.

The pass order is fixed:

1. `register-allocation`
2. `instruction-scheduling`
3. `peephole`

The order is intentionally strict. Register allocation establishes virtual
register, local slot, or stack slot pressure before scheduling. Instruction
scheduling can then respect calls, I/O, environment switching, and SECD/SSTD
barriers. Peephole optimization runs last so it can simplify target artifacts
created by both earlier passes.

Callers may enable the whole triple or a subset:

```clojure
(hgppascal.compiler/compile-source source :pcode {:backend-optimizations true})
(hgppascal.compiler/compile-source source :c {:backend-optimizations {:passes [:register-allocation :peephole]}})
```

Even when a subset is requested, selected passes are reordered into the
canonical sequence. The public API exposes this through
`hgppascal.interface/backend-optimization-order` and
`backend-optimization-plan`.

## Shared Contract

All backends consume the same resolved AST and descriptor model:

- Module descriptors for units and imports.
- Type descriptors for records, objects, fields, methods, and future interfaces.
- Callable descriptors for procedures, functions, and methods.
- Closure descriptors for higher-order functions.
- Debug descriptors for source-level tools.
- Profile descriptors for optimization and runtime measurement.

The public API exposes this through `hgppascal.interface/backend-capabilities`,
`backend-standards`, `backend-optimization-plan`, `language-profile`, and
`analyze-source`.

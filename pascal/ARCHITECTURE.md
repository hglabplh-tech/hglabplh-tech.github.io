- [GoTo Top](../index.html)
- [GoTo Index](./index.html)
- [GoTo Next](./p-code.html)
- [Go Back](./features.html)

# HGPPascal Architecture Direction

This document captures the integrated architecture direction taken from the
research ZIPs and adapted to the existing HGPPascal codebase.

## Pipeline

```text
Source
  -> Lexer
  -> Parser
  -> Unit Resolver
  -> Visitor Traversals
  -> Symbol and Call Tables
  -> Descriptor Builder
  -> Backends / Future SECD VM
  -> C-Lowered Native GCC Pipeline
  -> Debugging and Profiling Hooks
```

## Visitor Layer

`hgppascal.ast.visitor` provides a post-order AST visitor. Passes can count,
inspect, or rewrite nodes without coupling to a backend. This mirrors the DJL
research skeleton's optimizer traversal while using HGPPascal's `:node` AST
shape.

## Language Profiles

`hgppascal.language.features` and `hgppascal.language.profile` split the
language into modules:

- Turbo Pascal 5.5 compatibility: programs, routines, records, pointers, units,
  and TP 5.5-style objects.
- TP55Plus: function values, lambda captures, SECD runtime shape, descriptors,
  debugging, profiling, and visitor-based analysis.
- Research extensions: pass catalogs, backend-aware optimization hooks, and
  future ML/RL policy selection.

The compiler can therefore preserve historical syntax while making new
constructs explicit and optional.

## Descriptor Split

Descriptors are split by responsibility:

- `hgppascal.descriptors.module`: modules, imports, exports, private symbols.
- `hgppascal.descriptors.type`: type, field, method-slot, and interface descriptors.
- `hgppascal.descriptors.callable`: callable, parameter, and closure descriptors.
- `hgppascal.descriptors.runtime`: runtime context, environment, thread, stack, and heap descriptors.

The builder keeps `:unit` and `:visibility` metadata from resolved Units, so
public interface symbols and implementation-private symbols can evolve without
reworking the parser.

## SECD Runtime Direction

`hgppascal.runtime.secd` models the future VM boundary with:

- Stack
- Environment
- Control
- Dump

Closure calls store the caller frame in the dump, bind captured variables and
parameters into a target environment, and can restore the caller context
reentrantly.

The runtime also contains a numeric compute engine. `SSTD_NUMERIC` calls route
through `hgppascal.runtime.numeric`, while `SSTD_CALL` and
`SSTD_CALL_LAMBDA` enter fresh callee frames whose stack contains only the call
parameters. Return restores the caller frame and pushes the stack value back to
the caller. One-argument application supports currying for higher-order lambda
values.

`hgppascal.runtime.heap` adds handle-based heap management. SECD states carry a
heap table alongside stack, environment, control, and dump. Heap objects track
kind, type, value/fields, metadata, and live/free state, so allocated records
and future aggregates can be inspected by debugging, profiling, and VM research
tools.

## Debugging And Profiling

Debug and profiling are descriptor-level concerns:

- `hgppascal.instrumentation.debug` defines source locations, breakpoints, and step modes.
- `hgppascal.instrumentation.profiling` defines counters, events, and a simple cost model.
- `hgppascal.pipeline/analyze-program` returns AST, visitor counts, descriptors,
  profile data, and an initial SECD state.

This leaves room for later DJL/PyTorch-style pass selection, real runtime
measurements, source-level debugging, and backend-independent optimization.

## Backend Standards

Backend standards are described in `hgppascal.backend.capabilities` and
documented in `docs/BACKEND_STANDARDS.md`.

- C follows C99 and carries debug/profile data through comments, descriptors,
  and portable generated runtime hooks.
- Native M3/arm64 and x86_64 backends reuse C lowering and add an explicit GCC
  executable build plan.
- JVM follows JVM/Java conventions and keeps runtime support in pure generated
  Java, with a path toward class-file line tables.
- P-Code remains the explicit research IR with stable uppercase extension tags.

- Harald Glab-Plhak
- Computer Science since 1992

- &copy; Harald Glab-Plhak (2026)

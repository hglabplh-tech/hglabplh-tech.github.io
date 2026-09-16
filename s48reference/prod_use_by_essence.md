- [Go up](../index.html)
- [Go index](./index.html)
- [Go back](./intro.html)
- [Go next](./s48architecture.html)

# Essence for S48 - productive use of S48

## TTCN-3 Compiler Suite 

### What is TTCN-3
TTCN-3 (Testing and Test Control Notation Version 3) is an internationally standardized, concurrent, imperative programming language engineered specifically for writing automated test suites for complex distributed systems and protocols (like IPv6, DHCPv6, and SIP).



### The compiler and its architecture


The compiler relies heavily on existing, rock-solid functional programming infrastructure to process the language in a series of traditional stages:

```text
[TTCN-3 Source] 
       │
       ▼ (Cronenberg Scanner + Essence SLR(1) Parser)
  [Raw AST]
       │
       ▼ (Static Processing - 8 Passes)
[Annotated AST]
       │
       ▼ (CPS Transformation - Transformational Compiler)
   [CPS Graph]
   ┌───┴───┐
   ▼       ▼
[Scheme]  [Portable C (via Trampoline)]
```
**NOTE** CPS: Continuation Passing Style - AST: Abstract Syntax Tree 

The **TTCN-3 grammar** is incredibly dense and ambiguous, with more than 1,000 production rules. 
- **The Role of Essence:** Because Essence can parse strings interpretively without pre-generating lookahead or parser tables first, the developers could rapidly iterate and tweak the language rules in real time. 
- They successfully massaged the massive, **ambiguous grammar** into a clean, **SLR(1)** form. They built a minimalist companion scanner generator called **Cronenberg** to handle lexical analysis. 

The design paper by Mike Sperber and Matthias Neubauer is found at [Design paper](https://www.deinprogramm.de/sperber/papers/ttcn-3-compiler.pdf)

**NOTE**: Copyright
- Harald Glab-Plhak
- Computer Science since 1992
- &copy; Harald Glab-Plhak 2026

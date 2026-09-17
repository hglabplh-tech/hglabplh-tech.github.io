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

**A. Syntax Analysis (Essence & Cronenberg)**

The **TTCN-3 grammar** is incredibly dense and ambiguous, with more than 1,000 production rules. 
- **The Role of Essence:** Because Essence can parse strings interpretively without pre-generating lookahead or parser tables first, the developers could rapidly iterate and tweak the language rules in real time. 
- They successfully massaged the massive, **ambiguous grammar** into a clean, **SLR(1)** form. They built a minimalist companion scanner generator called **Cronenberg** to handle lexical analysis. 

**B. Static Processing (The 8-Pass System)**

Because **TTCN-3** constructs are highly interdependent and can appear out of order (e.g., types restricted by static expressions, which themselves rely on other types), the compiler uses **8 passes over the Abstract Syntax Tree (AST)** to resolve variables, sort dependencies topologically, and check types. Scheme's latent typing allowed them to flexibly append properties directly to AST nodes as passes progressed.

**C. The Continuation-Passing Style (CPS) Transformation** 

The absolute core of the compiler is the Transformational Compiler (TC). Originally built for the T project and used to maintain Scheme 48's virtual machine, the TC converts the AST into an explicitly managed graph of CPS nodes. [1]Why CPS? Representing the program in CPS made the messy, implicit control flows of TTCN-3 (such as selective polling, timers, and snapshotting via the alt construct) completely explicit and highly manageable.

**D. Code Generation & Runtime Strategy**

The compiler outputs to two distinct targets: 
1. **The Scheme Backend:** A tiny (<200 lines) generator used strictly for rapid, interactive testing inside a live Scheme 48 session. 
2. **The C Backend:** Designed to meet strict industrial constraints. Because standard C lacks native closures or a user-level preemptive thread system, the compiler performs liveness analysis to insert **explicit memory deallocation**. It then processes function calls using a classic **trampoline technique**, abandoning the native C stack to ensure safe execution on bare-metal systems without an OS. 

###### Paper
 
The design paper by Mike Sperber and Matthias Neubauer is found at [Design paper](https://www.deinprogramm.de/sperber/papers/ttcn-3-compiler.pdf)

**NOTE**: Copyright
- Harald Glab-Plhak
- Computer Science since 1992
- &copy; Harald Glab-Plhak 2026

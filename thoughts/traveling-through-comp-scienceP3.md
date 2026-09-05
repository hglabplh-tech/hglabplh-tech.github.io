###### [Goto top](../index.html)
###### [Goto index](./index.html)
###### [Go next](./logic-charts.html)
###### [Go back](./traveling-through-comp-scienceP2.html)

# The idea of object-oriented programming



## My coding / designing thoughts Part III - Object-Oriented Part

### History of the object-oriented paradigm
The Object-Oriented (OO) paradigm revolutionized software engineering by changing how developers reason about systems. Instead of viewing code as a sequential list of instructions (procedural programming), OO treats software as a web of interacting "objects" that bundle both data (state) and behavior. This shift spans six decades, evolving from a solution for computer simulations into the dominant architecture of modern software. 

1. The 1960s: The Birth of Simula (The Origin)
2. The 1970s: Smalltalk (The Definition of "OOP")
3. The 1980s: C++ and Mainstream Adoption (The Hybrid Era)
4. The 1990s: Java, C#, and Enterprise Dominance (The Managed Era)

#### Simula (1.)

The foundational concepts of OO were invented by **Ole-Johan Dahl** and **Kristen Nygaard** at the Norwegian Computing Center.

- **The Problem:**  They were writing simulation programs (like ship routes or logistics) and found that procedural languages couldn't naturally model real-world, concurrent physical entities.
- **The Solution:** In **Simula 67**, they introduced the concepts of **classes, objects, inheritance**, and virtual procedures. For the first time, software components could mimic **real-world entities**.

#### Smalltalk(2.)

While **Simula** invented the mechanics, **Alan Kay **, ** Dan Ingalls**, and Adele Goldberg at Xerox PARC created the philosophy. Alan Kay coined the term "Object-Oriented Programming" (OOP).

- **The Philosophy:** Kay envisioned software acting like biological cells, communicating exclusively via **"message passing."**
- **The Innovation:** **Smalltalk**  (released in versions like Smalltalk-72 and Smalltalk-80) was a pure OO language. Everything was an object—even integers and loops. It also gave rise to the first graphical user interfaces (GUIs), which naturally aligned with the OO paradigm (clicking an on-screen "button" object).

#### C++ and hybrid era (3.)

Businesses loved the promise of OO (code reuse and better organization), but Smalltalk was too slow and resource-heavy for the computers of the time.

- **The Bridge: Bjarne Stroustrup** solved this by creating **"C with Classes"** in 1979, which evolved into **C++** in 1983.

- **The Impact:**  By adding OO capabilities on top of the ultra-fast, procedural C language, Stroustrup allowed developers to adopt OO design gradually without sacrificing performance. At the same time, **Objective-C** was developed and later became the foundation for Apple's macOS and iOS.

#### The 1990s: Java, C#, and Enterprise Dominance (The Managed Era) (4.)

By the 1990s, the internet arrived, and software complexity exploded. C++ was powerful but notoriously hard to manage due to manual memory management (pointers) and platform-specific compilation.

- **The Java Revolution:** Released by Sun Microsystems in 1995, Java stripped out the dangerous parts of C++ (introducing automatic Garbage Collection) and forced everything into a class structure. Its "Write Once, Run Anywhere" philosophy made it the undisputed king of corporate enterprise and web backends.
- **The Microsoft response:**  Microsoft followed suit in the early 2000s with C# and the .NET framework, solidifying OO as the industry standard taught in every university.

#### Today's languages

By the 2010s, the software industry realized that forcing everything into a rigid OO structure could lead to over-engineered, bloated code (often criticized as "Kingdom of Nouns"). Deep inheritance hierarchies proved fragile and hard to modify.

Today, pure functional or pure object-oriented programming languages are rare. Both paradigms have advantages and disadvantages depending on the task. This leads to languages like Java since version 8, which support both approaches, or C#, which combines object-oriented and functional elements. Python is also a good example.

In these multi-paradigm languages, the best of OO (like encapsulation and interfaces) is combined with functional programming (immutability, first-class functions) to handle concurrent data processing efficiently.

## Under the hood

- [Load the object model environment](./oo-scm-markdown/load-tiny-oo.html)
- [The object model environment macro interface](./oo-scm-markdown/tiny-oo-macros.html)
- [The object model environment model](./oo-scm-markdown/tiny-oo-model.html)
- [The object model environment runtime](./oo-scm-markdown/tiny-oo-runtime.html)

#### Here is the whole thing again in a concept graphic

!["Concept cannot be shown](./tiny-oo-concept.png)

- Harald Glab-Plhak
- Computer Science since 1992

- &copy; Harald Glab-Plhak (2026)
# MyLittleLang → Brainfuck

Diese Fassung enthält bewusst kein `goto`. Kontrollfluss bleibt strukturiert und
lässt sich deshalb direkt auf Brainfuck-Schleifen abbilden.

## Grammatik

```bnf
<program>       ::= { <statement> }

<statement>     ::= <declaration> ";"
                  | <assignment> ";"
                  | <input> ";"
                  | <output> ";"
                  | "break" ";"
                  | <while-statement>
                  | <if-statement>

<declaration>   ::= "dcl" ( "number" | "integer" | "long" | "float" | "double" | "string" 
							| "number[" <integer> "]" 
							| "integer[" <integer> "]" 
							| "long[" <integer> "]" 
							| "float[" <integer> "]" 
							| "double[" <integer> "]" 
							| "string[" <integer> "]") 
							<identifier>
<assignment>    ::= <identifier> "=" <expression>
<input>         ::= "in" <identifier>
<output>        ::= "out" <identifier>

<while-statement> ::= "while" <expression> "do" ";"
                        { <statement> }
                      "end" ";"

<if-statement>  ::= "if" <expression> "then" ";"
                      { <statement> }
                    [ "else" ";" { <statement> } ]
                    "end" ";"

<expression>    ::= <additive>
                    [ ( "==" | "!=" | "<" | "<=" | ">" | ">=" )
                      <additive> ]
<additive>      ::= <multiplicative> { ( "+" | "-" ) <multiplicative> }
<multiplicative>::= <power> { "*" <power> }
<power>         ::= <primary> [ "^" <power> ]
<primary>       ::= <integer> | <identifier> | "(" <expression> ")"
<identifier>    ::= ( "A"…"Z" | "a"…"z" | "_" )
                    { "A"…"Z" | "a"…"z" | "0"…"9" | "_" }
<integer>       ::= <digit> { <digit> }
```

`#` starts a comment up to end of line (EOL). Each simple statement is terminated by a semi-colon as well as the head and end marks of statement blocks.

## Semantik

- `number` is a byte without -/+ (`0..255`). calculation is modulo 256.
- `string` preserves 64 bytes. input ends with LF (`\n`, Byte 10).
- Strings must not hava \NUL  bytes or line-feeds.
- declarations are always global independent of the placement in the code. Duplicate declarations end in an error.
  
- Nur `number` darf in Ausdrücken und Zuweisungen verwendet werden.
- Null ist falsch; jeder andere Zahlenwert ist wahr. Vergleiche liefern 0 oder 1.
- `^` ist rechtsassoziative Potenzierung. Die übrigen Prioritäten entsprechen
  der Reihenfolge in der Grammatik.
- Brainfuck arbeitet mit Bytes. Daher lesen und schreiben `in`/`out` bei
  `number` genau ein Rohbyte. Bei `string` lesen bzw. schreiben sie eine
  LF-terminierte Bytefolge.

## `break;`

`break;` beendet den **innersten lexikalisch umgebenden `while`- oder
`if`-Block**. Außerhalb dieser Blöcke ist es ein Übersetzungsfehler.

```text
while running do;
    if skip then;
        break;       # beendet nur diesen if-Block
        out skipped;
    end;
    out continued;  # wird noch ausgeführt
end;
```

Der Compiler reserviert für jeden aktiven Block eine `live`-Zelle. Jedes
Statement des Blocks wird nur ausgeführt, solange `live != 0` ist. `break;`
setzt die `live`-Zelle des innersten Blocks auf null. Bei `while` wird danach
auch die Schleifenbedingung nicht erneut aktiviert; bei `if` wird lediglich der
Rest des gewählten Zweigs übersprungen.

## Compilerstufen

```text
Quelltext → Lexer → Parser/AST → Namens- und Typprüfung
          → Tape-Allokation → Brainfuck-Codegenerator
```

Der Python- und der Java-Compiler enthalten jeweils die vollständige Pipeline.
Kotlin, Scala und Clojure benutzen absichtlich denselben geprüften Java-Kern;
ihre Einstiegspunkte sind dadurch klein und erzeugen bytegleiches Brainfuck.

## Aufruf

```sh
python3 mini_compiler.py example.mll > example.bf
java MiniCompiler.java example.mll > example.bf

javac MiniCompiler.java
kotlinc MiniCompilerKotlin.kt -cp . -d mini-kotlin.jar
kotlin -cp .:mini-kotlin.jar MiniCompilerKotlin example.mll > example.bf

javac MiniCompiler.java
scala run --classpath . --main-class MiniCompilerScala \
  MiniCompilerScala.scala -- example.mll > example.bf

javac MiniCompiler.java
clojure -Sdeps '{:paths ["."]}' \
  -M -m mini-compiler-clojure example.mll > example.bf
```

Beim Scala-Aufruf kann je nach Installation zusätzlich `--server=false`
notwendig sein.

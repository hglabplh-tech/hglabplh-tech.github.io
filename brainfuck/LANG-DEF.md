## The BNF - definition of **MLL** (__MyLittleLang__)

```bnf
# (c) Harald Glab-Plhak, 2026

program
    ::= statement* EOF

statement
    ::= declaration ";"
      | assignment ";"
      | input ";"
      | output ";"
      | gotoStatement ";"
      | breakStatement ";"
      | whileStatement
      | ifStatement
      | labelStatement

declaration
    ::= "dcl" type IDENTIFIER sizedDimension*

# The number of sized dimensions after the identifier must equal the number
# of [] suffixes in type.  Sizes are positive compile-time integer literals.
type
    ::= baseType arraySuffix*

baseType
    ::= "string"
      | "number"
      | "integer"
      | "long"
      | "float"
      | "double"

arraySuffix
    ::= "[" "]"

sizedDimension
    ::= "[" INTEGER_LITERAL "]"

assignment
    ::= reference "=" expression

input
    ::= "in" reference

output
    ::= "out" expression

reference
    ::= IDENTIFIER indexSuffix*

indexSuffix
    ::= "[" INTEGER_LITERAL "]"

labelStatement
    ::= IDENTIFIER ":"
      | "label" IDENTIFIER ":"

gotoStatement
    ::= "goto" IDENTIFIER

breakStatement
    ::= "break"

whileStatement
    ::= "while" expression "do" ";"
        statement*
        "end" ";"

ifStatement
    ::= "if" expression "then" ";"
        statement*
        ("else" ";" statement*)?
        "end" ";"

expression
    ::= comparison

comparison
    ::= additive
        (("==" | "!=" | "<" | "<=" | ">" | ">=") additive)?

additive
    ::= multiplicative (("+" | "-") multiplicative)*

multiplicative
    ::= power (("*" | "/") power)*

power
    ::= postfix ("^" power)?

postfix
    ::= primary postfixOperation*

postfixOperation
    ::= "." "concat" "(" expression ")"
      | "." "toNumeric" ("(" ")")?

primary
    ::= literal
      | ("+" | "-") literal
      | reference
      | "(" expression ")"

literal
    ::= INTEGER_LITERAL
      | DECIMAL_FLOAT_LITERAL
      | HEX_FLOAT_LITERAL
      | STRING_LITERAL

DECIMAL_FLOAT_LITERAL
    ::= decimalFraction decimalExponent? FLOAT_SUFFIX?
      | DIGIT+ decimalExponent FLOAT_SUFFIX?
      | DIGIT+ FLOAT_SUFFIX

decimalFraction
    ::= DIGIT* "." DIGIT+
      | DIGIT+ "." DIGIT*

decimalExponent
    ::= ("e" | "E") SIGN? DIGIT+

HEX_FLOAT_LITERAL
    ::= ("0x" | "0X") hexSignificand binaryExponent FLOAT_SUFFIX?

hexSignificand
    ::= HEX_DIGIT+ ("." HEX_DIGIT*)?
      | "." HEX_DIGIT+

binaryExponent
    ::= ("p" | "P") SIGN? DIGIT+

# f/F selects binary32; no suffix selects binary64. l/L is tokenized so the
# compiler can issue a precise unsupported-long-double diagnostic.
FLOAT_SUFFIX
    ::= "f" | "F" | "l" | "L"

SIGN
    ::= "+" | "-"

STRING_LITERAL
    ::= '"' stringCharacter* '"'

stringCharacter
    ::= anySourceByteExceptQuoteBackslashOrNewline
      | simpleEscape
      | octalEscape
      | hexadecimalEscape

simpleEscape
    ::= "\\'" | '\\"' | "\\?" | "\\\\"
      | "\\a" | "\\b" | "\\f" | "\\n"
      | "\\r" | "\\t" | "\\v"

octalEscape
    ::= "\\" OCTAL_DIGIT OCTAL_DIGIT? OCTAL_DIGIT?

hexadecimalEscape
    ::= "\\x" HEX_DIGIT+

IDENTIFIER
    ::= LETTER (LETTER | DIGIT | "_")*

INTEGER_LITERAL
    ::= DIGIT+

LETTER
    ::= "A"..."Z" | "a"..."z" | "_"

DIGIT
    ::= "0"..."9"

OCTAL_DIGIT
    ::= "0"..."7"

HEX_DIGIT
    ::= DIGIT | "A"..."F" | "a"..."f"

```

##### (c) Harald Glab-Plhak, 2026 
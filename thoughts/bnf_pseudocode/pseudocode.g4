grammar Pseudocode;

/*
 * Pseudocode.g4
 * ANTLR 4 grammar for the PSEUDOCODE language described in logic-charts.md.
 *
 * The grammar is intentionally language-like rather than merely illustrative:
 * it supports declarations, user-defined types, expressions, structured control
 * flow, procedures/functions, collections, records, enums, classes, labels,
 * goto, input/output, and comments.
 */

program
    : (topLevelItem | statement)* EOF
    ;

topLevelItem
    : typeDefinition
    | functionDefinition
    | procedureDefinition
    | classDefinition
    ;

block
    : statement*
    ;

statement
    : beginEndBlock
    | declaration
    | constantDeclaration
    | assignment
    | inputStatement
    | outputStatement
    | ifStatement
    | caseStatement
    | whileStatement
    | repeatStatement
    | forStatement
    | forEachStatement
    | callStatement
    | returnStatement
    | breakStatement
    | continueStatement
    | gotoStatement
    | labelStatement
    | expressionStatement
    | SEMI
    ;

beginEndBlock
    : BEGIN block END
    ;

/* ================================================================
 * Declarations and types
 * ================================================================ */

declaration
    : DECLARE identifier (AS typeRef)?
      (assignmentOperator expression)? statementEnd?
    ;

constantDeclaration
    : CONSTANT identifier (AS typeRef)?
      assignmentOperator expression statementEnd?
    ;

typeDefinition
    : TYPE identifier ASSIGN typeDefinitionBody statementEnd?
    ;

typeDefinitionBody
    : recordType
    | enumType
    | typeRef
    ;

typeRef
    : primitiveType
    | arrayType
    | listType
    | setType
    | mapType
    | queueType
    | stackType
    | referenceType
    | pointerType
    | optionalType
    | functionType
    | identifier typeArguments?
    ;

primitiveType
    : BOOLEAN
    | CHARACTER
    | STRING
    | INTEGER
    | NATURAL
    | REAL
    | FLOAT
    | DOUBLE
    | DECIMAL
    | VOID
    | ANY
    ;

arrayType
    : ARRAY (LBRACK expression? RBRACK)? OF typeRef
    | ARRAY LBRACK expression? RBRACK
    ;

listType
    : LIST OF typeRef
    ;

setType
    : SET OF typeRef
    ;

mapType
    : MAP OF LT typeRef COMMA typeRef GT
    ;

queueType
    : QUEUE OF typeRef
    ;

stackType
    : STACK OF typeRef
    ;

referenceType
    : REFERENCE TO typeRef
    ;

pointerType
    : POINTER TO typeRef
    ;

optionalType
    : OPTIONAL typeRef
    ;

functionType
    : FUNCTION LPAREN typeRefList? RPAREN RETURNS typeRef
    ;

typeRefList
    : typeRef (COMMA typeRef)*
    ;

typeArguments
    : LT typeRef (COMMA typeRef)* GT
    ;

recordType
    : RECORD fieldDeclaration* END RECORD
    ;

fieldDeclaration
    : identifier AS typeRef
      (assignmentOperator expression)? statementEnd?
    ;

enumType
    : ENUM enumItem (COMMA enumItem)* COMMA? END ENUM
    ;

enumItem
    : identifier (ASSIGN expression)?
    ;

/* ================================================================
 * Classes
 * ================================================================ */

classDefinition
    : CLASS identifier classMember* END CLASS
    ;

classMember
    : fieldDeclaration
    | functionDefinition
    | procedureDefinition
    ;

/* ================================================================
 * Functions and procedures
 * ================================================================ */

functionDefinition
    : FUNCTION identifier
      LPAREN parameterList? RPAREN
      (RETURNS typeRef)?
      block
      END FUNCTION
    ;

procedureDefinition
    : PROCEDURE identifier
      LPAREN parameterList? RPAREN
      block
      END PROCEDURE
    ;

parameterList
    : parameter (COMMA parameter)*
    ;

parameter
    : identifier (AS typeRef)?
    ;

callStatement
    : CALL callableExpression statementEnd?
    ;

returnStatement
    : RETURN expression? statementEnd?
    ;

/* ================================================================
 * Input / Output
 * ================================================================ */

inputStatement
    : (READ | INPUT)
      assignable
      (COMMA assignable)*
      statementEnd?
    ;

outputStatement
    : (PRINT | OUTPUT)
      expression
      (COMMA expression)*
      statementEnd?
    ;

/* ================================================================
 * Assignment
 * ================================================================ */

assignment
    : SET?
      assignable
      assignmentOperator
      expression
      statementEnd?
    ;

assignmentOperator
    : ASSIGN
    | ARROW
    ;

assignable
    : identifier
      (LBRACK expression RBRACK | DOT identifier)*
    ;

/* ================================================================
 * Selection
 * ================================================================ */

ifStatement
    : IF expression THEN block
      (ELSE IF expression THEN block)*
      (ELSE block)?
      END IF
    ;

caseStatement
    : (CASE expression OF | SWITCH expression)
      caseAlternative+
      otherwiseAlternative?
      END (CASE | SWITCH)
    ;

caseAlternative
    : WHEN expression
      (COMMA expression)*
      COLON?
      block
    ;

otherwiseAlternative
    : OTHERWISE COLON? block
    ;

/* ================================================================
 * Iteration
 * ================================================================ */

whileStatement
    : WHILE expression DO
      block
      END WHILE
    ;

repeatStatement
    : REPEAT
      block
      UNTIL expression
      statementEnd?
    ;

forStatement
    : FOR identifier
      assignmentOperator expression
      (TO | DOWNTO) expression
      (STEP expression)?
      DO
      block
      END FOR
    ;

forEachStatement
    : FOR EACH identifier IN expression DO?
      block
      END FOR
    ;

breakStatement
    : BREAK statementEnd?
    ;

continueStatement
    : CONTINUE statementEnd?
    ;

/* ================================================================
 * Unstructured control flow
 * ================================================================ */

gotoStatement
    : GOTO identifier statementEnd?
    ;

labelStatement
    : LABEL identifier COLON? statementEnd?
    ;

/* ================================================================
 * Expressions
 *
 * Precedence, highest to lowest:
 *
 * postfix
 * unary
 * power
 * multiplication / division / modulo
 * addition / subtraction
 * relational
 * equality
 * AND
 * OR
 * ================================================================ */

expression
    : logicalOrExpression
    ;

logicalOrExpression
    : logicalAndExpression
      (OR logicalAndExpression)*
    ;

logicalAndExpression
    : equalityExpression
      (AND equalityExpression)*
    ;

equalityExpression
    : relationalExpression
      ((EQ | NEQ) relationalExpression)*
    ;

relationalExpression
    : additiveExpression
      ((LT | LE | GT | GE) additiveExpression)*
    ;

additiveExpression
    : multiplicativeExpression
      ((PLUS | MINUS) multiplicativeExpression)*
    ;

multiplicativeExpression
    : powerExpression
      ((STAR | SLASH | MOD) powerExpression)*
    ;

powerExpression
    : unaryExpression
      (POWER powerExpression)?
    ;

unaryExpression
    : (NOT | PLUS | MINUS) unaryExpression
    | postfixExpression
    ;

postfixExpression
    : primaryExpression postfixPart*
    ;

postfixPart
    : LPAREN argumentList? RPAREN
    | LBRACK expression RBRACK
    | DOT identifier
    ;

callableExpression
    : identifier postfixPart*
    ;

argumentList
    : expression (COMMA expression)*
    ;

primaryExpression
    : literal
    | identifier
    | arrayLiteral
    | listLiteral
    | mapLiteral
    | LPAREN expression RPAREN
    ;

expressionStatement
    : callableExpression statementEnd?
    ;

/* ================================================================
 * Collection literals
 * ================================================================ */

arrayLiteral
    : LBRACK argumentList? RBRACK
    ;

listLiteral
    : LBRACE argumentList? RBRACE
    ;

mapLiteral
    : LBRACE mapEntry (COMMA mapEntry)* RBRACE
    | LBRACE RBRACE
    ;

mapEntry
    : expression COLON expression
    ;

/* ================================================================
 * Literals
 * ================================================================ */

literal
    : INTEGER_LITERAL
    | REAL_LITERAL
    | STRING_LITERAL
    | CHARACTER_LITERAL
    | TRUE
    | FALSE
    | NULL
    ;

identifier
    : IDENTIFIER
    ;

statementEnd
    : SEMI
    ;

/* ================================================================
 * Lexer
 *
 * Keywords are case-insensitive.
 * ================================================================ */

BEGIN       : B E G I N;
END         : E N D;

SET         : S E T;

READ        : R E A D;
INPUT       : I N P U T;

PRINT       : P R I N T;
OUTPUT      : O U T P U T;

IF          : I F;
THEN        : T H E N;
ELSE        : E L S E;

CASE        : C A S E;
SWITCH      : S W I T C H;
OF          : O F;
WHEN        : W H E N;
OTHERWISE   : O T H E R W I S E;

WHILE       : W H I L E;
DO          : D O;

REPEAT      : R E P E A T;
UNTIL       : U N T I L;

FOR         : F O R;
EACH        : E A C H;
IN          : I N;
TO          : T O;
DOWNTO      : D O W N T O;
STEP        : S T E P;

BREAK       : B R E A K;
CONTINUE    : C O N T I N U E;

FUNCTION    : F U N C T I O N;
PROCEDURE   : P R O C E D U R E;
CALL        : C A L L;
RETURN      : R E T U R N;
RETURNS     : R E T U R N S;

DECLARE     : D E C L A R E;
CONSTANT    : C O N S T A N T;

TYPE        : T Y P E;
AS          : A S;

ARRAY       : A R R A Y;
LIST        : L I S T;
MAP         : M A P;
QUEUE       : Q U E U E;
STACK       : S T A C K;

RECORD      : R E C O R D;
ENUM        : E N U M;
CLASS       : C L A S S;

REFERENCE   : R E F E R E N C E;
POINTER     : P O I N T E R;
OPTIONAL    : O P T I O N A L;

GOTO        : G O T O;
LABEL       : L A B E L;

/* ================================================================
 * Primitive types
 * ================================================================ */

BOOLEAN     : B O O L E A N;
CHARACTER   : C H A R A C T E R;
STRING      : S T R I N G;

INTEGER     : I N T E G E R;
NATURAL     : N A T U R A L;

REAL        : R E A L;
FLOAT       : F L O A T;
DOUBLE      : D O U B L E;
DECIMAL     : D E C I M A L;

VOID        : V O I D;
ANY         : A N Y;

/* ================================================================
 * Logical operators and constants
 * ================================================================ */

AND         : A N D;
OR          : O R;
NOT         : N O T;

TRUE        : T R U E;
FALSE       : F A L S E;
NULL        : N U L L;

MOD         : M O D;

/* ================================================================
 * Operators
 * ================================================================ */

ARROW       : '<-' | '\u2190';

ASSIGN      : '=';

EQ          : '==' | '=';
NEQ         : '!=' | '<>';

LE          : '<=';
GE          : '>=';

LT          : '<';
GT          : '>';

PLUS        : '+';
MINUS       : '-';

STAR        : '*';
SLASH       : '/';

POWER       : '^' | '**';

/* ================================================================
 * Punctuation
 * ================================================================ */

LPAREN      : '(';
RPAREN      : ')';

LBRACK      : '[';
RBRACK      : ']';

LBRACE      : '{';
RBRACE      : '}';

COMMA       : ',';
COLON       : ':';
DOT         : '.';
SEMI        : ';';

/* ================================================================
 * Numeric literals
 * ================================================================ */

REAL_LITERAL
    : DIGIT+ '.' DIGIT* EXPONENT?
    | '.' DIGIT+ EXPONENT?
    | DIGIT+ EXPONENT
    ;

INTEGER_LITERAL
    : DIGIT+
    ;

/* ================================================================
 * String / character literals
 * ================================================================ */

STRING_LITERAL
    : '"' (ESCAPE_SEQUENCE | ~["\\\r\n])* '"'
    ;

CHARACTER_LITERAL
    : '\'' (ESCAPE_SEQUENCE | ~['\\\r\n]) '\''
    ;

/* ================================================================
 * Identifiers
 * ================================================================ */

IDENTIFIER
    : [a-zA-Z_] [a-zA-Z_0-9]*
    ;

/* ================================================================
 * Comments
 * ================================================================ */

LINE_COMMENT
    : '//' ~[\r\n]* -> skip
    ;

HASH_COMMENT
    : '#' ~[\r\n]* -> skip
    ;

BLOCK_COMMENT
    : '/*' .*? '*/' -> skip
    ;

/* ================================================================
 * Whitespace
 * ================================================================ */

WS
    : [ \t\r\n]+ -> skip
    ;

/* ================================================================
 * Lexer fragments
 * ================================================================ */

fragment DIGIT
    : [0-9]
    ;

fragment EXPONENT
    : [eE] [+-]? DIGIT+
    ;

fragment ESCAPE_SEQUENCE
    : '\\' ["'\\btnrf]
    ;

/*
 * Alphabet fragments allow keywords to be case-insensitive.
 */

fragment A : [aA];
fragment B : [bB];
fragment C : [cC];
fragment D : [dD];
fragment E : [eE];
fragment F : [fF];
fragment G : [gG];
fragment H : [hH];
fragment I : [iI];
fragment J : [jJ];
fragment K : [kK];
fragment L : [lL];
fragment M : [mM];
fragment N : [nN];
fragment O : [oO];
fragment P : [pP];
fragment Q : [qQ];
fragment R : [rR];
fragment S : [sS];
fragment T : [tT];
fragment U : [uU];
fragment V : [vV];
fragment W : [wW];
fragment X : [xX];
fragment Y : [yY];
fragment Z : [zZ];

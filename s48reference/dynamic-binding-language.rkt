#lang racket

(require racket/match)

;; ============================================================
;; Abstract syntax
;; ============================================================

(struct program (statements) #:transparent)
(struct variable-declaration (name expression) #:transparent)
(struct function-declaration (name body) #:transparent)
(struct function-call (name arguments) #:transparent)
(struct print-statement (format-expression arguments) #:transparent)
(struct if-statement (condition then-block else-block) #:transparent)
(struct comparison (operator left right) #:transparent)
(struct integer-expression (value) #:transparent)
(struct string-expression (value) #:transparent)
(struct variable-expression (name) #:transparent)

;; A function value contains its body.  Name lookup follows the active
;; environment and then the caller dump, as requested below.
(struct function-value (name body) #:transparent)

;; A binding is an identifier-to-location association.  The box is the
;; location; changing a box would be assignment, not a new binding.
(struct binding (name location) #:transparent)

;; An environment is a map: symbol -> binding.
;; A frame is one unit on the dump.
(struct frame (environment) #:transparent)

;; ============================================================
;; Tokenizer
;; ============================================================

(define token-pattern
  #px"\"(?:\\\\.|[^\"])*\"|<=|>=|==|!=|<-|<|>|[A-Za-z_][A-Za-z0-9_]*|-?[0-9]+|[(),;]")

(define (tokenize source)
  (regexp-match* token-pattern source))

;; ============================================================
;; Recursive-descent parser
;;
;; Grammar:
;;
;; program       := statement (";" statement)* ";"?
;; statement     := declaration | call | print | if
;; declaration   := "dcl" identifier "<-" expression
;;                | "dcl" "fun"? identifier block
;; call          := identifier "(" arguments? ")"
;; print         := "print" expression ("," expression)*
;; if            := "if" condition "then" block "else" block
;; condition     := expression comparison-operator expression
;; block         := "(" statement (";" statement)* ";"? ")"
;; expression    := integer | string | identifier
;; comparison-op := "==" | "!=" | "<" | "<=" | ">" | ">="
;; ============================================================

(define (parse source)
  (define tokens (list->vector (tokenize source)))
  (define position 0)

  (define (finished?)
    (= position (vector-length tokens)))

  (define (peek)
    (and (not (finished?))
         (vector-ref tokens position)))

  (define (take!)
    (when (finished?)
      (error 'parse "unexpected end of input"))
    (begin0
      (vector-ref tokens position)
      (set! position (add1 position))))

  (define (accept! expected)
    (and (equal? (peek) expected)
         (begin (take!) #t)))

  (define (expect! expected)
    (unless (accept! expected)
      (error 'parse "expected ~a, found ~a" expected (peek))))

  (define (identifier-token? token)
    (and token
         (regexp-match? #px"^[A-Za-z_][A-Za-z0-9_]*$" token)
         (not (member token '("dcl" "fun" "print" "if" "then" "else")))))

  (define (take-identifier!)
    (let ([token (take!)])
      (unless (identifier-token? token)
        (error 'parse "expected identifier, found ~a" token))
      (string->symbol token)))

  (define (string-token? token)
    (and token
         (>= (string-length token) 2)
         (char=? (string-ref token 0) #\")))

  (define (decode-string token)
    (with-input-from-string token read))

  (define (parse-expression)
    (let ([token (take!)])
      (cond
        [(regexp-match? #px"^-?[0-9]+$" token)
         (integer-expression (string->number token))]
        [(string-token? token)
         (string-expression (decode-string token))]
        [(identifier-token? token)
         (variable-expression (string->symbol token))]
        [else
         (error 'parse "invalid expression: ~a" token)])))

  (define comparison-operators
    '("==" "!=" "<" "<=" ">" ">="))

  (define (parse-condition)
    (let* ([left (parse-expression)]
           [operator (take!)])
      (unless (member operator comparison-operators)
        (error 'parse "expected comparison operator, found ~a" operator))
      (comparison operator left (parse-expression))))

  (define (parse-arguments)
    (expect! "(")
    (cond
      [(accept! ")") '()]
      [else
       (let loop ([result (list (parse-expression))])
         (if (accept! ",")
             (loop (append result (list (parse-expression))))
             (begin
               (expect! ")")
               result)))]))

  (define (parse-call)
    (let ([name (take-identifier!)])
      (function-call name (parse-arguments))))

  (define (parse-print)
    (expect! "print")
    (let ([format-expression (parse-expression)])
      (let loop ([arguments '()])
        (if (accept! ",")
            (loop (append arguments (list (parse-expression))))
            (print-statement format-expression arguments)))))

  (define (parse-block)
    (expect! "(")
    (let loop ([result '()])
      (cond
        [(accept! ")") result]
        [else
         (let ([statement (parse-statement)])
           (accept! ";")
           (loop (append result (list statement))))])))

  (define (parse-if)
    (expect! "if")
    (let ([condition (parse-condition)])
      (expect! "then")
      (let ([then-block (parse-block)])
        (expect! "else")
        (if-statement condition then-block (parse-block)))))

  (define (parse-declaration)
    (expect! "dcl")
    (let ([explicit-function? (accept! "fun")])
      (let ([name (take-identifier!)])
        (cond
          [explicit-function?
           (function-declaration name (parse-block))]
          [(accept! "<-")
           (variable-declaration name (parse-expression))]
          [(equal? (peek) "(")
           (function-declaration name (parse-block))]
          [else
           (error 'parse "invalid declaration for ~a" name)]))))

  (define (parse-statement)
    (cond
      [(equal? (peek) "dcl") (parse-declaration)]
      [(equal? (peek) "print") (parse-print)]
      [(equal? (peek) "if") (parse-if)]
      [(identifier-token? (peek)) (parse-call)]
      [else (error 'parse "unexpected token: ~a" (peek))]))

  (let loop ([result '()])
    (if (finished?)
        (program result)
        (let ([statement (parse-statement)])
          (accept! ";")
          (loop (append result (list statement)))))))

;; ============================================================
;; Binding creation and lookup
;; ============================================================

(define (make-environment)
  (make-hasheq))

(define (create-binding! environment variable value)
  (when (hash-has-key? environment variable)
    (error 'create-binding!
           "duplicate declaration in actual environment: ~a"
           variable))
  (let ([new-binding (binding variable (box value))])
    (hash-set! environment variable new-binding)
    new-binding))

;; Lookup only in the actual environment.  An empty list means not found.
(define (lookup-act-environment environment variable)
  (hash-ref environment variable (lambda () empty)))

;; Search dump frames from the most recent caller towards top-level.
(define (env-lookup-helper dump variable)
  (cond
    [(empty? dump) empty]
    [else
     (let* ([environment (frame-environment (first dump))]
            [found-binding
             (lookup-act-environment environment variable)])
       (if (not (empty? found-binding))
           found-binding
           (env-lookup-helper (rest dump) variable)))]))

;; Required lookup order:
;;   1. actual environment
;;   2. most recent frame in the dump
;;   3. older frames, continuing to top-level
(define (lookup-environment environment dump variable)
  (let ([actual-binding
         (lookup-act-environment environment variable)])
    (cond
      [(not (empty? actual-binding)) actual-binding]
      [(not (empty? dump)) (env-lookup-helper dump variable)]
      [else empty])))

(define (lookup-value environment dump variable)
  (let ([found-binding
         (lookup-environment environment dump variable)])
    (when (empty? found-binding)
      (error 'lookup-value "unbound identifier: ~a" variable))
    (unbox (binding-location found-binding))))

;; Included to show the distinction between binding and assignment.
(define (assign-value! environment dump variable new-value)
  (let ([found-binding
         (lookup-environment environment dump variable)])
    (when (empty? found-binding)
      (error 'assign-value! "unbound identifier: ~a" variable))
    (set-box! (binding-location found-binding) new-value)))

;; ============================================================
;; Evaluator
;; ============================================================

(define (evaluate-expression expression environment dump)
  (match expression
    [(integer-expression value) value]
    [(string-expression value) value]
    [(variable-expression name) (lookup-value environment dump name)]))

(define (evaluate-comparison condition environment dump)
  (match condition
    [(comparison operator left-expression right-expression)
     (let* ([left (evaluate-expression left-expression environment dump)]
            [right (evaluate-expression right-expression environment dump)])
       (cond
         [(equal? operator "==") (equal? left right)]
         [(equal? operator "!=") (not (equal? left right))]
         [else
          (unless (and (exact-integer? left) (exact-integer? right))
            (error 'comparison
                   "~a requires integer operands, received ~e and ~e"
                   operator left right))
          (cond
            [(equal? operator "<") (< left right)]
            [(equal? operator "<=") (<= left right)]
            [(equal? operator ">") (> left right)]
            [(equal? operator ">=") (>= left right)]
            [else (error 'comparison "unknown operator: ~a" operator)])]))]))

(define (format-with-placeholders format-string values)
  (for/fold ([result format-string])
            ([value (in-list values)])
    (unless (regexp-match? #rx"%(d|s)" result)
      (error 'print "too many values for format string: ~a" format-string))
    (regexp-replace
     #rx"%(d|s)"
     result
     (lambda ignored (format "~a" value)))))

(define (install-declaration! declaration environment dump)
  (match declaration
    [(variable-declaration name expression)
     (create-binding!
      environment name
      (evaluate-expression expression environment dump))]
    [(function-declaration name body)
     (create-binding! environment name (function-value name body))]))

(define (execute-block! statements parent-environment dump)
  ;; A block receives a fresh actual environment.  Its immediately enclosing
  ;; environment becomes the first frame on the new dump.
  (let ([block-environment (make-environment)]
        [block-dump (cons (frame parent-environment) dump)])
    (for-each
     (lambda (statement)
       (execute-statement! statement block-environment block-dump))
     statements)))

(define (execute-call! call caller-environment dump)
  (match call
    [(function-call name arguments)
     (unless (empty? arguments)
       (error 'function-call "example functions accept no arguments"))
     (let ([function (lookup-value caller-environment dump name)])
       (unless (function-value? function)
         (error 'function-call "~a is not a function" name))
       ;; Dynamic/dump lookup: the caller environment is pushed first.
       (let ([callee-environment (make-environment)]
             [callee-dump (cons (frame caller-environment) dump)])
         (for-each
          (lambda (statement)
            (execute-statement! statement callee-environment callee-dump))
          (function-value-body function))))]))

(define (execute-print! statement environment dump)
  (match statement
    [(print-statement format-expression argument-expressions)
     (let* ([format-string
             (evaluate-expression format-expression environment dump)]
            [values
             (map
              (lambda (expression)
                (evaluate-expression expression environment dump))
              argument-expressions)])
       (unless (string? format-string)
         (error 'print "first expression must produce a string"))
       (displayln (format-with-placeholders format-string values)))]))

(define (execute-statement! statement environment dump)
  (match statement
    [(or (variable-declaration _ _)
         (function-declaration _ _))
     (install-declaration! statement environment dump)]
    [(function-call _ _)
     (execute-call! statement environment dump)]
    [(print-statement _ _)
     (execute-print! statement environment dump)]
    [(if-statement condition then-block else-block)
     (if (evaluate-comparison condition environment dump)
         (execute-block! then-block environment dump)
         (execute-block! else-block environment dump))]))

(define (execute-program! syntax-tree)
  (let ([top-level-environment (make-environment)])
    (for-each
     (lambda (statement)
       (execute-statement! statement top-level-environment empty))
     (program-statements syntax-tree))
    top-level-environment))

;; ============================================================
;; Executable example
;; ============================================================

(define source
  (string-append
   "dcl a <- 5; "
   "dcl b <- 7; "
   "dcl fun_print (print \"%d geta %d\", a, b); "
   "dcl fun test ("
   "  dcl a <- 9; "
   "  if a == 9 then ("
   "    print \"condition true; inner a = %d\", a; "
   "    fun_print()"
   "  ) else ("
   "    print \"condition false; a = %d\", a"
   "  ); "
   "  print \"after if; inner a = %d\", a"
   "); "
   "test(); "
   "fun_print(); "
   "if a < b then ("
   "  print \"top-level condition true: a = %d, b = %d\", a, b"
   ") else ("
   "  print \"top-level condition false: a = %d, b = %d\", a, b"
   ")"))

(define syntax-tree (parse source))

(displayln "Parsed program:")
(pretty-print syntax-tree)
(displayln "\nProgram output:")
(void (execute-program! syntax-tree))

#lang racket

(require racket/match
         racket/set)

;; ============================================================
;; Abstract syntax tree
;; ============================================================

(struct program    (declarations) #:transparent)
(struct var-decl  (name expression) #:transparent)
(struct fun-decl  (name body) #:transparent)
(struct call       (name arguments) #:transparent)
(struct print-stmt (format arguments) #:transparent)
(struct number-expr (value) #:transparent)
(struct variable-expr (name) #:transparent)

;; A closure remembers the environment in which it was defined.
(struct closure (name body definition-environment) #:transparent)

;; A rib contains:
;;   table  : symbol -> location
;;   order  : binding names in declaration order
;;   parent : enclosing lexical rib
(struct rib (table order parent) #:transparent)

;; ============================================================
;; Tokenizer
;; ============================================================

(define token-pattern
  #px"\"(?:\\\\.|[^\"])*\"|<-|[A-Za-z_][A-Za-z0-9_]*|-?[0-9]+|[(),;]")

(define (tokenize source)
  (regexp-match* token-pattern source))

;; ============================================================
;; Recursive-descent parser
;; ============================================================

(define (parse source)
  (define tokens
    (list->vector (tokenize source)))

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
         (begin
           (take!)
           #t)))

  (define (expect! expected)
    (unless (accept! expected)
      (error 'parse
             "expected ~a, found ~a"
             expected
             (peek))))

  (define (identifier-token? token)
    (and token
         (regexp-match?
          #px"^[A-Za-z_][A-Za-z0-9_]*$"
          token)))

  (define (take-identifier!)
    (define token (take!))

    (unless (identifier-token? token)
      (error 'parse "expected identifier, found ~a" token))

    (string->symbol token))

  (define (parse-expression)
    (define token (take!))

    (cond
      [(regexp-match? #px"^-?[0-9]+$" token)
       (number-expr (string->number token))]

      [(identifier-token? token)
       (variable-expr (string->symbol token))]

      [else
       (error 'parse "invalid expression: ~a" token)]))

  (define (parse-call)
    (define name (take-identifier!))

    (expect! "(")

    (define arguments
      (if (accept! ")")
          '()
          (let loop ([arguments
                      (list (parse-expression))])
            (cond
              [(accept! ",")
               (loop
                (append arguments
                        (list (parse-expression))))]

              [else
               (expect! ")")
               arguments]))))

    (call name arguments))

  (define (parse-print)
    (expect! "print")

    (define format-token (take!))

    (unless (and (positive? (string-length format-token))
                 (char=? (string-ref format-token 0) #\"))
      (error 'parse
             "expected a format string, found ~a"
             format-token))

    (define format-string
      (substring format-token
                 1
                 (sub1 (string-length format-token))))

    (define arguments
      (let loop ([arguments '()])
        (if (accept! ",")
            (loop
             (append arguments
                     (list (parse-expression))))
            arguments)))

    (print-stmt format-string arguments))

  (define (parse-body)
    (expect! "(")

    (let loop ([statements '()])
      (cond
        [(accept! ")")
         statements]

        [else
         (define statement (parse-statement))
         (accept! ";")

         (loop
          (append statements
                  (list statement)))])))

  (define (parse-declaration)
    (expect! "dcl")

    ;; Accept both:
    ;;   dcl fun_print (...)
    ;;   dcl fun test (...)
    (accept! "fun")

    (define name (take-identifier!))

    (cond
      [(accept! "<-")
       (var-decl name (parse-expression))]

      [(equal? (peek) "(")
       (fun-decl name (parse-body))]

      [else
       (error 'parse
              "expected <- or function body after ~a"
              name)]))

  (define (parse-statement)
    (cond
      [(equal? (peek) "dcl")
       (parse-declaration)]

      [(equal? (peek) "print")
       (parse-print)]

      [(identifier-token? (peek))
       (parse-call)]

      [else
       (error 'parse "unexpected token: ~a" (peek))]))

  (define declarations
    (let loop ([result '()])
      (if (finished?)
          result
          (let ([declaration (parse-declaration)])
            (accept! ";")
            (loop
             (append result
                     (list declaration)))))))

  (program declarations))

;; ============================================================
;; Ribcage environments
;; ============================================================

(define (make-rib [parent #f])
  (rib (make-hasheq)
       (box '())
       parent))

;; A binding maps a name to a location.
;; The location is represented by a Racket box.
(define (bind! environment name initial-value)
  (define table (rib-table environment))

  (when (hash-has-key? table name)
    (error 'bind!
           "duplicate binding in the same rib: ~a"
           name))

  (define location
    (box initial-value))

  (hash-set! table name location)

  (set-box! (rib-order environment)
            (append (unbox (rib-order environment))
                    (list name)))

  location)

;; Return the first matching location, searching outward.
(define (lookup-location environment name)
  (cond
    [(not environment)
     (error 'lookup
            "unbound identifier: ~a"
            name)]

    [(hash-has-key? (rib-table environment) name)
     (hash-ref (rib-table environment) name)]

    [else
     (lookup-location
      (rib-parent environment)
      name)]))

(define (lookup-value environment name)
  (unbox
   (lookup-location environment name)))

;; Assignment changes a location's contents.
;; It does not create another binding.
(define (assign! environment name new-value)
  (set-box! (lookup-location environment name)
            new-value))

;; ============================================================
;; Evaluation
;; ============================================================

(define (evaluate-expression expression environment)
  (match expression
    [(number-expr value)
     value]

    [(variable-expr name)
     (lookup-value environment name)]))

(define (install-declaration! declaration environment)
  (match declaration
    [(var-decl name expression)
     (bind! environment
            name
            (evaluate-expression expression environment))]

    [(fun-decl name body)
     ;; Install the location first so recursive functions can
     ;; refer to their own binding.
     (define location
       (bind! environment name 'uninitialized))

     (set-box! location
               (closure name body environment))]))

(define (execute-call expression caller-environment)
  (match-define
    (call function-name argument-expressions)
    expression)

  (define function-value
    (lookup-value caller-environment function-name))

  (unless (closure? function-value)
    (error 'call "~a is not a function" function-name))

  (unless (null? argument-expressions)
    (error 'call
           "this example supports zero-argument functions"))

  ;; The crucial lexical-scoping step:
  ;;
  ;; The call rib points to the function's definition
  ;; environment, not the caller's environment.
  (define call-environment
    (make-rib
     (closure-definition-environment function-value)))

  (for-each
   (lambda (statement)
     (execute-statement statement call-environment))
   (closure-body function-value)))

(define (execute-statement statement environment)
  (match statement
    [(or (var-decl _ _)
         (fun-decl _ _))
     (install-declaration! statement environment)]

    [(call _ _)
     (execute-call statement environment)]

    [(print-stmt format-string arguments)
     (define values
       (map
        (lambda (argument)
          (evaluate-expression argument environment))
        arguments))

     ;; The input uses C-style %d placeholders.
     ;; This displays the resolved binding values.
     (printf "~a  values: ~a\n"
             format-string
             values)]))

(define (load-program parsed-program)
  (define global-environment
    (make-rib))

  (for-each
   (lambda (declaration)
     (install-declaration!
      declaration
      global-environment))
   (program-declarations parsed-program))

  global-environment)

;; ============================================================
;; Deterministic inspection of visible bindings
;; ============================================================

(define (display-value value)
  (if (closure? value)
      `(closure ,(closure-name value))
      value))

;; Return bindings from nearest rib to outermost rib.
;; A shadowed outer name is omitted.
(define (visible-bindings environment)
  (define seen (mutable-seteq))

  (let loop ([current environment]
             [depth 0])
    (cond
      [(not current)
       '()]

      [else
       (append
        (for/list
            ([name (in-list
                    (unbox (rib-order current)))]
             #:unless (set-member? seen name))

          (set-add! seen name)

          (list 'depth
                depth
                'name
                name
                'value
                (display-value
                 (unbox
                  (hash-ref
                   (rib-table current)
                   name)))))

        (loop (rib-parent current)
              (add1 depth)))])))

;; ============================================================
;; Parse and run the supplied program
;; ============================================================

(define source
  (string-append
   "dcl a <- 5; "
   "dcl b <- 7; "
   "dcl fun_print (print \"%d geta %d\", a, b); "
   "dcl fun test (dcl a <- 9; fun_print(); print \"inner a -> delivers 9: %d\", a);"
   "fun_print()"))


(define syntax-tree
  (parse source))

(define global-environment
  (load-program syntax-tree))

(displayln syntax-tree)
(displayln (visible-bindings global-environment))

(execute-call
 (call 'test '())
 global-environment)
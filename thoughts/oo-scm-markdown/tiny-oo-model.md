###### [Go back](../traveling-through-comp-scienceP3.html)

```scheme
;; ============================================================
;; tiny-oo-model.scm
;; R5RS + SRFI-9
;;
;; Data model and procedural class/interface/inheritance layer.
;;
;; No dynamic dispatch state is kept here.
;; ============================================================

;; ------------------------------------------------------------
;; Member
;;
;; name   : symbol
;; type   : type description
;; value  : field value or method-description
;; owner  : symbol naming the defining class
;; ------------------------------------------------------------

(define-record-type <member>
  (make-member name type value owner)
  member?
  (name member-name)
  (type member-type)
  (value member-value member-value-set!)
  (owner member-owner))


;; ------------------------------------------------------------
;; Method description
;; ------------------------------------------------------------

(define-record-type <method-description>
  (make-method-description
    name
    parameter-types
    return-type
    code
    owner)
  method-description?
  (name method-description-name)
  (parameter-types method-description-parameter-types)
  (return-type method-description-return-type)
  (code method-description-code)
  (owner method-description-owner))


;; ------------------------------------------------------------
;; Typed function value
;;
;; Used when functions themselves are passed as typed values.
;; ------------------------------------------------------------

(define-record-type <typed-function>
  (make-typed-function
    parameter-types
    return-type
    procedure)
  typed-function?
  (parameter-types typed-function-parameter-types)
  (return-type typed-function-return-type)
  (procedure typed-function-procedure))


;; ------------------------------------------------------------
;; Interface field description
;; ------------------------------------------------------------

(define-record-type <interface-field>
  (make-interface-field name type)
  interface-field?
  (name interface-field-name)
  (type interface-field-type))


;; ------------------------------------------------------------
;; Interface method description
;; ------------------------------------------------------------

(define-record-type <interface-method>
  (make-interface-method
    name
    parameter-types
    return-type)
  interface-method?
  (name interface-method-name)
  (parameter-types interface-method-parameter-types)
  (return-type interface-method-return-type))


;; ------------------------------------------------------------
;; Interface definition
;;
;; Stored as a proper record containing vectors of field and
;; method requirements.
;; ------------------------------------------------------------

(define-record-type <interface-definition>
  (make-interface-definition
    name
    fields
    methods)
  interface-definition?
  (name interface-definition-name)
  (fields interface-definition-fields)
  (methods interface-definition-methods))


;; ------------------------------------------------------------
;; Class definition
;;
;; parent            : class or #f
;; interfaces        : vector of interface definitions
;; instance-members  : vector of own fields/methods only
;; static-members    : vector of own static fields/methods only
;; ------------------------------------------------------------

(define-record-type <class-definition>
  (make-class-definition
    name
    parent
    interfaces
    instance-members
    static-members)
  class-definition?
  (name class-name)
  (parent class-parent)
  (interfaces class-interfaces)
  (instance-members class-instance-members)
  (static-members class-static-members))


;; ============================================================
;; Type symbols
;; ============================================================

(define type-any            'any)
(define type-void           'void)

(define type-long           'long)
(define type-integer        'integer)
(define type-real           'real)
(define type-string         'string)
(define type-boolean        'boolean)
(define type-object         'object)

(define type-method         'method)
(define type-static-method  'static-method)

(define type-object-class   'object-class)


;; ============================================================
;; Errors
;;
;; R5RS does not standardize ERROR.
;; ============================================================

(define (oo-error message value)
  (display "OO runtime error: ")
  (display message)
  (if value
      (begin
        (display " : ")
        (write value)))
  (newline)
  #f)


;; ============================================================
;; Type description helpers
;;
;; Simple:
;;   long
;;   string
;;
;; Function:
;;   (function (long string) boolean)
;; ============================================================

(define (function-type? type)
  (and
    (pair? type)
    (eq? (car type) 'function)
    (pair? (cdr type))
    (pair? (cddr type))))


(define (function-type-parameters type)
  (cadr type))


(define (function-type-return type)
  (caddr type))


(define (type-list=? left right)
  (cond
    ((and (null? left)
          (null? right))
     #t)

    ((or (null? left)
         (null? right))
     #f)

    ((type-description=?
       (car left)
       (car right))
     (type-list=?
       (cdr left)
       (cdr right)))

    (else
     #f)))


(define (type-description=? left right)
  (cond
    ((and
       (symbol? left)
       (symbol? right))
     (eq? left right))

    ((and
       (function-type? left)
       (function-type? right))
     (and
       (type-list=?
         (function-type-parameters left)
         (function-type-parameters right))
       (type-description=?
         (function-type-return left)
         (function-type-return right))))

    (else
     #f)))


(define (value-matches-type? type value)
  (cond
    ((eq? type type-any)
     #t)

    ((eq? type type-void)
     (eq? value #f))

    ((eq? type type-long)
     (integer? value))

    ((eq? type type-integer)
     (integer? value))

    ((eq? type type-real)
     (real? value))

    ((eq? type type-string)
     (string? value))

    ((eq? type type-boolean)
     (boolean? value))

    ((eq? type type-object)
     (vector? value))

    ((function-type? type)
     (and
       (typed-function? value)
       (type-list=?
         (function-type-parameters type)
         (typed-function-parameter-types value))
       (type-description=?
         (function-type-return type)
         (typed-function-return-type value))))

    (else
     #f)))


(define (arguments-match? types values)
  (cond
    ((and
       (null? types)
       (null? values))
     #t)

    ((or
       (null? types)
       (null? values))
     #f)

    ((value-matches-type?
       (car types)
       (car values))
     (arguments-match?
       (cdr types)
       (cdr values)))

    (else
     #f)))


;; ============================================================
;; Vector helpers
;; ============================================================

(define (vector->list-r5rs vector-value)
  (let ((length (vector-length vector-value)))
    (let loop ((index 0)
               (result '()))
      (if (= index length)
          (reverse result)
          (loop
            (+ index 1)
            (cons
              (vector-ref vector-value index)
              result))))))


(define (list->vector-r5rs values)
  (let* ((length (length values))
         (result (make-vector length)))
    (let loop ((index 0)
               (rest values))
      (if (null? rest)
          result
          (begin
            (vector-set!
              result
              index
              (car rest))
            (loop
              (+ index 1)
              (cdr rest)))))))


;; ============================================================
;; Copy helpers
;; ============================================================

(define (copy-member member)
  (make-member
    (member-name member)
    (member-type member)
    (member-value member)
    (member-owner member)))


(define (copy-member-vector vector-value)
  (let* ((length
           (vector-length vector-value))
         (result
           (make-vector length)))
    (let loop ((index 0))
      (if (= index length)
          result
          (begin
            (vector-set!
              result
              index
              (copy-member
                (vector-ref vector-value index)))
            (loop (+ index 1)))))))


(define (copy-environment environment)
  (copy-member-vector environment))


;; ============================================================
;; Generic member lookup
;; ============================================================

(define (find-member environment name)
  (let ((length
          (vector-length environment)))
    (let loop ((index 0))
      (cond
        ((= index length)
         #f)

        ((eq?
           (member-name
             (vector-ref environment index))
           name)
         (vector-ref environment index))

        (else
         (loop (+ index 1)))))))


(define (find-owned-member
          environment
          owner
          name)
  (let ((length
          (vector-length environment)))
    (let loop ((index 0))
      (if (= index length)
          #f
          (let ((member
                  (vector-ref
                    environment
                    index)))
            (if
              (and
                (eq?
                  (member-owner member)
                  owner)
                (eq?
                  (member-name member)
                  name))
              member
              (loop (+ index 1))))))))


;; ============================================================
;; Class hierarchy
;; ============================================================

(define (class-hierarchy class)
  (if (not class)
      '()
      (append
        (class-hierarchy
          (class-parent class))
        (list class))))


(define (class-is-a? class target)
  (cond
    ((not class)
     #f)

    ((eq? class target)
     #t)

    (else
     (class-is-a?
       (class-parent class)
       target))))


(define (find-class-in-chain class name)
  (cond
    ((not class)
     #f)

    ((eq?
       (class-name class)
       name)
     class)

    (else
     (find-class-in-chain
       (class-parent class)
       name))))


;; ============================================================
;; Instance member collection
;;
;; Parent and child declarations are both preserved.
;; Their OWNER distinguishes inheritance layers.
;; ============================================================

(define (collect-instance-members class)
  (let ((hierarchy
          (class-hierarchy class)))
    (let loop-classes
         ((classes hierarchy)
          (result '()))
      (if (null? classes)
          result
          (let ((members
                  (vector->list-r5rs
                    (class-instance-members
                      (car classes)))))
            (loop-classes
              (cdr classes)
              (append
                result
                (map copy-member members))))))))


;; ============================================================
;; Object construction
;;
;; Object is still a vector of member records.
;; The first reserved member points at the most-derived class.
;; ============================================================

(define (make-object-from-class class)
  (list->vector-r5rs
    (cons
      (make-member
        '__object-class__
        type-object-class
        class
        #f)
      (collect-instance-members class))))


(define (object-class object)
  (let ((member
          (find-member
            object
            '__object-class__)))
    (if member
        (member-value member)
        #f)))


;; ============================================================
;; Instance lookup with overriding
;;
;; Start from leaf and walk up.
;; ============================================================

(define (lookup-instance-member
          object
          class
          name)
  (if (not class)
      #f
      (let ((member
              (find-owned-member
                object
                (class-name class)
                name)))
        (if member
            member
            (lookup-instance-member
              object
              (class-parent class)
              name)))))


;; ============================================================
;; Static lookup with inheritance
;; ============================================================

(define (lookup-static-member
          class
          name)
  (if (not class)
      #f
      (let ((member
              (find-member
                (class-static-members class)
                name)))
        (if member
            member
            (lookup-static-member
              (class-parent class)
              name)))))


;; ============================================================
;; Interface validation
;; ============================================================

(define (method-description-matches-interface?
          description
          requirement)
  (and
    (type-list=?
      (method-description-parameter-types
        description)
      (interface-method-parameter-types
        requirement))
    (type-description=?
      (method-description-return-type
        description)
      (interface-method-return-type
        requirement))))


(define (object-satisfies-interface?
          object
          interface)
  (let* ((class
           (object-class object))
         (fields
           (interface-definition-fields interface))
         (methods
           (interface-definition-methods interface)))

    (define (fields-ok? index)
      (if (= index
             (vector-length fields))
          #t
          (let* ((requirement
                   (vector-ref fields index))
                 (member
                   (lookup-instance-member
                     object
                     class
                     (interface-field-name
                       requirement))))
            (and
              member
              (not
                (eq?
                  (member-type member)
                  type-method))
              (type-description=?
                (member-type member)
                (interface-field-type requirement))
              (fields-ok?
                (+ index 1))))))

    (define (methods-ok? index)
      (if (= index
             (vector-length methods))
          #t
          (let* ((requirement
                   (vector-ref methods index))
                 (member
                   (lookup-instance-member
                     object
                     class
                     (interface-method-name
                       requirement))))
            (and
              member
              (eq?
                (member-type member)
                type-method)
              (method-description?
                (member-value member))
              (method-description-matches-interface?
                (member-value member)
                requirement)
              (methods-ok?
                (+ index 1))))))

    (and
      (fields-ok? 0)
      (methods-ok? 0))))


(define (validate-class-interfaces!
          object)
  (let loop-class
       ((class
          (object-class object)))
    (if (not class)
        #t
        (let ((interfaces
                (class-interfaces class)))
          (let loop-interface
               ((index 0))
            (cond
              ((= index
                  (vector-length interfaces))
               (loop-class
                 (class-parent class)))

              ((object-satisfies-interface?
                 object
                 (vector-ref interfaces index))
               (loop-interface
                 (+ index 1)))

              (else
               (oo-error
                 "Object does not satisfy declared interface"
                 (interface-definition-name
                   (vector-ref
                     interfaces
                     index))))))))))


;; ============================================================
;; Typed function call
;; ============================================================

(define (typed-function-call
          function
          . arguments)
  (cond
    ((not
       (typed-function? function))
     (oo-error
       "Value is not a typed function"
       function))

    ((not
       (arguments-match?
         (typed-function-parameter-types function)
         arguments))
     (oo-error
       "Typed function argument mismatch"
       arguments))

    (else
     (let ((result
             (apply
               (typed-function-procedure function)
               arguments)))
       (if
         (value-matches-type?
           (typed-function-return-type function)
           result)
         result
         (oo-error
           "Typed function return mismatch"
           result))))))
```
- Harald Glab-Plhak
- Computer Science since 1992

- &copy; Harald Glab-Plhak (2026)
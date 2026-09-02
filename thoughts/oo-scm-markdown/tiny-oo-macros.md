###### [Go back](../traveling-through-comp-scienceP3.html)

```scheme
;; ============================================================
;; tiny-oo-macros.scm
;; R5RS + SRFI-9
;;
;; Surface syntax / define-syntax layer
;;
;; Load order:
;;   1. tiny-oo-model.scm
;;   2. tiny-oo-runtime.scm
;;   3. tiny-oo-macros.scm
;; ============================================================

;; ------------------------------------------------------------
;; typed-fun
;;
;; Example:
;;
;;   (typed-fun
;;     (long string)
;;     boolean
;;     (lambda (x s) ...))
;;
;; Creates a typed callable value suitable for typed parameters.
;; ------------------------------------------------------------

(define-syntax typed-fun
  (syntax-rules ()
    ((_ (parameter-type ...)
        return-type
        procedure)
     (make-typed-function
       '(parameter-type ...)
       'return-type
       procedure))))


;; ------------------------------------------------------------
;; interface
;;
;; Example:
;;
;;   (interface Transformer
;;     (fields
;;       (value long))
;;     (methods
;;       (fun transform (long) long)
;;       (fun transform-with
;;            ((function (long) long))
;;            long)))
;; ------------------------------------------------------------

(define-syntax interface
  (syntax-rules (fields methods fun)
    ((_ interface-name
        (fields
          (field-name field-type)
          ...)
        (methods
          (fun method-name
               (parameter-type ...)
               return-type)
          ...))
     (define interface-name
       (make-interface-definition
         'interface-name
         (vector
           (make-interface-field
             'field-name
             'field-type)
           ...)
         (vector
           (make-interface-method
             'method-name
             '(parameter-type ...)
             'return-type)
           ...))))))


;; ------------------------------------------------------------
;; class
;;
;; Root class:
;;
;;   (class Object
;;     (interfaces)
;;     (fields
;;       (identifier string "Object"))
;;     (methods
;;       (fun get-id () string
;;         (lambda () ...)))
;;     (static-fields
;;       (count long 0))
;;     (static-methods
;;       (fun count-all () long
;;         (lambda () ...))))
;;
;; Derived class:
;;
;;   (class Animal
;;     (extends Object)
;;     (interfaces Printable)
;;     ...)
;;
;; ------------------------------------------------------------

(define-syntax class
  (syntax-rules
    (extends interfaces fields methods static-fields static-methods fun)

    ;; Derived class
    ((_ class-name
        (extends parent-name)
        (interfaces
          interface-name
          ...)
        (fields
          (field-name
            field-type
            field-value)
          ...)
        (methods
          (fun method-name
               (parameter-type ...)
               return-type
               method-code)
          ...)
        (static-fields
          (static-field-name
            static-field-type
            static-field-value)
          ...)
        (static-methods
          (fun static-method-name
               (static-parameter-type ...)
               static-return-type
               static-code)
          ...))

     (define class-name
       (make-class-definition
         'class-name
         parent-name
         (vector
           interface-name
           ...)
         (vector
           (make-member
             'field-name
             'field-type
             field-value
             'class-name)
           ...
           (make-member
             'method-name
             type-method
             (make-method-description
               'method-name
               '(parameter-type ...)
               'return-type
               method-code
               'class-name)
             'class-name)
           ...)
         (vector
           (make-member
             'static-field-name
             'static-field-type
             static-field-value
             'class-name)
           ...
           (make-member
             'static-method-name
             type-static-method
             (make-method-description
               'static-method-name
               '(static-parameter-type ...)
               'static-return-type
               static-code
               'class-name)
             'class-name)
           ...))))

    ;; Root class
    ((_ class-name
        (interfaces
          interface-name
          ...)
        (fields
          (field-name
            field-type
            field-value)
          ...)
        (methods
          (fun method-name
               (parameter-type ...)
               return-type
               method-code)
          ...)
        (static-fields
          (static-field-name
            static-field-type
            static-field-value)
          ...)
        (static-methods
          (fun static-method-name
               (static-parameter-type ...)
               static-return-type
               static-code)
          ...))

     (define class-name
       (make-class-definition
         'class-name
         #f
         (vector
           interface-name
           ...)
         (vector
           (make-member
             'field-name
             'field-type
             field-value
             'class-name)
           ...
           (make-member
             'method-name
             type-method
             (make-method-description
               'method-name
               '(parameter-type ...)
               'return-type
               method-code
               'class-name)
             'class-name)
           ...)
         (vector
           (make-member
             'static-field-name
             'static-field-type
             static-field-value
             'class-name)
           ...
           (make-member
             'static-method-name
             type-static-method
             (make-method-description
               'static-method-name
               '(static-parameter-type ...)
               'static-return-type
               static-code
               'class-name)
             'class-name)
           ...))))))


;; ------------------------------------------------------------
;; new
;;
;;   (new Dog)
;; ------------------------------------------------------------

(define-syntax new
  (syntax-rules ()
    ((_ class-name)
     (make-object-from-class class-name))))


;; ------------------------------------------------------------
;; send!
;;
;; Calls an instance method and rebinds the object variable
;; to the fresh object generation returned by SEND.
;;
;;   (send! dog set-name "Rex")
;; ------------------------------------------------------------

(define-syntax send!
  (syntax-rules ()
    ((_ object-variable
        method-name
        argument ...)
     (call-with-values
       (lambda ()
         (send
           object-variable
           'method-name
           argument ...))
       (lambda (result fresh-object)
         (set!
           object-variable
           fresh-object)
         result)))))


;; ------------------------------------------------------------
;; super
;;
;; Method:
;;   (super speak)
;;   (super add x y)
;;
;; Field:
;;   (super name)
;; ------------------------------------------------------------

(define-syntax super
  (syntax-rules ()
    ((_ name argument ...)
     (super-runtime
       'name
       argument ...))))


;; ------------------------------------------------------------
;; super-set!
;;
;;   (super-set! name "parent-value")
;; ------------------------------------------------------------

(define-syntax super-set!
  (syntax-rules ()
    ((_ name value)
     (super-set-runtime!
       'name
       value))))


;; ------------------------------------------------------------
;; static-ref
;;
;;   (static-ref Counter count)
;; ------------------------------------------------------------

(define-syntax static-ref
  (syntax-rules ()
    ((_ class-name member-name)
     (static-get-runtime
       class-name
       'member-name))))


;; ------------------------------------------------------------
;; static-set!
;;
;;   (static-set! Counter count 10)
;; ------------------------------------------------------------

(define-syntax static-set!
  (syntax-rules ()
    ((_ class-name member-name value)
     (static-set-runtime!
       class-name
       'member-name
       value))))


;; ------------------------------------------------------------
;; static-call
;;
;;   (static-call Counter reset)
;; ------------------------------------------------------------

(define-syntax static-call
  (syntax-rules ()
    ((_ class-name method-name argument ...)
     (apply
       static-send-runtime
       class-name
       'method-name
       (list argument ...)))))
```
- Harald Glab-Plhak
- Computer Science since 1992

- &copy; Harald Glab-Plhak (2026)
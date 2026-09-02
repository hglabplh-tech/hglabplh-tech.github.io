;; ============================================================
;; tiny-oo-runtime.scm
;; R5RS + SRFI-9
;;
;; Dynamic execution runtime:
;;
;;   * self
;;   * current defining class
;;   * copy-on-write instance generations
;;   * dynamic-wind instance dispatch
;;   * typed SEND checking
;;   * runtime interface verification
;;   * SUPER
;;   * static access/calls
;; ============================================================

;; ============================================================
;; Dynamic runtime context
;; ============================================================

(define *self* #f)
(define *current-class* #f)


;; ============================================================
;; Self field access
;; ============================================================

(define (self-get name)
  (if (not *self*)
      (oo-error
        "No active self"
        name)
      (let ((member
              (lookup-instance-member
                *self*
                (object-class *self*)
                name)))
        (cond
          ((not member)
           (oo-error
             "Unknown instance member"
             name))

          ((eq?
             (member-type member)
             type-method)
           (oo-error
             "Member is a method, not a field"
             name))

          (else
           (member-value member))))))


;; ============================================================
;; Copy-on-write field modification
;; ============================================================

(define (self-set! name value)
  (if (not *self*)
      (oo-error
        "No active self"
        name)
      (let* ((fresh
               (copy-environment
                 *self*))
             (member
               (lookup-instance-member
                 fresh
                 (object-class fresh)
                 name)))
        (cond
          ((not member)
           (oo-error
             "Unknown instance field"
             name))

          ((eq?
             (member-type member)
             type-method)
           (oo-error
             "Cannot assign to method"
             name))

          ((not
             (value-matches-type?
               (member-type member)
               value))
           (oo-error
             "Field type mismatch"
             name))

          (else
           (member-value-set!
             member
             value)
           (set!
             *self*
             fresh)
           value)))))


;; ============================================================
;; Invoke typed method descriptor
;;
;; Checks:
;;   * parameter count
;;   * parameter types
;;   * typed function signatures
;;   * return type
;;
;; Also installs the method's defining class so SUPER works.
;; ============================================================

(define (invoke-method
          member
          arguments)
  (let ((description
          (member-value member)))
    (if (not
          (method-description?
            description))
        (oo-error
          "Malformed method member"
          (member-name member))
        (if (not
              (arguments-match?
                (method-description-parameter-types
                  description)
                arguments))
            (oo-error
              "Method argument signature mismatch"
              (method-description-name
                description))
            (let ((old-current-class
                    *current-class*)
                  (result #f))
              (dynamic-wind

                ;; before
                (lambda ()
                  (set!
                    *current-class*
                    (find-class-in-chain
                      (object-class *self*)
                      (method-description-owner
                        description))))

                ;; body
                (lambda ()
                  (set!
                    result
                    (apply
                      (method-description-code
                        description)
                      arguments)))

                ;; after
                (lambda ()
                  (set!
                    *current-class*
                    old-current-class)))

              (if
                (value-matches-type?
                  (method-description-return-type
                    description)
                  result)
                result
                (oo-error
                  "Method return type mismatch"
                  (method-description-name
                    description))))))))


;; ============================================================
;; Internal dynamic dispatch:
;;
;;   self.method(...)
;; ============================================================

(define (self-send
          method-name
          . arguments)
  (if (not *self*)
      (oo-error
        "No active self"
        method-name)
      (let ((member
              (lookup-instance-member
                *self*
                (object-class *self*)
                method-name)))
        (cond
          ((not member)
           (oo-error
             "Unknown method"
             method-name))

          ((not
             (eq?
               (member-type member)
               type-method))
           (oo-error
             "Member is not a method"
             method-name))

          (else
           (invoke-method
             member
             arguments))))))


;; ============================================================
;; SUPER
;;
;; Starts at parent(current defining class).
;;
;; Method:
;;   (super-runtime 'speak)
;;
;; Field:
;;   (super-runtime 'name)
;; ============================================================

(define (super-runtime
          name
          . arguments)
  (cond
    ((not *self*)
     (oo-error
       "SUPER used outside instance method"
       name))

    ((not *current-class*)
     (oo-error
       "SUPER has no defining class context"
       name))

    (else
     (let* ((parent
              (class-parent
                *current-class*))
            (member
              (lookup-instance-member
                *self*
                parent
                name)))
       (cond
         ((not member)
          (oo-error
            "No superclass member"
            name))

         ((eq?
            (member-type member)
            type-method)
          (invoke-method
            member
            arguments))

         ((null? arguments)
          (member-value member))

         (else
          (oo-error
            "Superclass field does not accept parameters"
            name)))))))


;; ============================================================
;; SUPER field modification
;; ============================================================

(define (super-set-runtime!
          name
          value)
  (cond
    ((not *self*)
     (oo-error
       "SUPER-SET! outside instance method"
       name))

    ((not *current-class*)
     (oo-error
       "SUPER-SET! has no defining class context"
       name))

    (else
     (let* ((fresh
              (copy-environment
                *self*))
            (parent
              (class-parent
                *current-class*))
            (member
              (lookup-instance-member
                fresh
                parent
                name)))
       (cond
         ((not member)
          (oo-error
            "No superclass field"
            name))

         ((eq?
            (member-type member)
            type-method)
          (oo-error
            "Superclass member is a method"
            name))

         ((not
            (value-matches-type?
              (member-type member)
              value))
          (oo-error
            "Superclass field type mismatch"
            name))

         (else
          (member-value-set!
            member
            value)
          (set!
            *self*
            fresh)
          value))))))


;; ============================================================
;; External SEND
;;
;; Steps:
;;
;;   1. fresh copy of object env
;;   2. install as SELF
;;   3. validate declared interfaces
;;   4. lookup method
;;   5. check method signature
;;   6. execute
;;   7. check return type
;;   8. return result + fresh object generation
;;   9. restore caller context with dynamic-wind
;; ============================================================

(define (send
          object
          method-name
          . arguments)
  (let ((old-self
          *self*)
        (old-current-class
          *current-class*)
        (result #f)
        (result-environment object))

    (dynamic-wind

      ;; before
      (lambda ()
        (set!
          *self*
          (copy-environment
            object))
        (set!
          *current-class*
          #f))

      ;; body
      (lambda ()
        (if
          (validate-class-interfaces!
            *self*)
          (let ((member
                  (lookup-instance-member
                    *self*
                    (object-class *self*)
                    method-name)))
            (cond
              ((not member)
               (set!
                 result
                 (oo-error
                   "Unknown method"
                   method-name)))

              ((not
                 (eq?
                   (member-type member)
                   type-method))
               (set!
                 result
                 (oo-error
                   "Member is not a method"
                   method-name)))

              (else
               (set!
                 result
                 (invoke-method
                   member
                   arguments)))))
          (set!
            result
            #f))

        (set!
          result-environment
          *self*))

      ;; after
      (lambda ()
        (set!
          *self*
          old-self)
        (set!
          *current-class*
          old-current-class)))

    (values
      result
      result-environment)))


;; ============================================================
;; Static field read
;; ============================================================

(define (static-get-runtime
          class
          name)
  (let ((member
          (lookup-static-member
            class
            name)))
    (cond
      ((not member)
       (oo-error
         "Unknown static member"
         name))

      ((eq?
         (member-type member)
         type-static-method)
       (oo-error
         "Static member is a method"
         name))

      (else
       (member-value member)))))


;; ============================================================
;; Static field write
;;
;; Static environments are global/shared and mutable.
;; No dynamic-wind.
;; ============================================================

(define (static-set-runtime!
          class
          name
          value)
  (let ((member
          (lookup-static-member
            class
            name)))
    (cond
      ((not member)
       (oo-error
         "Unknown static field"
         name))

      ((eq?
         (member-type member)
         type-static-method)
       (oo-error
         "Cannot assign to static method"
         name))

      ((not
         (value-matches-type?
           (member-type member)
           value))
       (oo-error
         "Static field type mismatch"
         name))

      (else
       (member-value-set!
         member
         value)
       value))))


;; ============================================================
;; Static method call
;;
;; Static methods have typed descriptions too.
;; They do not use SELF and do not use dynamic-wind.
;; ============================================================

(define (static-send-runtime
          class
          method-name
          . arguments)
  (let ((member
          (lookup-static-member
            class
            method-name)))
    (cond
      ((not member)
       (oo-error
         "Unknown static method"
         method-name))

      ((not
         (eq?
           (member-type member)
           type-static-method))
       (oo-error
         "Static member is not a method"
         method-name))

      ((not
         (method-description?
           (member-value member)))
       (oo-error
         "Malformed static method"
         method-name))

      (else
       (let* ((description
                (member-value member))
              (parameter-types
                (method-description-parameter-types
                  description)))
         (if
           (not
             (arguments-match?
               parameter-types
               arguments))
           (oo-error
             "Static method argument signature mismatch"
             method-name)
           (let ((result
                   (apply
                     (method-description-code
                       description)
                     arguments)))
             (if
               (value-matches-type?
                 (method-description-return-type
                   description)
                 result)
               result
               (oo-error
                 "Static method return type mismatch"
                 method-name)))))))))


;; ============================================================
;; Optional direct object/class predicates
;; ============================================================

(define (oo-object? value)
  (and
    (vector? value)
    (object-class value)))


(define (instance-of?
          object
          class)
  (and
    (oo-object? object)
    (class-is-a?
      (object-class object)
      class)))

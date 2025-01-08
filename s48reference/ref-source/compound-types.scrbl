@(require
   scribble/manual scribble/eval
          (for-label lang/prim racket/gui/base                     
                     (only-in racket/contract any/c)
                     (only-in racket/class is-a?/c)))


@;---------------------------------------------------------------
@subsection[#:tag "vectors"]{Vectors}

@defproc[(vector->list [v vector?]) list?]{
                                 }

@defproc[(list->vector [l list?]) vector?]
  

(define (vector-fill! v x)
  (let ((z (vector-length v)))
    (do ((i 0 (+ i 1)))
        ((= i z) (unspecific))
      (vector-set! v i x))))


#lang scribble/base
@(require
   scribble/manual scribble/eval
          (for-label lang/prim racket/gui/base                     
                     (only-in racket/contract any/c)
                     (only-in racket/class is-a?/c)))


@;---------------------------------------------------------------
@subsection[#:tag "vectors"]{Vectors}

@defproc[(vector->list [v vector?]) list?]{
This function converts a given vector to a list and returns the list                                         
                                 }

@defproc[(list->vector [l list?]) vector?]{
This function converts a givenlist to a vector and returns the  vector
                                            }
  

@defproc[(vector-fill! [v vector?] [x  any/c]) unspecific]{
                 
}


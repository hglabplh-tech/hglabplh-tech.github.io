#lang scribble/doc

@(require scribble/manual scribble/eval
          (for-label lang/prim lang/imageeq lang/posn racket/gui/base
                     (only-in racket/contract any/c)
                     (only-in racket/class is-a?/c)))

@title{Scheme48 Reference}

@; ------------------------------------------------------------
@section{@italic{Lambda} Lambda Expressions}

@defproc*[([(define <id>
              <expr>)])
          (<epr> -> (lambda  opt-lambda  <function> ))]
                    

 @racket[id].  The window is
@racket[horiz] pixels wide and @racket[vert] pixels high.  For
backward compatibility, a single @racket[posn] value can be submitted
in the place of @racket[horiz] and @racket[vert].  The result is a
viewport descriptor.}
#lang scribble/doc
@(require
   scribble-include-text
   scribble/manual scribble/eval        
          (for-label scheme))



@; ------------------------------------------------------------
@section{Lambda Expressions}

{First of all we need some keyword which gives the possibility
to define something on top level this is in our case the define function
}

@scheme[([(define <id>
              <expr>)])
          (<epr> -> (lambda (<parameters>) <function-body> )
                     (opt-lambda (<parameters>) <function-body> )
                     <value>)]
                    

{@racket[id].  The window is
@racket[horiz] pixels wide and @racket[vert] pixels high.  For
backward compatibility, a single @racket[posn] value can be submitted
in the place of @racket[horiz] and @racket[vert].  The result is a
viewport descriptor.}
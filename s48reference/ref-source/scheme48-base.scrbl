#lang scribble/base
@(require
   scribble/manual scribble/eval
          (for-label lang/prim lang/imageeq lang/posn racket/gui/base
                     (only-in racket/contract any/c)
                     (only-in racket/class is-a?/c)))



@author[(author+email "Harald Glab-Plhak" "hglabplhak@gmail.com")]

@; ------------------------------------------------------------
@section{Bindings Examples}
Bindings are essetial because the values we use in the program have to be bound in the environment.
There are different levels of bindings in Scheme
Level 0: Toplevel
Level 1: after a function call from top level
.
.
.
Level n
The environment has 1..n generations starting at Top Level.

@defproc[(define (binding value)) any?/c]{
The define is to make a top level binding to the top level environment
}

Example:
@racketblock[(define the-string "string")]
Here the string "string" is bound to the-string so that now the id the-string has the value string 

@racketblock[(define (the-fun arg1 ...))]

Here a procedure higher order function is defined the function binding can be treated completely
like a variable. It can be a argument / parameter and so on.
@racketblock[(let ([id value]...) body) function?]
With let a few pairs can be defined as bindings which are after that valid inside the body of let
a body defined with let can also be called anonymous
@racketblock[((let ([a 5 ][b 6 ][c 7]) body))]



    

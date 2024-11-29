#lang scribble/doc
@(require
   scribble/manual scribble/eval
          (for-label lang/prim lang/imageeq lang/posn racket/gui/base
                     (only-in racket/contract any/c)
                     (only-in racket/class is-a?/c)))



@author[(author+email "Harald Glab-Plhak" "hglabplhak@gmail.com")]

@; ------------------------------------------------------------
@section{Bindings Examples}
Here we define the potential environment operations for bindings:


@racketblock[(define add 'add)
(define remove 'remove)
(define push-frame 'push-frame)
(define pop-frame 'pop-frame)]

Have a look how such functionality may be defined

@defproc[(binding [id string?] [value any?/c]) function?]{
This function takes a id as first parameter and any value function or another binding as second parameter
and returns a function containing the binding
}

Example:
@racketblock[(define binding (lambda (id value)
                  (let ([int-id id]
                        [int-value value])
                  (lambda ()
                    (cons int-id int-value)))))]

@defproc[(frame-it [frame list?] [binding cons?]) list?]{
This function takes a frame and a new binding and adds the binding to the frame newly created
and given back so the binding is part of this frame which normaly is the actual environment level
}

Example:
@racketblock[(define frame-it (lambda (frame binding)
                (let ([new-frame (append frame (list binding))])
                  new-frame)))]


@defproc[(environment) function?]{
This function takes no arguments it is the function to return a function representing the quasi singleton
of an environment which holds the frames and inside the frame the stack and the bindings which are newly
created entering a new block and the existing block is pushed back after leaving the block the
actual environent is thrown away and the last environment (frame) is popped from stack 

}

Example:
@racketblock[(define environment (lambda ()
  (let ([act-frame (frame-it 'dummy 'new-val)]
        [frames (list)]
        )
  (lambda (cmd id value)
    (cond ((eq? cmd add)
        (set! act-frame (frame-it act-frame id value)))
          ((eq? cmd remove)
           'none) ;; here will be the remove function
          ((eq? cmd push-frame)
           (begin
               (set! frames (append frames act-frame))
               (set! act-frame (frame-it 'dummy 'new-val))))
          )))))]

This example is not complete but you can see a bit how bindings frames and different levels of environments can be handled if you
are interested to learn more about this mechanismn you can read for example the articles of Mr. Landine about the SECD machine concept
             
             
           
          
        
    
  
  





    

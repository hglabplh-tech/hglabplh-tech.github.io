#lang scribble/doc
@(require scribble/manual scribble/eval
          (for-label lang/prim lang/imageeq lang/posn racket/gui/base
                     (only-in racket/contract any/c)
                     (only-in racket/class is-a?/c)))

@title{Binding Example - Reference}

@; ------------------------------------------------------------


@racketblock[(define add 'add)
(define remove 'remove)
(define push-frame 'push-frame)
(define pop-frame 'pop-frame)


(define binding (lambda (id value)
                  (let ([int-id id]
                        [int-value value])
                  (lambda ()
                    (cons int-id int-value)))))
  
(define frame-it (lambda (frame binding)
                (let ([new-frame (append frame (list binding))])
                  new-frame)))
                  
(define environment (lambda ()
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
             
             
           
          
        
    
  
  





    

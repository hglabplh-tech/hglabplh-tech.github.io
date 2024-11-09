#lang scribble/doc
@(require
   scribble/manual scribble/eval
          (for-label lang/prim lang/imageeq lang/posn racket/gui/base
                     (only-in racket/contract any/c)
                     (only-in racket/class is-a?/c)))

@title{Scheme 48 - Reference - Part II - Basics - Datatypes}

@; ------------------------------------------------------------
@section[#:tag "basetypes"]{The Datatypes - Primitives}

The basic datatypes like Integer , Boolean, Long, Float Double and the base functions

@defproc[(not [value any/c]) boolean?]{
This function takes a value as parameter and reverts the case of #t to #f
}

@defproc[(eqv? [x any/c] [y any/c]) boolean?]{
This function takes a first value x as first parameter and a second value x and compares them for equality
}

@defproc[(eqv? [x any/c] [y any/c]) boolean?]{
This function takes a first value x as first parameter and a second value x and compares them for equality
}

@defproc[(equal? [x any/c] [y any/c]) boolean?]{
This function takes a first value x as first parameter and a second value x and compares them for equality
}

@defproc[(max [first number?] [rest number?] ...) number?]{
This function takes a first value first as first parameter and a second or 0..n value(s) rest
And here the highest value is returned
}

@defproc[(min [first number?] [rest number?] ...) number?]{
This function takes a first value first as first parameter and a second or 0..n value(s) rest
And here the lowest value is returned
}

@defproc[(abs [num number?]) number?]{
This function takes a number and returns the absolute which is than positive
}

@defproc[(zero? [x number?]) boolean?]{
This function takes a nomber and checks if it is zero
}

@defproc[(positive? [x number?]) boolean?]{
This function takes a nomber and checks if it is positive
}

@defproc[(negative? [x number?]) boolean?]{
This function takes a nomber and checks if it is negative
}

@defproc[(even? [x number?]) boolean?]{
This function takes a nomber and checks if it is even
}

@defproc[(odd? [x number?]) boolean?]{
This function takes a nomber and checks if it is odd
}

@; ------------------------------------------------------------
@section[#:tag "listtypes"]{The Datatypes - List functions}

@defproc[(car [lst list?]) any/c]{
takes the first element of a list from start of the list
}

@defproc[(cdr [lst list?]) list?]{
takes the rest element(s) of a list all elements after the first element
}



Here are some abbreviations which can be useful:
@racketblock[(define (caar   x) (car (car x)))
(define (cadr   x) (car (cdr x)))
(define (cdar   x) (cdr (car x)))
(define (cddr   x) (cdr (cdr x)))

(define (caaar  x) (caar (car x)))
(define (caadr  x) (caar (cdr x)))
(define (cadar  x) (cadr (car x)))
(define (caddr  x) (cadr (cdr x)))
(define (cdaar  x) (cdar (car x)))
(define (cdadr  x) (cdar (cdr x)))
(define (cddar  x) (cddr (car x)))
(define (cdddr  x) (cddr (cdr x)))

(define (caaaar x) (caaar (car x)))
(define (caaadr x) (caaar (cdr x)))
(define (caadar x) (caadr (car x)))
(define (caaddr x) (caadr (cdr x)))
(define (cadaar x) (cadar (car x)))
(define (cadadr x) (cadar (cdr x)))
(define (caddar x) (caddr (car x)))
(define (cadddr x) (caddr (cdr x)))
(define (cdaaar x) (cdaar (car x)))
(define (cdaadr x) (cdaar (cdr x)))
(define (cdadar x) (cdadr (car x)))
(define (cdaddr x) (cdadr (cdr x)))
(define (cddaar x) (cddar (car x)))
(define (cddadr x) (cddar (cdr x)))
(define (cdddar x) (cdddr (car x)))
(define (cddddr x) (cdddr (cdr x)))
]

@defproc[(null? [x list?]) boolean?]{
checks if the list is empty '()                                     
}

@defproc[(list [x any/c] ...) boolean?]{
creates a list                                
}



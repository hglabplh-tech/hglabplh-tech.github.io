#lang scribble/doc
@(require
   scribble/manual scribble/eval
          (for-label lang/prim lang/imageeq lang/posn racket/gui/base
                     (only-in racket/contract any/c)
                     (only-in racket/class is-a?/c)))

@title{Scheme 48 - Reference - Part II - Basics - Datatypes}

@author[(author+email "Harald Glab-Plhak" "hglabplhak@gmail.com")]


@; ------------------------------------------------------------
@section[#:tag "basetypes"]{The Datatypes - Primitives}

The basic datatypes like Integer , Boolean, Long, Float Double and the base functions

@defproc[(not [value any/c]) boolean?]{
This function takes a value as parameter and reverts the case of #t to #f
}

@defproc[(eq? [x any/c] [y any/c]) boolean?]{
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
@section[#:tag "listtypes"]{The Datatypes - Pairs/Lists }

@defproc[(car [l list?]) any/c]{
takes the first element of a list from start of the list
}

@defproc[(cdr [l list?]) list?]{
takes the rest element(s) of a list all elements after the first element
}

@;---------------------------------------------------------------
@subsection[#:tag "pairs"]{Pairs}

@defproc[(cons [e1 any/c][e2 any/c])  pair?]{
constructs a pair out of two given elements to get a object
which is a @racket[pair?] as well as a @racket[list?]
}


@defproc[(pair? [element any/c])  pair?]{
Tests if the element is a pair
}
Examples:

@racket[(pair? (cons 5 6))-> #t
(pair? (list 5 6))-> #t
(pair? (list 5))-> #f
(pair? '(5  6))-> #t
(pair? '(5))-> #f
(pair? '())-> #f
(pair?  5)-> #f]


@;---------------------------------------------------------------
@subsection[#:tag "lists"]{Lists}


Here are some abbreviations which can be useful:

@defproc[(caar [x list?]) any/c]{
Implemented as:
@racket[(car (car x))]
}
@defproc[(cadr [x list?]) any/c]{
Implemented as:
@racket[(car (cdr x))]
}

@defproc[(cdar [x list?]) list?]{
Implemented as:
@racket[(cdr (car x))]
}

@defproc[(cddr [x list?]) list?]{
Implemented as:
@racket[(cdr (cdr x))]
}

@defproc[(caaar [x list?]) any/c]{
Implemented as:
@racket[(caar (car x))]
}

@defproc[(caadr [x list?]) any/c]{
Implemented as:
@racket[(cadr (car x))]
}

@defproc[(caddr [x list?]) list?]{
Implemented as:
@racket[(cddr (cdr x))]
}

@defproc[(cdaar [x list?]) any/c]{
Implemented as:
@racket[(cdar (car x))]
}

@defproc[(cdadr [x list?]) list?]{
Implemented as:
@racket[(cdar (cdr x))]
}

@defproc[(cddar [x list?]) any/c]{
Implemented as:
@racket[(cddr (car x))]
}

@defproc[(cdddr [x list?]) list?]{
Implemented as:
@racket[(cddr (cdr x))]
}

@defproc[(caaaar [x list?]) any/c]{
Implemented as:
@racket[(caaar (car x))]
}

@defproc[(caaadr [x list?]) list?]{
Implemented as:
@racket[(caaar (cdr x))]
}

@defproc[(caadar [x list?]) any/c]{
Implemented as:
@racket[(caadr (car x))]
}

@defproc[(caaddr [x list?]) list?]{
Implemented as:
@racket[(caadr (cdr x))]
}
@defproc[(cadaar [x list?]) any/c]{
Implemented as:
@racket[(cadar (car x))]
}


@defproc[(cadadr [x list?]) list?]{
Implemented as:
@racket[(cadar (cdr x))]
}

@defproc[(cdaadr [x list?]) list?]{
Implemented as:
@racket[(cdaar (cdr x))]
}

@defproc[(cdadar [x list?]) any/c]{
Implemented as:
@racket[(cdadr (car x))]
}

@defproc[(cddaar [x list?]) any/c]{
Implemented as:
@racket[(cddar (car x))]
}

@defproc[(cddadr [x list?]) list?]{
Implemented as:
@racket[(cddar (cdr x))]
}

@defproc[(cddaar [x list?]) any/c]{
Implemented as:
@racket[(cddar (car x))]
}


@defproc[(cdddar [x list?]) any/c]{
Implemented as:
@racket[(cdddr (car x))]
}

@defproc[(cddddr [x list?]) list?]{
Implemented as:
@racket[(cdddr (cdr x))]
}

@defproc[(null? [l list?]) boolean?]{
checks if the list is empty '()                                     
}

@defproc[(list [x any/c] ...) list?]{
creates a list                                
}

@defproc[(length [l list?]) integer?]{
the effective length of a list (element count)                               
}

@defproc[(append [l list? ][lists list?] ...) list?]{
append lists to a list and return the result                           
}

@defproc[(reverse [l list?]) list?]{
reverts the order of the elements in a list
}

@defproc[(list-tail [l list?] [index integer?]) list?]{
returns the tailing list of the list up from index
}

@defproc[(list-ref [l list?] [index integer?]) any/c]{
returns the element at index
}

@defproc[(member [v any/c] [l list?]) (or/c #f list?)]{
Locates the first element of the list that is equal to v according to @racket[equal?].
 If such an element exists, the tail of lst starting
 with that element is returned. Otherwise, the result is @racket[#f].
}

@defproc[(memq [v any/c] [l list?]) (or/c #f list?)]{
Same as @racket[member] with the difference that @racket[eq?] is used
 instead of @racket[equal?] 
                                                       }

@defproc[(memv [v any/c] [l list?]) (or/c #f list?)]{
Same as @racket[member] with the difference that @racket[eqv?] is used
 instead of @racket[equal?] 
                                                       }


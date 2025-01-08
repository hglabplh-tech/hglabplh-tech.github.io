@(require
   scribble/manual scribble/eval
          (for-label scheme))


@author[(author+email "Harald Glab-Plhak" "hglabplhak@gmail.com")]

@; ------------------------------------------------------------
@section[#:tag "basetypes_definitions"]{The Datatypes - primitives / base types}



@; ------------------------------------------------------------
@section[#:tag "basetypes_functions"]{The Datatypes - functions}

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

 @defproc[(assoc [v any/c] [l (listof pair?)]) (or/c pair? #f)]{
Locates the first pair of the list where the key is @racket[equal?]
to v and returns it if no match is found it returns @racket[#f]  
}

@defproc[(assq [v any/c] [l (listof pair?)]) (or/c pair? #f)]{
Same as @racket[assoc] with the difference that @racket[eq?] is used
 instead of @racket[equal?] 
                                                       }

@defproc[(assv [v any/c] [l (listof pair?)]) (or/c pair? #f)]{
Same as @racket[assoc] with the difference that @racket[eqv?] is used
 instead of @racket[equal?] 

}

@defproc[(list? [thing any/c] ) (boolean?)]{
Ask if thing is a list
                    }


@;---------------------------------------------------------------
@subsection[#:tag "characters"]{Characters}

@defproc[(char<? [first char?] [second char?]) (boolean?)]{
Look if first char is smaller than second char
                                                         }

@defproc[(char>? [first char?] [second char?]) (boolean?)]{
Look if first char is greater than second char
                                                         }

@defproc[(char<=? [first char?] [second char?]) (boolean?)]{
Look if first char is smaller or equal second char
                                                         }

@defproc[(char>=? [first char?] [second char?]) (boolean?)]{
Look if first char is greater or equal second char
}


@;---------------------------------------------------------------
@subsection[#:tag "strings"]{Strings}


@defproc[(string ...) (string?)]{
 define a string out of strings                         
                         }
  

@defproc[(substring [str string?] [start integer?] [end integer?]) (string?)]{
 The substring of @scheme[str] starting with @scheme[start] offset and ending @scheme[end] offset
}
  

@defproc[(string-append ...) (string?)]{
Concat one or more strings to one string

}

@defproc[(string-length [arg string?]) (integer?)]{
The length of @scheme[arg]
}

@defproc[(string-ref [str string?] [index integer?]) (char?)]{
The string reference of @scheme[str] at the index position @scheme[index]
 the return is the char at that position
}


@defproc[(string->list [arg string?]) (list?)]{
The string @scheme[arg] is converted to a list of chars
}

@defproc[(list->string [arg list?]) (string?)]{
The list of chars @scheme[arg] is converted to a string
}

@defproc[(string-fill! [v string?] [x char?]) (unspecific)]{
The string @scheme[v] is filled with the char @scheme[x]
}

@defproc[(string=? [str1 string?] [str2 string?]) (boolean?)]{
Ask if the string @scheme[str1] is case sensitive equal to @scheme[str2]
return @scheme[true] if it is or @scheme[false] if not
}

@defproc[(string<=? [str1 string?] [str2 string?]) (boolean?)]{
Ask if the string @scheme[str1] is case sensitive smaller than or equal to @scheme[str2]
return @scheme[true] if it is or @scheme[false] if not  
}

@defproc[(string>=? [str1 string?] [str2 string?]) (boolean?)]{
Ask if the string @scheme[str1] is case sensitive greater than or equal to @scheme[str2]
return @scheme[true] if it is or @scheme[false] if not  
}

@defproc[(string>? [str1 string?] [str2 string?]) (boolean?)]{
Ask if the string @scheme[str1] is case sensitive greater than @scheme[str2]
return @scheme[true] if it is or @scheme[false] if not  
}

@defproc[(string<? [str1 string?] [str2 string?]) (boolean?)]{
Ask if the string @scheme[str1] is case sensitive smaller than @scheme[str2]
return @scheme[true] if it is or @scheme[false] if not
}

@defproc[(string-ci=? [str1 string?] [str2 string?]) (boolean?)]{
Ask if the string @scheme[str1] is case insensitive equal to @scheme[str2]
return @scheme[true] if it is or @scheme[false] if not  
}

@defproc[(string-ci>=? [str1 string?] [str2 string?]) (boolean?)]{
Ask if the string @scheme[str1] is case insensitive greater than or equal to @scheme[str2]
return @scheme[true] if it is or @scheme[false] if not  
}

@defproc[(string-ci<=? [str1 string?] [str2 string?]) (boolean?)]{
Ask if the string @scheme[str1] is case insensitive smaller than or equal to @scheme[str2]
return @scheme[true] if it is or @scheme[false] if not  
}

@defproc[(string-ci<? [str1 string?] [str2 string?]) (boolean?)]{
Ask if the string @scheme[str1] is case insensitive smaller than @scheme[str2]
return @scheme[true] if it is or @scheme[false] if not  
}

@defproc[(string-ci>? [str1 string?] [str2 string?]) (boolean?)]{
Ask if the string @scheme[str1] is case insensitive greater than @scheme[str2]
return @scheme[true] if it is or @scheme[false] if not  
}





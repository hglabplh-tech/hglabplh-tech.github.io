#lang scribble/doc

@(require
   scribble/manual scribble/eval
          (for-label lang/prim racket/gui/base                     
                     (only-in racket/contract any/c)
                     (only-in racket/class is-a?/c)))


@title[#:style '(toc) #:tag "scheme48"]{Sprachebenen und Material zu @italic{Schreibe Dein Programm!}}

Note: This reference is to have a complete overview of Scheme 48 it's functionality
and the different API's
@italic{@link["http://www.s48.org"]{Scheme48 homepage / sources, documentation, links}}.

Das Material in diesem Handbuch ist für die Verwendung mit Buch
@italic{@link["http://www.s48.org"]{Scheme 48 homepage}}
gedacht.

@table-of-contents["Scheme 48 Reference"]

@include-section["scheme48-base.scrbl"]
@include-section["datatype.scrbl"]
@include-section["io-functions.scrbl"]
@include-section["compound-types.scrbl"]



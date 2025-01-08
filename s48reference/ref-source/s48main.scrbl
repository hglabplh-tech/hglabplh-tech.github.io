#lang scribble/doc

@(require
   scribble-include-text
   scribble/manual scribble/eval        
          (for-label scheme))             
                     
@author[(author+email "Harald Glab-Plhak" "hglabplhak@gmail.com")

@title[#:style '(toc) #:tag "scheme48"]{Language Reference @italic{Scheme 48}}

Note: This reference is to have a complete overview of Scheme 48 it's base types, functionality
and the different API's
@italic{@link["http://www.s48.org"]{Scheme48 homepage / sources, documentation, links}}.

@table-of-contents[]

@include-text["./scheme48-base.scrbl"]
@include-text["./lambda-expr.scrbl"]
@include-text["./datatypes.scrbl"]
@include-text["./compound-types.scrbl"]
@include-text["./control-features.scrbl"]
@include-text["./io-functions.scrbl"]




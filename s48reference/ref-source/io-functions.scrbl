#lang scribble/base
@(require
   scribble/manual scribble/eval
          (for-label lang/prim racket/gui/base                     
                     (only-in racket/contract any/c)
                     (only-in racket/class is-a?/c)))


@author[(author+email "Harald Glab-Plhak" "hglabplhak@gmail.com")]

@; ------------------------------------------------------------
@section[#:tag "file_in_out_base"]{The Basic File Input / Output / Open / Read / Write  - Scheme48 IO - functions / definitions}

General definitions and functions for S48 Base File I/O



@; ------------------------------------------------------------
@section[#:tag "channel_port_in_out"]{The Channel and Port Scheme48 IO - functions / definitions}

The exported functions and datatypes for channel and port I/O


@; ------------------------------------------------------------
@section[#:tag "text_codecs"]{The Text Codecs of Scheme48 - functions / definitions}

The exported functions and datatypes for text character set codecs

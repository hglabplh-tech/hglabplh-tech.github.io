#lang scribble/base
@(require
   scribble/manual scribble/eval
          (for-label scheme))
@author[(author+email "Harald Glab-Plhak" "hglabplhak@gmail.com")]

@; ------------------------------------------------------------
@section[#:tag "r6rs_gbvector"]{The R6RS General byte-vector functions}

@; ------------------------------------------------------------
@section[#:tag "r6rs_string-bvector"]{The R6RS byte-vector / string funcions}}
@defproc[(string->utf8 [in string?]) bytevector?]{
Function to transform a string to a utf8 encoded bytevector
}

@defproc[(string->utf16 [in string?]) bytevector?]{
Function to transform a string to a utf16 encoded bytevector
}

@defproc[(string->utf32 [in string?]) bytevector?]{
Function to transform a string to a utf32 encoded bytevector
}

@defproc[(utf8->string [in bytevector?]) string?]{
Function to transform a utf8 encoded bytevector to a string
}

@defproc[(utf16->string [in bytevector?]) string?]{
Function to transform a utf16 encoded bytevector to a string
}

@defproc[(utf32->string [in bytevector?]) string?]{
Function to transform a utf32 encoded bytevector to a string
}
@; ------------------------------------------------------------
@section[#:tag "r6rs_bvect-ieee"]{The R6RS byte-vector / IEEE functions}}
REMARK!!: The float functions need 4 bytes in the vector or refer to the next four bytes up from index.
The double need 8 bytes in the vector or refer to the next eight bytes up from index 
@defproc[(bytevector-ieee-single-native-ref (bvect bytevector?) (k integer?)) float?]{
Transform a bytevector from index (k) to float via native function float -> system IEEE 
}
@defproc[(bytevector-ieee-single-ref (bvect bytevector?) (k integer?) (endness endian?)) float?]{
Transform a bytevector from index (k) and endian to float
}

@defproc[(bytevector-ieee-single-native-set! (k integer?) (x float?)) any/c]{
Transform a float (x) to a bytevector part from index (k) the return is unspecific                                                
}

@defproc[(bytevector-ieee-single-set! (k integer?) (x float?) (endness endian?)) any/c]{
Transform a float (x) to a bytevector part from index (k) with endness (little-endian / big-endian) the return is unspecific                             
}

@defproc[(bytevector-ieee-double-native-ref (bvect bytevector?) (k integer?)) double?]{
Transform a bytevector from index (k) to double via native function float -> system IEEE 
}

@defproc[(bytevector-ieee-double-ref (bvect bytevector?) (k integer?) (endness endian?)) double? ]{
                                         
}

@defproc[(bytevector-ieee-double-native-set! (k integer?) (x double?)) any/c]{

}

@defproc[(bytevector-ieee-double-set!  (k integer?) (x double?) (endness endian?)) any/c]{
}
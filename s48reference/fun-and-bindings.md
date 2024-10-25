#### The Scheme48 bindings concept
##### A binding is NOT an assignement !!! And why do not assign


##### How bindings work
Like LISP **Scheme48** has a _REPL_ (Read Eval Print Loop)
The code is running inside this _REPL_ the _REPL_ itself
comes with an environment this environment contains bindings
for example the functionality to bind something on let's call
top level is bound as `define` in the environment of the _REPL_
But take care: each binding can be overwritten in the next level.
We have a top level and if we e.g. enter a function and use a `let` ??? One level forgotten !!!!
the next level is reached. The function gets the top level environment 
and the `let`pushes this environment to stack and introduces its own
environment. Of course this environment has his own bindings but if a thing 
cannot be found on that level the bindings of the next higher level are scanned
if the binding is found the search returns it in our case this next level is the 
top level so if it is not found there the VM returns `unbound identifier`
This for sure works with more than one level.
Let us have a look at an example because if the binding concept is 
not clear to you how it works you will run in trouble you can't imagine:  

REPL(define, let, letrec) / Env 0 -> (define a 6) (define b 8) / Env 1 -> (lambda (a b)) 
/ Env 2 inside lambda (let([a 89]
[b 80]) /Env 3)
)))
In each new environment a , b are defined so that the definition in the previous 
environment is hidden but since the environment is restored after leaving the scope of 
a lambda / let e.g. the old value appears again in the definition of the previous environment
on the other side like i said if you try in the example asking for  the expression c the 
trace back will see that c is not defined in any environment and this 
leads to a not founnd error. 


#### Functions in Scheme48

A function in **Scheme48** is a form defining what should happen in that place.
How the function is really processed depends on the state of the environment 
when calling the function. In scheme all operators even the so called 
primitives are functions usable as **_'first class'_** functions. They can be returned 
by another function or can be given as parameter. A function can have a name 
or can be anonymous.

Here a function with a name simply adding two numbers:
```Scheme
(define adder-fun
  (lambda (x y)                 
    (+ x y)))
;;and now use it as parameter for
(define test-adder-fun 
  (lambda (a b x y math-fun)
    (* a b (math-fun x y))))

;; now do the call
(test-adder-fun 5 6 4 2 adder-fun) 

```

And here the same function given back anonymous

```Scheme 
(define get-adder-fun 
  (lambda ()
    (lambda (x y)
      (+ x y))             
    ))
;; if called the function is returned
(define myfun (get-adder-fun))
;; now the anonymous function is bound to the variable myfun
```
Now inside a function it may happen that you need local bindings 
this can be done using the keyword `let` it looks for example like

```Scheme
(let ([a 10]
       [b 9]
       )
... do something)
```

Here a is bound to the value 10.
And b is bound to the value 8.

You can imagine the following statement is nearly like a let

```Scheme
((lambda (a b)
   do something
) 10 9)
```



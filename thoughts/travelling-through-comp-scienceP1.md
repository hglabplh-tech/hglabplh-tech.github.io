###### [Goto top](../index.html)
###### [Go next](././travelling-through-comp-scienceP2.html)
###### [Go back](./index.html)

# An article about the history - how data and code design changed


## My coding / designing thoughts Part I - A walk through history


### My way of looking at code and data

When I learned computer science, I developed my own way to look at code, processing, and data that is processed

It started with the imperative way of looking at it. Dealing with languages like Pascal, C, PL/1, COBOL, and REXX (VM/CMS interpreter version), I started to look at the code as something manipulating a defined instance of data, and I learned to know data structures and a kind of streams and blocks:

#### "Streams" and "Blocks"

The first stream I looked at was stream-like file reading and reading files as "records" (meaning fixed-length blocks of 80 bytes / 72-byte punch/reader format). Unlike the text files on UNIX, these files had no line delimiter on the host, like '\n'.
But in most cases, it is unstructured data; text data is "structured" by processing it in code.

##### fixed length record data

With these fixed-length record files, there is a direct connection to the former puncher and reader formats, which can be emulated. 

##### variable length record data
The next step is a variable
Record length. Here the first 2 bytes tell the length.

#### How to structure one record 

total 80 byte (F 80)
###### Positions:
- 0..19 name
- 20..39 surname
- 40..54 street
- 55..74 city
- 75..80 postal code

You can imagine that the code to parse and structure for writing the changed record is a bit complicated, and it is sometimes annoying to code that way, even if the "structures" get more complex compound data.


#### Structured Data 

After that, I learned that programming languages can structure data. This can be done (I use ANSI C as an example language) by a structure like
You can also define these structures as a type.

```C
struct address {
	char* name;
	char* surname;
	char* street;
	char* city;
	char* postal-code;
}

typedef struct _BILL {
	int     rec_type;
	long 	part_number;
	char*	articel_name;
	int 	count;
	float   price;
	double  total; 
} BILL, PBILL*;

```

With this kind of data, a program can be better structured and more flexible; it handles complex compound data much better this way.

The next thing I learned was that, by the language feature 'BASED' in PL/1 (union in C does nearly the same), it is possible to have variants of data coming in the same storage that can be handled by simply adding a record type, and so there are more possibilities for what kind of data can appear in the same place.

Think about our BILL now we do that 

```C
typedef struct _BILL_FORM_1 {
	long 	part_number;
	char*	articel_name;
	int 	count;
	float   price;
	double  total; 
} BILL_FORM_1, *P;

typedef struct _BILL_FORM_2 {
	long 	liter;
	char*	articel_name;
	int 	count;
	float   price;
	double  total; 
} BILL_FORM_2;

```

And now comes the trick: Let's think the first type is 1 and the second type is 2

So we can do it like that (I found that fascinating):


```C
typedef union _BILL_DATA {
		BILL_FORM_1 bill_t_1;
		BILL_FORM_2 bill_t_2;
} BILL_DATA;

typedef struct _THE_BILL {
	int bill_type;
	BILL_DATA the_bill_data;
} THE_BILL

```

Thinking in those structures opened a completely new world because the logic was simpler. For example when deciding which record we need:

```C
switch (rec_type) {
	case 1:
		/* do something with BILL_FORM_1 */
		break;
	case 2:
		/* do something with BILL_FORM_2 */
		break;
	default:
		printf("%s", "error"); 
} 

```

The next thing, opening a new step of thinking about logic by handling complex data, started in the 1970s:

```
 :h1 id='intr'.Chapter 1:  Introduction
   :p.GML supported hierarchical containers, such as
   :ol.
   :li. Ordered lists (like this one),
   :li. Unordered lists, and
   :li. Definition lists
   :eol.
   as well as simple structures.
   :p.Markup minimization (later generalized and formalised in SGML),
   allowed the end-tags to be omitted for the "h1" and "p" elements.
```

This **GML**(General Markup Language) mutated to **SGML** (Structured General Markup Langage):

``` XML
<lines>
	<line>first line</line>
	<line>second line</line>
</lines>

```

Two standards were developed out of **SGML** -> **_XML_** and **_HTML_** (the well-known standards).

With this method, I thought ok now I can handle much more complex data with low effort, for the languages are parsed not by my own program, but there are parser libraries delivering a structured output, like for **_XML_** **DOM** parser (**DOM** -> Document Object Model)

This data is very good for some kind of structured data

The other thing I was excited about was relational data storage (**_DB2_**, my first Relational Database).

I think to explain the functionality of relational databases in that place is a bit to much.
I only showed these examples because this opened my mind to a new kind of programming and processing data

#### Data and functionality:

At one point in my career coding and designing in **ANSI C**, I reached a point where the logic was too complex to handle in a conventional way, so I thought, why not mix data and functionality in a structure? This was possible by using function pointers

 
```C
typedef struct _MIX_FUN_DAT {
	int a;
	int b;
	int (*add_pointer)(int,int);
} MIX_FUN_DAT, PMIX_FUN_DAT*

// Function definition
int addition(int x, int y) {
  return x + y;
}

int main () {
	MIX_FUN_DAT my_struct;
	my_struct.a = 7;
	my_struct.b = 9;
	my_struct.add_pointer = &addition;
	int result = (*my_struct.add_pointer)(my_struct.a, my_struct.b);
	// result is 16
}
````

Now what you see here is a very complicated way to add two integers, but let us see what happens if:

```C
typedef struct _MIX_FUN_DAT {
	_MIX_FUN_DAT *self;
	int a;
	int b;
	int (*add)(_MIX_FUN_DAT *self);
	void (*display_add_res)(_MIX_FUN_DAT *self);
} MIX_FUN_DAT, PMIX_FUN_DAT*

// function for add
int addition(PMIX_FUN_DAT self) {
  return (self->a + self->b);
}

// function for display
void display_addition_res(PMIX_FUN_DAT self) {
  int result = (*self->add)(self);
  printf("The result is: %d\n", result);
}



int main () {
	MIX_FUN_DAT my_struct;
	my_struct.self = &my_struct;
	my_struct.a = 7;
	my_struct.b = 9;
	my_struct.add_pointer = &addition;
	(*my_struct.display_add_res)(my_struct.self);
	int result = (*my_struct.add)(my_struct.self);
	// result is 16
}
````

Ok, now you can think about what you associate with that code. For me it is nearly 
like an object

And of course it is not far away from:

```C

typedef struct _FUN_AND_ENV {
	_FUN_AND_ENV *self;
	char** env; 
	int (*get_at)(_FUN_AND_ENV *self, int);
	char* (*concat)(_FUN_AND_ENV *self), int ,int);
} FUN_AND_ENV, PFUN_AND_ENV*


char* fun_get_at(PFUN_AND_ENV self, int index) {
	return self->env[index];
}

char* fun_concat(PFUN_AND_ENV self, int first, int second) {
	char* the_first = (*self->get_at)(first);
	char* the_first = (*self->get_at)(second);
	return strcat(the_first, the_second);
}


```

And finally, it should be clear how flexible this kind of structuring can be.

#### The way it went
Ok, I talked about how data were handled in former times. By structuring, code was also structured the same way with Nassi / Schneidermann. If you try to do that today, you will fail because in comparison to earlier times, there is a huge amount of data that has to be handled, and to be successful with that, the code is much more complex, and other ways to store data have changed more and more from local storage to distributed storage systems and Cloud storage. These architectures also require new ways to express application logic. Also, the most-used paradigms in software development have changed. Pure imperative languages have largely been replaced by object-oriented and/or functional languages. Even C++ (object oriented) is one of the languages built on top a imperative language in this case ANSI C. There are things like streaming libraries in Java / Python / C# and the structure of the data is often defined by data 'structures' like __JSON__(**J**ava **S**cript **O**bject **N**otation) or __XML__ (**E**xtended **M**arkup **L**anguage). But we often also need full-text search in RTF, WORD, PDF, or other formats. Here, libraries like Hadoop (Apache) come in. These tools search in an 'intelligent' way, like with backtracking, thesaurus, parsing PDF, fuzzy match, and/or AI. To see what I experienced as these strategies emerged, I invite you to read the next article about changes in application design. The object-oriented paradigm and what happens under the hood in object-oriented languages. And the same for the functional paradigm.

- Harald Glab-Plhak
- Computer Science since 1992

- &copy; Harald Glab-Plhak (2024-2026)





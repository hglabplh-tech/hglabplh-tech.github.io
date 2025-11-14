## My coding / designing thoughts Part I


### My way of looking at code and data

The time I learned computer science I developed my own way to look at code, processing and data which is processed

It started with the imperative way of looking at it. Dealing with languages like Pascal, C, PL/1, COBOL and REXX - (VM/CMS interpreter version) I started to look at the code as something manipulating a defined instance of data and I learned to know data structures and a kind of streams and blocks:

#### "Streams" and "Blocks"

The first stream I looked at was the stream like reading of files and the way of reading files as "records" (means fixed length blocks of 80 bytes / 72 bytes punch / reader format). Unlike the text files on UNIX this files had on the host no line delimiter like '\n'.
But it is unstructured data in most cases text data which is "structured" by the processing of the data inside the code.

##### fixed length record data

with this fixed length record files there is a direct connection to the former formats of puncher and reader can be emulated. 

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

You can imagine that the code to parse and structuring for writing the changed record is a bit complicated and it is sometimes annoying to code that way even if the "structures" get more complex compound data.


#### Structured Data 

After that I learned that with the features of the programming languages data can really be structured. This can be done (I use as example language ANSI C) by a structure like
This structures can also be defined as type.

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

With this kind of data a program could be made better structured and more flixible it is much better to handle complex compund data this way.

The next thing I learned was that by the language feature 'BASED' in PL/1 (union in C does nearly the same) it is possible to have variants of data comming in the same storage can be handled by simply add a record type and so there are more possibilities what kind of data can appear in the same place.

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

and now there comes the trick : Lets think the first type is 1 and the second type is 2

So we can do it like that (I found that faszinating):


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

Thinking in those structures opened a complete new world because the logic was more simple. For example when deciding which record we need:

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

The next thing opening a next step of thinking a logic by handling complex data started in the 1970:

```
 :h1 id='intr'.Chapter 1:  Introduction
   :p.GML supported hierarchical containers, such as
   :ol.
   :li.Ordered lists (like this one),
   :li.Unordered lists, and
   :li.Definition lists
   :eol.
   as well as simple structures.
   :p.Markup minimisation (later generalised and formalised in SGML),
   allowed the end-tags to be omitted for the "h1" and "p" elements.
```

This **GML**(General Markup Language) mutated to **SGML** (Structured General Markup Langage):

```XML
<lines>
	<line>first line</line>
	<line>second line</line>
</lines>

```

Two standards were developed out of **SGML** -> **_XML_** and **_HTML_** (the well known standards).

With this method I thought ok now I can handle much more complex data with low effort for the languages are parsed not by the own program but there are parser libraries delivering a structured output like for **_XML_** **DOM** parser (**DOM** -> Document Object Model)

This data is very good for some kind of structured data

The other thing I was excited about was relational storing data (**_DB2_** my first Relational Database).

I think to explain the functionality of relational databases in that place is a bit to much.
I only showed this examples because this opened my mind for a new kind of programming and processing data

#### Data and functionality:

At one point in my career coding and designing in **ANSI C** I came to the point where the logic was too complex to handle it straight in a conventional way so I thought by myself why not mixing data and functionality in a structure. This was possible by using function pointers

 
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

Now what you see here is a very complicated way to add two integers but let us see what happens if:

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

Ok now you can think about what you associate with that code. For me it is nearly 
like a object

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

And at last now it should be clear how flexible this kind of structuring can be used.

#### The way it went
Ok I talked about how data were handled in former times. By structuring also code was structured in the same way with Nassi / Schneidermann. If you try to do that today you will fail because at the one hand we have a very great amount of data and we have much more complex code. So also the view has changed. There are things like streaming libraries in Java / Python / C# and the structure of the data is often defined by data 'structures' like __JSON__(**J**ava **S**cript **O**bject **N**otation) or __XML__ (**E**xtended **M**arkup **L**anguage). But t is also often the case that we have to do some fulltext search in RTF, WORD, PDF, or other formats. Here libraries like Hadoop(Apache) take place. This tools search in an 'intelligent' way lke with backtracking Thesaurus, parsing PDF fuzzy match and/or KI.  


- Harald Glab-Plhak
- 03.05.1966 Computer Science since 1992

- &copy; Harald Glab-Plhak (2024, 2025)





# Preface

The aim of this post isn't to explore whether using macros as syntax extensions is practical, beneficial, or even a good idea. Rather, this post is designed to make these ideas known to those who are interested. Basic approaches to creating such syntax extensions are outlined throughout the post.

Note: although macros are styled in `SCREAMING_SNAKE_CASE` by convention, all macro definitions in this post that resemble keywords will be in `snake_case`.

# A Brief Introduction to Macros

This post assumes basic knowledge of what macros are, but for those that want a quick introduction: macros act as instructions to search for and replace some piece of code with another. Macros do not exist once the program is compiled, as they disappear once their job is done. More specifically, macros are a form of *compiler directive* or *preprocessor directive* that enable developers to assign symbols to pieces of (commonly used) source code. As the name suggests, these constructs perform their tasks before or during compile-time, hence their disappearance once the build process of the program is complete.

Macros in GML use the `#macro` directive, and function similarly to C macros. The most common application of macros in GML is to give synonyms to constants. Consider the following macro definition

```gmlext
#macro MESSAGE "hello world"
```

The symbol `MESSAGE` is the macro identifier and `"hello world"` is the piece of source code that the macro represents. Upon compilation, all occurrences of `MESSAGE` will be replaced with `"hello world"`.

The following sub-sections detail common pitfalls to macros that can be exploited in GML.

## The Precedence Problem

The term "precedence problem" has been borrowed from the official GNU C docs[^macro]. I'm a fan of this term because it clearly describes what the issue involves! Consider the following macro

```gmlext
#macro PRICE 5 + 8
```

Now suppose it is used in an expression such as

```gmlext
var tax = 0.2 * PRICE;
show_message("VAT: " + string(tax));
```

At first glance, the expected value of `tax` might be `2.6` since `20%` of `13` (`5 + 8`) is `2.6`. However, this is not the case. In fact, the value of `tax` ends up being `4`! The reason for this is that the macro `PRICE` interferes with the precedence of the expression. The compiler will expand the expression `0.2 * PRICE` into `0.2 * 5 + 8`, not `0.2 * (5 + 8)`. This can be problematic if not identified by the developer, as this behaviour can lead to difficult to diagnose bugs. To avoid this issue, the content of the `PRICE` macro should be wrapped in a grouping:

```gmlext
#macro PRICE (5 + 8)
```

Running this program again produces the desired result of `2.6`.

So how is this useful? There is some power here that can be exploited. For example, let an array `p` of player positions be of the form `[x1, y1, x2, y2, ...]`. To index this array and retrieve the x and y position of some player with the id of `i`, the following code may be used:

```gmlext
var posX = p[i * 2];
var posY = p[i * 2 + 1];
```

This code is clean, but macros may be used to help the code explain itself more clearly:

```gmlext
#macro X 2
#macro Y 2 + 1

var posX = p[i * X];
var posY = p[i * Y];
```

The macros `X` and `Y` can be thought of as "units" that apply some sort of transformation to the value `i`. The benefit of doing this the same reason macros are useful in the first place: potential human error in the source code can be reduced by reducing code duplication.

Although this example was cherry-picked, it does illustrate a practical use for this sort of behaviour.

## The Hygiene Problem

"Hygiene" with respect to macros refers to the possibility of macros strangely interacting with the program state outside of its definition. In other words, non-hygienic macros can create and access variables from outside of their scope. Consider the following example

```gmlext
#macro ENTER_BUNNY var bunny = "/(.U x U.) <(yuh)"

ENTER_BUNNY;
show_message(bunny); // ???
```

If macros in GML were hygienic, this code would complain that the variable `bunny` does not exist. However, the compiler just expands the `ENTER_BUNNY` macro and everything becomes balanced in the world:

```gmlext
var bunny = "/(.U x U.) <(yuh)";
show_message(bunny);
```

Macros are purposefully designed to be "dumb" in this way. They don't care about whether the syntax is valid or whether a variable is in scope, they just do their job and disappear.

Non-hygienic macros can be a useful tool for creating stateful macro definitions. Below is an example set of macros that return different names of fruit:

```gmlext
#macro FRUIT_BEGIN var fruits = ["pear", "grape", "apple", "mango"]
#macro FRUIT_OF_THE_DAY fruits[irandom(3)]

FRUIT_BEGIN;
show_message(FRUIT_OF_THE_DAY); // pear
show_message(FRUIT_OF_THE_DAY); // mango
show_message(FRUIT_OF_THE_DAY); // apple
show_message(FRUIT_OF_THE_DAY); // mango
```

# Keyword Aliases

A relatively simple class of syntax extensions (that can be created using macros) are aliases for existing keywords. For example, let's say a developer wants to use the word `elif` in place of any instance of `else if`. This can be achieved by creating a macro that maps from the synonym `elif` to the phrase `else if`; any occurrences of `elif` in the developer's codebase will behave as though `else if` were written instead:

```gmlext
#macro elif else if

var a = 1;
var b = 2;
if (a > b) {
  show_message("yes");
} elif (a == b) {
  show_message("no");
} else {
  show_message("maybe (.O _ O.)");
}
```

<br>

This sort of syntax extension is not particularly useful when applied to keywords. However, the same approach can be used with built-in constants and built-in functions! If a developer desires a shorter version of an existing function, then they can make use of macros to do so. For example, creating a shorter alias, `log`, for `show_debug_message`:

```gmlext
#macro log show_debug_message

log("wow, cool");
```

Although creating aliases for long functions is already quite useful, the next sub-section covers a wildly more useful feature of macros: overriding functions.

## Overriding Built-In Functions

One little known feature of macros is the ability to override built-in functions with a custom implementation. A particularly useful case for this is overriding `show_debug_message` so that it writes to a log file, rather than to the IDE console window. The process of logging debug messages to a file (or leaving "breadcrumbs") is very important for debugging issues encountered by users. This behaviour can be achieved by creating a macro where the function you want to override is the name of the macro:

```gmlext
#macro show_debug_message overrides_show_debug_message

function overrides_show_debug_message(str) {
  var file = file_text_open_append("game.log");
  file_text_write_string(file, str);
  file_text_writeln(file);
  file_text_close(file);
}
```

With this macro, any occurrences of `show_debug_message` will be replaced with `overrides_show_debug_message`. This results in all debug messages being written to an external file named `"game.log"`. However, be warned! Since all occurrences of `show_debug_message` are now replaced with the overriding function, any instance of `show_debug_message` inside the body of that function will cause it to enter an infinite loop (if not handled correctly). This is not immediately obvious, especially if the macro definition is in a separate file. For this reason, it's a pitfall to be aware of.

This same approach can be applied to other parts of GML, such as with built-in variables or constants. For example, the default colour for the literal, `c_red`, is very ugly, but it can be overridden to a [better shade](https://www.color-hex.com/color/d15864) using a macro:

```gmlext
#macro c_red make_colour_rgb(209, 88, 100)
```

As always, `c_red` will be replaced by the snippet of code, `make_colour_rgb(209, 88, 100)`.

# Custom Statements

Moving on from simple keyword aliases. This section covers three custom statements and walks through the different techniques of deriving them.

## Ignore

The first statement that has been [conjured up](https://twitter.com/katsaii/status/1306382870634795009) is `ignore`. The `ignore` statement is a simple construct with the power to prevent a block of code from being executed at runtime. This behaves somewhat similarly to comments, except syntax highlighting and IDE auto-completion are allowed. The example below pictures the ignore statement preventing an infinite loop, `while (true)`, from occurring:

```gmlext
show_message("this is shown");
ignore {
  show_message("this is ignored");
  while (true) {
    // repeat forever
  }
}
```

A common method of achieving this functionality is to replace `ignore` with `if (false)`, so perhaps this should also be the definition of `ignore`? For most intents and purposes that would be correct. However, according to that definition of `ignore`, the following snippet of code is valid:

```gmlext
#macro ignore if (false)

ignore {
  show_message("ignore me");
} else {
  get_funky();
}
```

Does it make sense for there to be an `else` clause on `ignore`, and if so, what would that even mean? Ideally, `ignore` should act by itself without allowing additional modifiers.

At this point, a little more creativity is needed. Of course, `if (false)` is not the only method of creating unreachable code. Other examples are shown below.

```gmlext
if (true) { } else {
  // ignore
}

while (false) {
  // ignore
}

for (;false;) {
  // ignore
}

repeat (0) {
  // ignore
}

with (noone) {
  // ignore
}

switch (0) {
case 0:
  break;
default:
  // ignore
  break;
}
```

At first glance, most of these options seem useful. However, two options completely outperform the rest: `if (true) { } else` and `for (;false;)`. This is because `while`, `until`, `repeat` and `with` statements are all susceptible to the same "attack;" that is, a partial expression, such as `|| true`, can be used to force the condition to evaluate to `true`. Thus unreachable code is suddenly able to be accessed. The benefit of `if (true) { } else` and `for (;false;)` is that neither of these candidates exposes a way for an external user to apply this attack. Specifically, `for` loops in GML are the only construct that requires a top-level grouping `()`, and `else` does not include a condition to exploit in the first place. Either one of these approaches will suit the `ignore` macro nicely. Ultimately, `if (true) { } else` was used in the following illustration for readability purposes:

```gmlext
#macro ignore if (true) { } else

ignore {
  show_message("ignore me");
}
// putting an `else` here will result in a syntax error, as intended
```

There you have it! A full-fat syntax extension that adds a new kind of statement to the language.

The next sub-section covers the `defer` statement, and how a sneaky feature of `for` loops can be exploited to implement this language feature.

## Defer

The second syntax extension this post will present is `defer`. A `defer` statement is a common kind of statement used in some systems programming languages. Its functionality involves delaying the execution of a segment of code until the end of its scope. The primary use of this is to clean up any resources once they go out of scope. This behaviour can be imitated in GML by including an additional `after` clause:

```gmlext
defer {
  show_message("me second!");
} after {
  show_message("me first!");
}
```

<br>

There is a very specific way this control flow can be achieved, and it involves a little known feature of `for` loops. Did you know that the third expression in a `for` loop can be a block?

```gmlext
for (var i = 0, j = 10; i < j; { i += 2; j += 1 }) {
  show_message(string(i) + " < " + string(j));
}
```

Notice the incrementor statement `{ i += 2; j += 1 }` in place of the third expression. This might look strange, but it is valid syntax in GML. What makes this feature so powerful is the fact that the body of the `for` loop itself gets executed before the third expression in the for loop:

```gmlext
for (;; {
  show_message("me second!");
  break;
}) {
  show_message("me first!");
}
```

The `break` is required to prevent an infinite loop. This is already looking very similar to the proposed `defer` and `after` keywords; the snippet `for (;; {` could represent the `defer` keyword, and `; break; })` could represent the `after` keyword. Together they form the full statement:

```gmlext
#macro defer for (;; {
#macro after ; break; })

var file = file_text_open_read("save.txt");
var content = "";
defer {
  // close the file after it is finished being read
  file_text_close(file);
} after {
  // read the content of the file
  while (!file_text_eof(file)) {
    content += file_text_readln(file);
  }
}
```

This example shows how the `defer` statement can be used in a practical situation: a text file is opened, its content is read, and then it is closed. This is beneficial because the code that handles the file closure is located near similar code that opens the file. Additionally, if the code for reading the content of the file is more complex, for example spanning hundreds of lines, then bugs caused by human error are certainly going to occur.

In the next sub-section, a `print` statement will be briefly discussed, including how a similar technique to this can be used to pull values into the body of the macro.

## Print

The final syntax extension that will be covered is a `print` statement. This might sound a bit anticlimactic at first, but it really is the most technical macro of the three. The `print` statement builds off of the approaches shown in the previous two sub-sections, so this will only be brief. Secretly, the `print` statement assigns the to-be printed value into a hidden variable. The value of this variable is then output to the console, before `break` is executed to exit the loop:

```gmlext
#macro print                          \
    for (var printValue;; {           \
      show_debug_message(printValue); \
      break;                          \
    }) printValue =

print "hello world";
print 7.2 * 3 + 9;
print { x : 90, y : 36 };
print [true, false, false, undefined];
```

The implementation of this macro makes use of the `\` to continue the definition onto a new line. So-called "multi-line macros" can improve the readability of long macros by breaking them over multiple lines.

# Custom Operators

Up to this point, macros have only been used to create syntax extensions for statements. However, custom operators can be defined in the same way! This section covers two custom binary operators that can be defined using macros.

## Boolean Implication

The first custom operator to be highlighted in this section is the lesser-known logical implication (`->`). The operation `a -> b` is often described in words as: "if `a` is `true`, then `b` is also `true`." Thus, if `a` is `true`, but `b` is `false`, the expression evaluates to `false`; otherwise, the expression evaluates to `true`.

Often `a -> b` is a derived operation defined in terms of Boolean **NOT** (`!`) and Boolean **OR** (`||`):

```gmlext
a -> b == !a || b
```

However, this form cannot be easily translated into a macro, since `a` occurs between `!` and `||`. Luckily, there is a way to get around this issue, and it involves Boolean **XOR** (`^^`): the term `!a` is semantically equivalent to `a ^^ true`. This is because the operation `b1 ^^ b2` only returns `true` if neither of the operands, `b1` or `b2`, are equal. Since `b2` always equals `true`, this has the effect of always returning the negation of `a`; that is, `true ^^ true == false` and `false ^^ true == true`. This knowledge can be used to define a custom binary operator `implies` in terms of `^^` and `||`:

```gmlext
#macro implies ^^ true ||

var a = true;
var b = false;
var aimplya = a implies a; // true  -> true  = true
var aimplyb = a implies b; // true  -> false = false
var bimplyb = b implies b; // false -> false = true
var bimplya = b implies a; // false -> true  = true
```

<br>

This same idea can be applied to bitwise operations by instead using `^` and `|`:

```gmlext
#macro bimplies ^ (~0) |

var a = 6; // 0110
var b = 5; // 0101
var abimplya = a bimplies a; // 0110 .-> 0110 = 1111
var abimplyb = a bimplies b; // 0110 .-> 0101 = 1101
var bbimplyb = b bimplies b; // 0101 .-> 0101 = 1111
var bbimplya = b bimplies a; // 0101 .-> 0110 = 1110
```

Since no variant of `true` exists in bitwise Boolean algebras, it is defined as the ones' complement (`~`) of `0`. This results in a similar implication operator that can be used with bitmasking.

In the next sub-section, a useful operator `seq` is discussed, which ends up being useful for combining side-effecting expressions.

## Sequential Composition

The second, and final operator to be showcased is a sequential composition operator. Actually, GML already has one of these! It's called the statement terminator `;`. However, as the name suggests, `;` is only ever used for statements. This is quite a disadvantage because it means that `for` loops ([typically](#defer)) only allow a single incrementor. If a sequential composition operator, `seq`, for expressions existed, then `for` loops with multiple incrementors could be constructed:

```gmlext
for (
  var i   = 0,
      key = ds_map_find_first(map);
  key != undefined;
  key = (i++ seq ds_map_find_next(map, key))
) {
  show_message("the key at index " + string(i) + " is " + string(key));
}
```

Fortunately, GML has just enough features to make the `seq` operator on expressions a reality:

```gmlext
#macro seq == NaN) && false ? undefined : (
```

Simply put: `seq` is defined as a ternary expression where the true branch is never executed. Therefore, its condition must always evaluate to false. The `&& false` at the end of the condition ensures this is the case. Additionally, the parenthesis `)` and `(` at the start and end of the macro ensures the user wraps the binary operation in a grouping `(a seq b)`. This is required because of the precedence of ternary operators.

Interestingly, this custom composition operator is functionally similar to the comma operator[^comma] which appears in JavaScript and C/C++.

# Summary

This post has discussed various macro pitfalls and how they can be utilised to create interesting syntax extensions. These came in the form of key and function aliases, statements and operators. This post also covers how to use macros to override built-in functions or constants with custom implementations.

# References

[^macro]: <%= ref({
	:author => "The GCC Team",
	:title => "3.10 - Macro Pitfalls",
	:booktitle => "The C Processor",
	:publisher => "Free Software Foundation, Inc",
	:year => "2020",
	:url => "https://gcc.gnu.org/onlinedocs/cpp/Macro-Pitfalls.html",
	:visitedon => "2021-03-02"
}) %>

[^comma]: <%= ref({
	:author => "MDN Contributers",
	:title => "Comma Operator (,)",
	:booktitle => "JavaScript Reference",
	:publisher => "Mozilla",
	:year => "2020",
	:url => "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Comma_Operator",
	:visitedon => "2021-03-02"
}) %>

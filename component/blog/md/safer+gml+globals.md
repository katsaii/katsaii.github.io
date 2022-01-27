# Preface

My intention with this post is not to preach a "[best practice](https://youtu.be/gc8mDZwUlfo?t=69s);" I just wanted to talk about one method of managing global state that I find useful. Just like with any problem, you should always consider different approaches based on your current priorities. `d (u _ u.)\`

# The Problem with Global Variables in GML

Plenty of articles describe some (of many) reasons why you should try to avoid global variables, typically because they can make reasoning about programs difficult[^wiki-glob]. However, I'm not concerned with discussing those problems within this post. Instead, I want to cover the situations where some value *really needs to be global*.

So what is the problem? In GML, global variables are only created the instant they're assigned a value at runtime. So, if your global variable definitions are hidden away inside some script or object that the game never reaches, then those global variables will never exist. For example, in the following code the global variable `name` gets defined before `colour`, and the global variable `hidden` is never defined:

```gml
global.name   = "Kirby";  // global.name is defined first
global.colour = 0xcbc0ff; // global.colour is defined second

return; // this return statement will prevent
        // any code below it from executing

// because this line is never reached
// the global variable is never defined
global.hidden = "(O x O) help!";
```

Attempting to access the `hidden` global variable will raise an error telling you that the global variable doesn't exist! This behaviour can become a problem if one part of your game depends on a global variable being declared some place else in your project.

Lets imagine a project with two objects:

 - `obj_control`, which initialises a global variable; and
 - `obj_player`, which uses the global variable that `obj_control` declares.

In order to avoid an error in your game, you **need to guarantee** that the `obj_control` object is created before `obj_player`, otherwise `obj_player` may try to access the global variable before it exists. This can be a particularly annoying bug to track down if it (seemingly) occurs randomly, which is not unlikely if you depend on the creation order of instances in rooms.

## Initialisation Rooms

One common method of patching this bug is to have a so-called "initialisation room," where short-lived objects declare your global variables. Although this solution works fine, it can be brittle because it relies on trust; trusting developers to add any newly introduced global variables to this special room. This is not a big issue, since if you encounter an error relating to a global variable being unset, then the solution is likely to be to add this variable to the initialisation room. However, it is a flaw with this system that I thought was worth mentioning.

## Global Scripts

In a similar way to initialisation rooms, script resources can be used to initialise any global variables. This is possible since all code inside script resources is executed before you even enter the first room of your game. However, because the execution order of this system is not predictable, global variables from one script should **never** depend on any global variables from other scripts, otherwise you may encounter situations where the global variable a script depends on has not been initialised yet.

## Checking If the Variable Exists

Another potential approach would be to check if the global variable exists, using the `variable_global_exists` function, before you attempt to access it, like so:

```gml
if (!variable_global_exists("highscore")) {
  // initialise the variable if it is unset
  global.highscore = 0;
}

// you are now allowed to access highscore here safely
var yay = global.highscore;
```

Unfortunately, there is a clear ergonomic issue with this approach: the code repeats the name of the global variable (`highscore`) too often. If the plan is to use this pattern for every global variable, then there is going to be a lot of repeating code.

Ergonomic issues aside, duplicating this code in many places is not a good idea either. (Yes, even if you squeeze it all onto a single line.) Instead, new functions can be defined that handle the "getting" and "setting" of the global variable automatically:

```gml
// note:
// these functions should be defined inside of a script
// so that they are available globally to all objects

function get_highscore() {
  if (!variable_global_exists("highscore")) {
    global.highscore = 0;
  }
  return global.highscore;
}

function set_highscore(score) {
  global.highscore = score;
}
```

Now `get_highscore()` can be called in any object, at any time, and the global variable will be initialised on-demand if it hasn't already. The initialisation code can be as complicated or as simple as you need it to be, and it will only ever be executed once.

I like this solution, but it's far from perfect. It's somewhat unrealistic to define unique "getter" and "setter" functions for every global variable that may be used in a codebase. Additionally, `global.highscore` still exists and is accessible, potentially inviting other contributers to use this variable and reintroduce the bugs we were originally trying to squish. As a team, you *could* agree to not use this specific global variable, or you *could* obfuscate its name to make accessing it less likely, but I feel like it's possible to do better by using a new feature of GML 2.3: static variables...

# Static Variables

Static variables are new type of variable introduced in version 2.3 of GML. Static variables and global variables are somewhat similar: both will stick around until you end the program. There are two useful differences between them, however:

 - static variables can only be accessed from within the functions they are defined in; and
 - static variables are only ever initialised once, the first time the function that they were defined in is called.

Any subsequent calls to the function will just ignore the initialisation code of any static variables it contains. These features make it possible for functions to maintain their own kind of internal state; for example, a function that counts up from zero:

```gml
function counter() {
  // declare the static variable
  static count = 0;

  // increment the count variable
  var current = count;
  count += 1;

  // return the current count
  return current;
}
```

Calling the `counter` function repetitively will yield different results each time:

```gml
var zero  = counter(); // 0
var one   = counter(); // 1
var two   = counter(); // 2
var three = counter(); // 3
```

## Modifying Static Variables

The ability for static variables to be automatically initialised if they have not yet been is a neat feature. If it were possible to modify the value of a static variable from outside of its enclosing function, then this would erase the need to use the `variable_global_exists` pattern. Unfortunately, because static variables can only be assigned to from within their enclosing function, workarounds need to be used.

One way to modify the value of a static variable would be to pass in a parameter to its enclosing function. This parameter, if passed, would indicate that the value should be updated:

```gml
function game_title() {
  static title = "Witch Wanda";
  if (argument_count == 1) {
    // update the static variable if an argument was passed
    title = argument[0];
  }
  return title;
}
```

Updating the static variable may then be done like so:

```gml
var currentTitle = game_title();    // get the current title
game_title(currentTitle + "izard"); // set the new title
```

This pattern is useful if you need to directly modify the value of a static variable, but results in quite a lot of boilerplate code for just one value.

Another method of modifying the contents of a static variable involves *reference types*. (Things like arrays, or struct instances.) If the value of a static variable is a reference to a data structure, and that reference is returned by the enclosing function, then it is possible to modify the contents of the static variable by modifying the data structure through its reference. For example, creating a static variable that stores a reference to an array data structure:

```gml
function witches() {
  static names = ["Ashley", "Marisa", "Wanda"];
  return names;
}
```

The `witches` function returns a reference to the `names` array. This reference can be used to modify the elements of the array, so that a new witch is added to the list:

```gml
var namesRef = witches();
namesRef[@ 3] = "Gruntilda";
```

After this operation, the value of `names` will now be the array `["Ashley", "Marisa", "Wanda", "Gruntilda"]`.

# Replacing Global Variables with Static Variables

We're in the endgame, now. So I'll try to keep this last section brief.

Both of the methods of modifying static variables, shown in the previous section, are useful in their own ways. However, the last method can result in more familiar syntax if used with a struct data structure. For example, defining a static struct that stores the current score and highscore is quite simple:

```gml
function scores() {
  static data = {
    // initialise the default values
    current : 0,
    highscore : 0,
  };
  return data;
}
```

Accessing and modifying these values greatly resembles the "shape" of `global` variables:

```gml
// static variables
scores().current = 10;
scores().highscore += 100;

// global variables
global.scoresCurrent = 10;
global.scoresHighscore += 100;
```

Since this pattern doesn't introduce much boilerplate code, it is relatively effortless to adopt. Personally, five more lines is a small price to pay in order to guarantee that your global variables will be declared when they are needed!

# Summary

This post has covered a pitfall with global variables in GML, and proposed various methods of dealing with this issue. Covered in detail is a method involving static variables, describing: what static variables are; how they can be modified; and how a simple pattern can be used to imitate the "shape" and behaviour of global variables, whilst also providing guarantees that certain data will be initialised when requested.

# References

[^wiki-glob]: <%= ref({
	:title => "GlobalVariablesAreBad",
	:author => "WikiWikiWeb",
	:booktitle => "CategoryScope",
	:year => "2013",
	:url => "https://wiki.c2.com/?GlobalVariablesAreBad",
	:visitedon => "2022-01-10"
}) %>

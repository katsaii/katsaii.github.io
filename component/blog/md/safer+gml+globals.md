# Preface

My intention with this post is not to preach a "[best practice](https://youtu.be/gc8mDZwUIfo?t=69s);" I just wanted to talk about one method of managing global state that I find useful. Just like with any problem, you should always consider different approaches based on your current priorities. `d (u _ u.)\`

# The Problem with Global Variables in GML

Plenty of articles describe some (of many) reasons why you should try to avoid global variables, typically because they can make reasoning about programs difficult[^wiki-glob]. However, I'm not concerned with discussing those problems within this post. Instead, I want to cover the situations where some value *really needs to be global*.

So what is the problem? In GML, global variables are only created when the program reaches a point where that global variable is assigned a value. So, if your global variable definitions are hidden away inside some script or object that the program never reaches, then those global variables will never exist. For example, in the following code the global variable `name` gets defined before `colour`, and the global variable `hidden` is never defined:
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

One common method of patching this bug is to have a so-called "initialisation room," where short-lived objects declare your global variables. Although this solution works fine, it can be brittle because it depends on trusting the developer to add any newly introduced global variables to this list. Additionally, this approach is susceptible to the same instance order problem mentioned in the previous section, if you have multiple initialisation objects that may depend on each other.

## Checking If the Variable Exists

Another potential approach would be to check if the global variable exists using the `variable_global_exists` function before you attempt to access it, like so:

```gml
if (!variable_global_exists("highScore")) {
  global.highScore = 0;
}

// you are now allowed to access highScore here safely
var yay = global.highScore;
```

Unfortunately, there is a clear ergonomic issue with this approach: the code repeats the name of the global variable (`highScore`) too often. If the plan is to use this pattern for every global variable, then there is going to be a lot of repeating code. Ergonomic issues aside, duplicating this code in many places is not a good idea either. (Yes, even if you squeeze it all onto a single line.) Instead, new functions can be defined that handle the "getting" and "setting" of the global variable automatically:

```gml
// note:
// these functions should be defined inside of a script
// so that they are available globally to all objects

function get_highscore() {
  if (!variable_global_exists("highScore")) {
    // initialise the variable if it is unset
    global.highScore = 0;
  }
  return global.highScore;
}

function set_highscore(score) {
  global.highScore = score;
}
```

Now `get_highscore()` can be called in any object, at any time, and the global variable will be initialised on-demand if it hasn't already. The initialisation code can be as complicated or as simple as you need it to be, and it will only ever be executed once.

I like this solution, but it's far from perfect. It's somewhat unrealistic to define unique "getter" and "setter" functions for every global variable that may be used in a codebase. Additionally, `global.highScore` still exists and is accessible, potentially inviting other contributers to use this variable and reintroduce the bugs we were originally trying to squish. As a team, you *could* agree to not use this specific global variable, or you *could* obfuscate its name to make accessing it less likely, but I feel like we can do better by using a new feature of GML 2.3: static variables...

# Static Variables

Static variables are new type of variable introduced in version 2.3 of GML. Static variables and global variables are somewhat similar: both will stick around until you end the program. There are two useful differences between static variables and global variables, however:

 - static variables can only be accessed from within the function it was defined in; and
 - static variables are only ever initialised once, the first time the function that it was defined in is called.

Any subsequent calls to the enclosing function will just ignore the initialisation code of any static variables. These features make it possible for functions to maintain their own kind of internal state; for example, a function that counts up from zero:

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

This is neat, but it is not what I'm writing this post about. The next section shows how this can be used to immitate global variables, whilst also preserving their ease of use.

## Modifying Static Variables

The useful feature of static variables I want to harness is their ability to be automatically initialised if they have not yet been. This would erase the need to use the `variable_global_exists` function for each variable we want to use.

However, at first glance this doesn't seem feasible. Sure static variables can store some state inside of a function, but there isn't a way to modify the contents of the static variable from outside of the function... Right? Not entirely. If a static variable contains a reference to a data structure, and that reference is returned by the enclosing function, then it is possible to mutate that data structure, and by extension the contents of the static variable. For example, creating a static variable that stores a reference to an array data structure:

```gml
function witches() {
  static names = [];
  return names;
}

// add names to the array
var names = witches();
names[@ 0] = "Ashley";
names[@ 1] = "Marisa";
names[@ 2] = "Wanda";
```

Calling the `witches` function again will return the same array, this time containing three elements inserted into the array:

```gml
var sameNames = witches(); // ["Ashley", "Marisa", "Wanda"]
```

In this example, if you want the array to always contain these three names by default, the static variable declaration can be updated to:

```gml
static names = ["Ashley", "Marisa", "Wanda"];
```

Now when the `witches` function is called, the `names` array will be initialised with these three default values.

This is already looking similar to the behaviour of global variables, except without the possibility of the `witches` list being unset. However, this idea can be taken one step further...

# Replacing Global Variables with Static Variables

The pattern shown in the previous section is not restricted to arrays. It's possible to use any kind of data structure, but structs resemble global variables best. For example, defining some static state for keeping scores is relatively short:

```gml
function scores() {
  static data = {
    current   : 10, // initialise the default values
    highScore : 100,
  };
  return data;
}
```

Comparing this to typical global variables, there isn't much difference:

```gml
global.scoresCurrent = 10;
global.scoresHighScore = 100;
```

# Summary

Yeah.

# References

[^wiki-glob]: <%= ref({
	:title => "GlobalVariablesAreBad",
	:author => "WikiWikiWeb",
	:booktitle => "CategoryScope",
	:year => "2013",
	:url => "https://wiki.c2.com/?GlobalVariablesAreBad",
	:visitedon => "2022-01-10"
}) %>

# Preface

This post is not intended to be preached as a "best practice." I just wanted to talk about one method of managing global state that I find useful. Just like with any problem, you should always consider different approaches based on your current priorities. `d (u _ u.)\`

# The Problem with Using Global Variables

Okay... There are actually many problems with using global variables, some of which are useful to look out for. However, I'm not concerned with discussing those problems within this post. Instead, I want to discuss the situations where some value *really needs to be global*. (But if you're just itching to know, you can read all about some common pitfalls in this [WikiWikiWeb article](https://wiki.c2.com/?GlobalVariablesAreBad)[^wiki-glob].)

So what is the problem? In GML, global variables are only defined if and when the program reaches a point where a value needs to be assigned to a global variable with that name. So, if your global variable definitions are hidden away inside some script or object that the program never reaches, then those global variables will never exist. For example, in the following code the global variable `name` gets defined before `colour`, and the global variable `hidden` is never defined:
```gml
global.name   = "Kirby";  // global.name is defined first
global.colour = 0xcbc0ff; // global.colour is defined second

return;

// because this line is never reached, the global variable is never defined
global.hidden = "(O x O) help!";
```
Attempting to access the `hidden` global variable will raise an error telling you that the global variable doesn't exist! This behaviour can be a problem if one part of your game expects a global variable to exist before it's initialised.

Lets imagine a project with two objects:

 - `obj_control`, which initialises a global variable; and
 - `obj_player`, which uses the global variable that `obj_control` declares.

In order to avoid an error in your game, you **need to guarantee** that the `obj_control` object is created before `obj_player`, otherwise `obj_player` may try to access the global variable before it exists. This can be a particularly annoying bug to track down if it only occurs randomly, which is not too far-fetched if you depend on the creation order of instances in rooms.

## Initialisation Rooms

One common method of fixing this bug is to have a so-called "initialisation room," where short-lived objects declare your global variables. This solution works fine but it can be brittle, since it depends on trusting the developer to add any newly introduced global variables to this list. Additionally, this design breaks down if there are other objects in the initialisation room that depend on the values of certain global variables that may or may not be defined yet. (You could get around this by having a single object `obj_mega_initialiser` that has a thousand lines of initialisation code in its create event, but I shudder at the thought.)

## Checking If the Variable Exists

Another potential solution would be to check if the global variable exists with the `variable_global_exists` function before you attempt to access it, like so:

```gml
if (!variable_global_exists("highScore")) {
  global.highScore = 0;
}

// you are now allowed to access highScore here safely
var yay = global.highScore;
```

Ignoring the obvious ergonomic issues with this proposal, duplicating this code in many places is not a good idea. (Yes, even if you squeeze it all onto a single line.) Instead, new functions can be defined that handle the "getting" and "setting" of the global variable automatically:

```gml
// note:
// these functions should be defined inside of a script
// so that they are available globally to all objects

function get_highscore() {
  if (!variable_global_exists("highScore")) {
    // initialise the variable
    global.highScore = 0;
  }
  return global.highScore;
}

function set_highscore(score) {
  global.highScore = score;
}
```

Now `get_highscore()` can be called in any object, at any time, and the global variable will be initialised on-demand if it hasn't already. The initialisation code can be as complicated or as simple as you need it to be, and it will only ever be executed once.

I like this solution, but it's far from perfect. It's somewhat unrealistic to define unique "getter" and "setter" functions for every global variable that may be used in a codebase. Additionally, `global.highScore` still exists and is accessible, potentially inviting other contributers to use this variable and reintroduce the bugs we were originally trying to squish. As a team, you *could* agree to not use this specific global variable, or you *could* obfuscate its name to make accessing it less likely, but I feel like we can do better by using a new feature of GML 2.3: static variables.

# Avoiding The Problem by using static variables

```gml
global.playerName = "Jake";
global.playerScore = 0;
global.playerHiScore = 100;
```
becomes
```gml
function player_data() {
  static data = {
    name : "Jake",
    score : 0,
    hiScore : 100,
  };
  return data;
}
```
accessing player data
```gml
var playerScore = player_data().score;
```

## Advantages over global variables

more control over what gets assigned to your global variables

```gml
function player_data() {
  static data = {
    score : 0,
    hiScore : 100,
    setScore : function(newScore) {
      score = newScore;
      if (score > hiScore) {
        hiScore = score;
      }
    },
    getScore : function() {
      return score;
    },
    getHiScore : function() {
      return hiScore;
    }
  };
  return {
    setScore : data.setScore,
    getScore : data.getScore,
    getHiScore : data.getHiScore,
  };
}
```

read-only global state
```gml
function team_colours() {
  static colours = [c_red, c_blue, c_green]; // this array can be updated externally, but never reassigned
  return colours;
}
```

# References

[^wiki-glob]: <%= ref({
	:title => "GlobalVariablesAreBad",
	:author => "WikiWikiWeb",
	:booktitle => "CategoryScope",
	:year => "2013",
	:url => "https://wiki.c2.com/?GlobalVariablesAreBad",
	:visitedon => "2022-01-10"
}) %>

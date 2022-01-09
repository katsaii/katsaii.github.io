# Preface

This post is not intended to be preached as a "best practice." I just wanted to talk about one method of managing global state that I find useful. Just like with any problem, you should always consider different approaches based on your current priorities. `d (u _ u.)\`

# The Problem with Using Global Variables

 - many problesm with globals
 - not gonna discuss that in this post
 - gm is inheritely stateful

 - depends on code evaluation order
 - initialisation rooms
 - check for variable existence using variable_global_exists
 - works fine, but can be brittle

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

# Preface

 - not intended to be preached as a best practice, just one method of managing global state that i fine useful

# The Problem with Using Global Variables

 - depends on code evaluation order

## Solving the problem

 - check for variable existence using variable_global_exists

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

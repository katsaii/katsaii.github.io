Instead of this...

```gml
global.playerName  = "Ashley";
global.playerAge   = 15;
global.playerScore = 1000;
```

...I like to do this...

```gml
function player_data() {
  static player = {
    name  : "Ashley",
    age   : 15,
    score : 9,
  };
  return player;
}
```

...and then get/set these global values like...

```gml
player_data().age += 1;
player_data().name = string(player_data().score) + "-Volt";
```

...because it guarantees that your data will be initialised before it's accessed.

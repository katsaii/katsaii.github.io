Instead of this...

```gml
global.scoresCurrent = 10;
global.scoresHighscore += 100;
```

...I like to do this...

```gml
function scores() {
  static data = {
    current   : 0, // initialise the default values
    highscore : 0,
  };
  return data;
}
```

...and then get/set these global values like...

```gml
scores().current = 10;
scores().highscore += 100;
```

...because it guarantees that your data will be initialised before it's accessed.

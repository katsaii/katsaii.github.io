Using macros can result in strange behaviour like...

```gmlext
#macro ENTER_BUNNY var bunny = "/(.U x U.) <(yuh)"

ENTER_BUNNY;
show_message(bunny); // ???
```

...but they can also be used to override built-in values...

```gmlext
#macro c_red make_colour_rgb(209, 88, 100)
```

...and even create new entirely new syntax!

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

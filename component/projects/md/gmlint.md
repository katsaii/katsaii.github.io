A simple linter for GameMaker Language that lets teams ban access to certain global variables, or detect semantic problems with your games that GameMaker does not. GMLint attempts to offer clear and concise error messages (as shown in Listing 1), inspired by state-of-the-art solutions like the Rust and Elm compilers.

```txt
error (banned-functions) in testfiles/scripts/idiomatic-gml.gml:34:17
 34 |  for (var i=0;i<array_length(keys);i++) {
    |                 ^^^^^^^^^^^^ accessing this variable is prohibited
    = note: `//# WARN banned-functions` is enabled by default

error (bad-tab-style) in testfiles/scripts/idiomatic-gml.gml:72:30
 72 |   if (gamepad_is_connected(i) ) {
    |                              ^ tab is used here when it shouldn't be
    = note: `//# WARN bad-tab-style` is enabled by default

displayed 2 errors for testfiles/scripts/idiomatic-gml.gml

error (banned-functions) in testfiles/bad-tab-style.gml:1:7
 1 | hello this is bad
   |       ^^^^ accessing this variable is prohibited, instead use `self`

displayed 1 error for testfiles/bad-tab-style.gml
```
<%= caption(desc: 'Error output', ref: 1, type: :listing) %>

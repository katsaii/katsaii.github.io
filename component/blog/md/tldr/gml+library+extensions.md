Overriding the implementation of built-in functions is possible using macros...

```gml
#macro BUILTIN_SHOW_DEBUG_MESSAGE show_debug_message
#macro show_debug_message overrides_show_debug_message

function overrides_show_debug_message(str) {
  BUILTIN_SHOW_DEBUG_MESSAGE(str); // call the original implementation
  var file = file_text_open_append("game.log");
  file_text_write_string(file, str);
  file_text_writeln(file);
  file_text_close(file);
}
```

...now every call to `show_debug_message` will also append the message to a log file named `game.log`!

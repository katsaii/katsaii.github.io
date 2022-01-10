# Preface

This post goes into detail about an undocumented feature of GML, originally brought to my attention by [Zach&nbsp;Reedy](https://twitter.com/datzach). Since this feature is undocumented, it wouldn't be wise to depend entirely on any topics discussed throughout this post, in case something changes in the future or there are inconsistencies between target platforms.

# The Problem

Like many libraries, there are gaps in the set of built-in functions provided by GameMaker. This is typically due to the low-priority of niche functionality; for instance, there exists functions for setting the minimum and maximum size of the game window[^windowf], but (currently) no functions for getting these values back in case they were updated somewhere else in the codebase.

One method to circumvent this would be to maintain a set of global variables; ones that would store the current minimum and maximum size of the window. These global variables could then be accessed in order to obtain the current window size. The following example illustrates how such an approach could be applied:

```gml
global.windowMinWidth  = -1;
global.windowMinHeight = -1;

function set_min_size(width, height) {
  window_set_min_width(width);
  window_set_min_height(height);
  global.windowMinWidth  = width;
  global.windowMinHeight = height;
}
```

A helper function `set_min_size` is implemented which sets the minimum size of the window. The corresponding minimum width and height of the window can then be tracked using the global variables `windowMinWidth` and `windowMinHeight` respectively. However, this approach only works well if you trust yourself and your collaborators to maintain synchronisation between the global variables and the actual window size. This ultimately requires prohibiting the use of both `window_set_min_width` and `window_set_min_height` by team members; any violation of this rule would result in difficult to track bugs.

# The Solution

An alternative approach to this problem is to use macros to override existing built-in functions, whilst preserving a reference to the original function. In other words, opaquely extending existing built-in functions with additional behaviour; for instance, extending `window_set_min_width` and `window_set_min_height` such that their associated global variables get automatically updated:

```gml
window_set_min_width(100);  // automatically updates `windowMinWidth` to 100
window_set_min_height(100); // automatically updates `windowMinHeight` to 100
```

In some ways this is superior compared to the previous approach, because it does not prohibit the use of `window_set_min_width` and `window_set_min_height`. Everything the `set_min_size` function did is being performed behind the scenes for the user.

## Implementation Details

As shown in a [previous blog post](./gml+syntax+extensions.html), built-in functions and variables can be overridden using macros. However, this had limited applications because it caused the original reference to the built-in function to become unreachable. As a result, the original behaviour of the function was lost:

```gml
#macro show_debug_message overrides_show_debug_message

function overrides_show_debug_message(str) {
  var file = file_text_open_append("game.log");
  file_text_write_string(file, str);
  file_text_writeln(file);
  file_text_close(file);
}
```

The `show_debug_message` typically displays a message in the console window; this example will override the `show_debug_message` function with a custom implementation that appends the message to a log file. This results in no debug messages being displayed in the console window, since the original functionality has been overwritten. This is not ideal, because the goal was to add additional functionality on top of existing functions, not to replace their functionality entirely; therefore, a method of preserving the reference to the original built-in function is required.

The new method avoids these pitfalls by including an additional macro that acts as a replacement alias for the built-in function. The function definition can then be updated such that both the original and custom implementations of the function are performed:

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

The macro `BUILTIN_SHOW_DEBUG_MESSAGE` acts as a new alias for the `show_debug_message` function. This alias is then used within the `overrides_show_debug_message` function in order to call the original implementation. As a result, the `show_debug_message` function will now first display the message to the console before writing it to the log file.

Applying this technique to the window example, the following code can be produced:

```gml
// preserve the original built-in function references
#macro BUILTIN_WINDOW_SET_MIN_WIDTH  window_set_min_width
#macro BUILTIN_WINDOW_SET_MIN_HEIGHT window_set_min_height

// override the current function with a custom user-defined function
#macro window_set_min_width  overrides_window_set_min_width
#macro window_set_min_height overrides_window_set_min_height

global.windowMinWidth  = -1;
global.windowMinHeight = -1;

// implement function overrides
function overrides_window_set_min_width(width) {
  BUILTIN_WINDOW_SET_MIN_WIDTH(width); // call the original implementation
  global.windowMinWidth = width;       // update internal record
}
function overrides_window_set_min_height(height) {
  BUILTIN_WINDOW_SET_MIN_HEIGHT(height);
  global.windowMinHeight = height;
}
```

Using the `window_set_min_width` and `window_set_min_height` functions will now automatically update their corresponding global variables, without any additional functions from the perspective of the library user.

## Hiding Implementation Details

Although not strictly required, in the interest of making it difficult to de-synchronise the global variables, the public interface can be restricted; for example, verbose names could be given to the global variables. Their values would then be exposed using shorter, more appealing user-defined getter functions `window_get_min_width` and `window_get_min_height`:

```gml
global.__internalWindowVariable_windowMinWidth  = -1;
global.__internalWindowVariable_windowMinHeight = -1;

function window_get_min_width() {
  return global.__internalWindowVariable_windowMinWidth;
}
function window_get_min_height() {
  return global.__internalWindowVariable_windowMinHeight;
}
```

Since getter functions return a copy of the values stored in the global variables, there is no risk of accidentally modifying them, and hence desynchronising their values. This essentially reduces the likelihood of a team member making a mistake, by increasing the effort required to type out the names of protected global variables. Similarly, this could be applied to the macro definitions and function overides in order to coerce users into only using the getter and setter functions.

Note: since many auto-complete engines order underscores after letters alphabetically, any identifiers starting with an underscore will usually appear at the end of the list. This further increases the effort required to make a mistake when using the library.

# Experiments

<div class="centre"><%= figure("/image/figures/pixel-perfect.png", ref: 1, desc: "Pixel-perfect scaling with a high-resolution GUI layer", width: 640) %></div>

A few experiments can be found on [GitHub](https://github.com/NuxiiGit/macro-hacks/tree/master/gml-library-extensions) that extend the GameMaker standard library. A list of functions that have been implemented include:

 - `application_set_position` — Enables setting an exact region to render the application surface.
 - `application_set_position_fixed` — Similar to `application_set_position`, except preserving aspect ratio.
 - `display_set_gui_position` — Enables setting an exact region and scale to draw the GUI in.
 - `network_get_config` — Enables getting network configurations set by the user.

All extensions have seen practical use in projects I've been a part of. Most importantly, `display_set_gui_position` lifts a restriction of the current GUI functions, requiring that either the offset *or* scale of the GUI could be set, but not both simultaneously[^guif]. In conjunction with `application_set_position_fixed`, these extensions allow for low-resolution games to scale "pixel-perfectly," whilst also enabling a high-resolution GUI. An example of this is shown in Figure 1.

Also included in the repository is a singleton system, which overrides the built-in instance functions in order to prevent multiple singletons of the same type from being created, and to offer deactivation immunity to system objects. This can help reduce the likelihood of bugs related to system objects from occurring.

# Summary

This post has discussed an interesting undocumented feature of macros, and how it can be used to fill gaps within the GameMaker standard library. This approach also shows promise in reducing potential bugs by hiding the job of synchronising global variables with expected inputs to built-in functions.

# References

[^windowf]: <%= ref({
	:author => "YoYo Games Ltd",
	:title => "10.2.6.2 - The Game Window",
	:booktitle => "GameMaker Studio 2 Manual",
	:year => "2021",
	:url => "https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Cameras_And_Display/The_Game_Window/The_Game_Window.htm",
	:visitedon => "2021-06-08"
}) %>

[^guif]: <%= ref({
	:author => "YoYo Games Ltd",
	:title => "10.2.6 - <code>display_set_gui_size</code>",
	:booktitle => "GameMaker Studio 2 Manual",
	:year => "2021",
	:url => "https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Cameras_And_Display/display_set_gui_size.htm",
	:visitedon => "2021-06-09"
}) %>


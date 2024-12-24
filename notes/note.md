
# AwesomeWM config II

- package
    - query installed packages
    - understands SemVer or (or whatever arch actually uses)
    - defaults to arch packages except where noted (keep track dumbass)

- https://github.com/andOrlando/rubato

- consider adding a __gc hack helper
  - https://stackoverflow.com/questions/27426704/lua-5-1-workaround-for-gc-metamethod-for-tables
  - lua 5.1 only - this is an amenity!

# API todos
- escalate - allow action through pkexec
- anything in spawn should check package and fallback if possible - ie, tput
  returns default 80x24
  - also, register commands under spawn - fail if commands that are absolutely
    required are not installed
  - same thing for given lua rocks - don’t find out later, print a nice error on
    startup
- agnostic class? create an interface, register fallbacks, each tries its own
  criteria

Neat idea: tags that provide contexts for wiboxes
<Screen.Current>{children}</Screen.Current> <Screen.All>{children}</Screen.All>

## Preload scripts 

config/preload dir is full of scripts that get loaded before
config:create_provider(), allowing for user mods.
  - should I even do this? config/scripts dir could be included as
hot-reloadable
 - maybe scripts should have global API that has callbacks for various DE states

## Actions
- Typechecking should be provided easily! Something like `Action.arg_type`
- Registering nearly everything as an action means that keyboard can be easily
  configured in a serializable format
- Write Actions for Awesome features like client minimize etc.

- action API should support 'client' mode - stringifies lua value (disallowing
  threads, userdata), sends over DBus 
  - even more generic interface that takes GVariant ("v" format type seems to be
    able to describe a generic variant, so we can send anything?? Test this!)

## Keyboard
The key layer loads during awesome core setup. Probably makes sense to create a
key registrar in configuration_info.state.temp, maybe even a Key class. This
must(!!) hot-reload nicely
 - Temp state is pretty much dead, how to save these nicely?

## Services
I think sections should make a comeback, though modified. No JSON provider (this
is weak and bullshit). Services are any subprocess that sticks around for an
appreciable amount of time. Ideally they're structured similarly to Actions if
not a subclass of Action. 
- TODO - service mtime change / reload causes 30log stack overflow!

### `service <name> tail` 
converts to `tail -f /proc/$(child_pid)/fd/1`, to open the tail log of this
command. `awful.spawn_easy_async_with_shell` is supposed to return us a PID but
i don't think it does

## Applications
There should be a section of the configuration that allows users to specify
applications for which ~/.local/share/applications (or whatever the folder is)
entries are made
 - allows for creating application entries for scripts & commands
 - allows for modifying startup flags etc
 - allow images of any size & type and resize automatically
   - write a helper class for imagemagick
     - maybe even a base class for command syntaxes
   - maybe LGI is an option?
   - must fail nicely by default, but allow toggling it off
 - write in vanilla lua - this could possibly be useful as its own script + API
 - AwesomeWM implementation automatically adds & removes on WM startup / exit
 - switch from current rofi menu setup to the nicer "application" one
   - allow command-based rofi with another shortcut

### Rofi sidequest
Consider writing LuaX for rofi's config? I think it's css. hmmm or even a lua
rofi-esque
 - Awful includes a menu system, and it looks like entry wiboxes can be
   custom-generated
 - https://awesomewm.org/doc/api/libraries/awful.menu.html#entry

## Bundled Applications
- LuaX
- https://github.com/thenumbernine/lua-imgui /
  https://github.com/thenumbernine/lua-imguiapp

## Libraries
- Sound: https://github.com/jkl1337/proteaAudio
- i18n: https://github.com/kikito/i18n.lua
- Animations: https://github.com/andOrlando/rubato
- Stack trace plus (maybe?) https://github.com/ignacio/StackTracePlus
- Type safety (maybe?) https://github.com/teal-language/tl

## Other links
- Bluetooth example code through rofi menu:
  https://github.com/nickclyde/rofi-bluetooth/blob/master/rofi-bluetooth

## Components
- ~~Text~~
- ~~Margin~~
- Flex (layout like flex box but simpler)
- ~~Background (color, radius)~~
- Icon
- XIcon
- TextInput
- Image
- ~~Component that warns you that the component will return nil because it’s
  awesomewm only (ie, Systray, XIcon)~~
- TagList (somehow - might be styled)
- TaskList
- Some sort of absolute positioning system
- forced width / height must work
- opacity, visibility, click handlers

### Low priority
- Checkbox
- Graph
- Calendar
- Piechart
- Menubar which i don’t really understand
- Slider
- ProgressBar

> [!NOTE] components/styled does the heavy lifting ⁃ font, size, text color

## Themes
Theme class
- register elements
- runs inside Virtualized

## Interesting notes
beautiful.gtk queries GTK3 for us - useful? awful.emwh seems useful - window
hints

## Things to perhaps ask cat to design
⁃ component library ( too abstract? ) ⁃ taskbar ( i doubt she wants ) ⁃ control
center ⁃ status applets ( volume, brightness, notification etc ) ⁃ launcher

## Libraries
https://github.com/lunarmodules/say


# AwesomeWM config II

- package
    - query installed packages
    - understands SemVer or (or whatever arch actually uses)
    - defaults to arch packages except where noted (keep track dumbass)

- https://github.com/andOrlando/rubato

# API todos
- escalate - allow action through pkexec
- 

# directories
src/
    ui/
        client/
            titlebars.lua
        desktop/
            taskbar/
                init.lua
                clock.lua
                appmenu/
                    init.lua
                control_center/
                    
    awesome/
        core/   Core files load basic shit for awesome
            layouts.lua
            keys.lua
            errors.lua
        The rest of this directory might just be helpers... 

I need to decide if I'm using LuaX

Neat idea: tags that provide contexts for wiboxes
<Screen.Current>{children}</Screen.Current>
<Screen.All>{children}</Screen.All>

## Preload scripts 

config/preload dir is full of scripts that get loaded before config:create_provider(), allowing for user mods.
config/scripts dir could be included as hot-reloadable

## Actions

Action class provides an API to register
actions by name. Somehow.
- Hot-reload ready (ie, weak table & `Action:__gc` unregisters).
- `Action:call(opts)` where opts is always a table. 
- Typechecking should be provided easily! Something like `Action.arg_type`
- Registering nearly everything as an action means that keyboard can be easily
  configured in a serializable format
- Write Actions for Awesome features like client minimize etc.

## Keyboard
The key layer loads during awesome core setup. Probably makes sense to create a
key registrar in configuration_info.state.temp, maybe even a Key class. This
must(!!) hot-reload nicely

## Glob loading
Issue here is that path doesn't automatically get sorted out for me. I don't
want to work in absolutes, as this is bad security practice. A possible hacky
'fix' is 
```lua
local sep = require("src.polyfill.path.sep")
local real_require = require

local require = function (path)
    return path:gsub("%.", sep)
end

-- Would the language server automatically update this path?
local path = require("src.util.action")

for file in ls(path) hot_reload(file) end
```

## Services
I think sections should make a comeback, though modified. No JSON provider (this
is weak and bullshit). Services are any subprocess that sticks around for an
appreciable amount of time. Ideally they're structured similarly to Actions if
not a subclass of Action. 

### `service <name> tail` 
converts to `tail -f /proc/$(child_pid)/fd/1`, to open the tail log of this
command. `awful.spawn_easy_async_with_shell` is supposed to return us a PID but
i don't think it does

## Bundled Applications
- LuaX
- https://github.com/thenumbernine/lua-imgui / https://github.com/thenumbernine/lua-imguiapp

## Libraries
- Sound: https://github.com/jkl1337/proteaAudio
- i18n: https://github.com/kikito/i18n.lua
- Animations: https://github.com/andOrlando/rubato
- Stack trace plus (maybe?) https://github.com/ignacio/StackTracePlus
- Type safety (maybe?) https://github.com/teal-language/tl

## Other links
- Bluetooth example code through rofi menu: https://github.com/nickclyde/rofi-bluetooth/blob/master/rofi-bluetooth

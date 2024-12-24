
# Bookmarked files
src/hooks/use_animated.lua <- currently broken!
src/awesome/ui/taskbar/Taskbar.lua
src/components/awesome/Flex.lua
src/awesome/ui/Console/Console.lua
src/components/awesome/Wibox.lua

# Tasks that I should do
 - organize this list

 - look into some sort of self-hosted / in-repo ticketing / planning / whatever system
   - basically agile so i don't burn myself out

 - [LuaX] make a github issue for wibox.layout.ratio
   - rtfm really hard first
   - possibly inspect / patch source

 - finish src/util/typed
   - static typings are GOOD

 - ~~weak_load_asset()~~
    - ~~unload chunks of code after ttl~~
    - ~~reduces dead memory for unused DE features~~
    - ~~load code to bytecode~~
      - ~~load() -> string.dump() perhaps~~
    - ~~returns a Promise so we can use Suspenses!~~

 - [LuaX] test use_animated hook (use_memo fix should work )

 - [LuaX] look into the old Wibox component I wrote while developing LuaX. seems a lot better but does it work?

 - [LuaX] try writing Suspense with hooks

 - Fix Virtualize metatable vulnerability

 - Agnostic or something class
   - provide interface, log.error
   - candidate implementations are loaded in order, check `implementation:can_use()` which may return a Promise
     - first true or Promise<true> returned loads that provider
   - allows 
     - simplification of ConfigurationProvider selection, 
     - spawn with fallbacks (be they mocks or other similar commands)
     - simplification of Timer provider selection

 - [LuaX] props type checker?
   - i wanna rewrite LuaX :(

 - [LuaX] ForCurrentScreen and ForAllScreens components

 - rerewrite Configuration API 
   - configuration sections should be installable ad-hok
     - minimizes configuration bloat, gimmick feature checks if its enabled, may load its section
       - if feature goes unused, we ignore
       - write a very nice api into ConfigurationMixin
         - function like self:configuration_register_if_enabled (fun(): boolean enabled, section)
         - check self.super.configuration_section or something to register as a subsection
   - rewrite ConfigurationProvider selection to not use promise_iter
     - delete promise_iter

 - fix service hot reload

 - component hot reload (in dev)

 - Services should maybe be enabled in another way
    - start/stop/restart in the command line
    - ConfigurationProviders could offer optional writeback support
      - just warn() if not implemented by given config binding

 - LuaConfigurationProvider should provide globals for [time](../src/util/time.lua) and [dir](../src/util/dir.lua)

 - src/util/input/ folder for MotionData, Vector, future scroll, future gestures

 - some sort of dev/prod env toggle maybe

 - Service that just removes dead logs
   - in dev, daily
   - in prod, 30 days

 - [LuaX] styled components
   - scroll
     - low key i wonder if I can write a shim that allows GTK to intercept more complex scroll data
   - text (FontContext / FontProvider)
   - popup

 - [LuaX] [Console](../src/awesome/ui/Console/Console.lua)
   - wibox that appears through action, hardcoded keys, or CLI
     - browse wiboxes as if HTML viewer
     - browse LuaX components as if HTML viewer
     - awesome lua console (maybe GTK can provide a nicer terminal-esque environment?)
     - actions browser
     - service viewer
     - logs
   - honestly will be swag af
   - this should be loaded via weak_load_asset.

 - themes
   - Theme class with nice api
   - weak_load_asset for everything 
   - same goes for default theme
   - default theme must be an instance of Theme. 

 - some sort of thread API through GLib 
   - i want a worker thread!
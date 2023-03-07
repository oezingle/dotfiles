---@meta

-- TODO come back to this when lua-language-server fixes the generic class inheritance issue
-- https://github.com/LuaLS/lua-language-server/issues/1861
---@class ClassSignalAble<T>: { connect_signal: fun(signal: string | T, callback: function), emit_signal: fun(signal: string | T, ...: any), disconnect_signal: fun (signal: string | T, callback: function) }

---@class InstanceSignalAble<T>: { connect_signal: fun(self: table, signal: string | T, callback: function), emit_signal: fun(self: table, signal: string | T, ...: any), disconnect_signal: fun (self: table, signal: string | T, callback: function) }
---@alias SignalAble<T> InstanceSignalAble<T> | ClassSignalAble<T>

---@alias GetterOrSetter<Self, V> (fun(self: Self): V)|(fun(self: Self, value: V): nil)

---@diagnostic disable: lowercase-global

---@alias Surface table
---@alias Screen table
---@alias Tag table
---@alias GearsShape function
---@alias Struts { right: integer, left: integer, top: integer, bottom: integer }
---@alias Button table
---@alias Key table

--- https://awesomewm.org/doc/api/libraries/awesome.html
---@class Awesome
---@field register_xproperty fun(name: string, type: "string"|"number"|"boolean")
---@field quit fun(code: integer?) quit Awesome
---@field exec fun(cmd: string) Execute another application, probably a window manager, to replace awesome.
---@field restart fun() restart Awesome
---@field kill fun(pid: integer, signal: integer? ) kill a process. 0 and negative values have special meaning. See `man kill`.
---@field sync fun() Synchronize with the X11 server.
---@field pixbuf_to_surface fun(pixbuf: table, path: unknown?): Surface Translate a GdkPixbuf to a cairo image surface.
---@field load_image fun(path: string): Surface Load an image from its path and return it as a cairo image
---@field set_preferred_icon_size fun(size: number) Set the preferred size for client icons.
-- ---@field spawn fun() Spawn a program on the default screen -- Removed because not well documented enough to use
---@field xkb_set_layout_group fun(group: integer)  Switch keyboard layout. Integer from 0-3
---@field xkb_get_layout_group fun(): number Get current layout level
---@field xkb_get_group_names fun(): string Get layout short names. Eg 'pc+us+de:2+inet(evdev)+group(alt_shift_toggle)+ctrl(nocaps)'
---@field version string The version of Awesome
---@field release string The release name of Awesome
---@field conffile string The configuration file which has been loaded.
---@field startup boolean True if we are still in startup, false otherwise, ie this isn't an iteration of the main loop
---@field startup_errors string? if errors are present at startup, the error message
---@field composite_manager_running boolean True if a composite manager is running.
---@field unix_signal { SIGCHLD: 17, SIGPOLL: 29, SIGHUP: 1, SIGSTKFLT: 16, SIGALRM: 14, SIGSTOP: 19, SIGTTOU: 22, SIGPROF: 27, SIGUSR1: 10, SIGTERM: 15, SIGIOT: 6, SIGSYS: 31, SIGXFSZ: 25, SIGXCPU: 24, SIGTRAP: 5, SIGVTALRM: 26, SIGILL: 4, SIGQUIT: 3, SIGTTIN: 21, SIGURG: 23, SIGFPE: 8, SIGPIPE: 13, SIGABRT: 6, SIGSEGV: 11, SIGPWR: 30, SIGIO: 29, SIGBUS: 7, SIGWINCH: 28, SIGCONT: 18, SIGINT: 2, SIGUSR2: 12, SIGCLD: 17, SIGTSTP: 20, SIGKILL: 9 } the list of signals you can send to awesome.kill
---@field hostname string The hostname of the computer on which we are running.
---@field themes_path string The path where themes were installed to.
---@field icon_path string The path where icons were installed to.

---@type Awesome | ClassSignalAble<"debug::error" | "debug::deprecation" | "debug::index::miss" | "debug::newindex::miss" | "systray::update" | "wallpaper_changed" | "xkb::map_changed" | "xkb::group_changed." | "refresh" | "startup" | "exit" | "screen::change" | "spawn::canceled" | "spawn::change" | "spawn::completed" | "spawn::initiated" | "spawn::timeout">
awesome      = awesome or {}

---@alias ClientSignal "focus" | "list" | "swapped" | "manage" | "button::press" | "button::release" | "mouse::enter" | "mouse::leave" | "mouse::move" | "property::window" | "request::activate" | "request::geometry" | "request::tag" | "request::urgent" | "tagged" | "unfocus" | "unmanage" | "untagged" | "raised" | "lowered" | "property::size" | "property::position" | "property::floating_geometry" | "request::titlebars" | "marked" | "unmarked"

---@class CClient
---@field window string The X window id.
---@field name string The client title.
---@field skip_taskbar boolean True if the client does not want to be in taskbar.
---@field type "desktop" | "dock" | "splash" | "dialog" | "menu" | "toolbar" | "utility" | "dropdown_menu" | "popup_menu" | "notification" | "combo" | "dnd" | "normal" The window type.
---@field class string The client class. To get a client class from the command line, use the command xprop WM_CLASS. The class will be the second string.
---@field instance string The client instance. To get a client instance from the command line, use the command xprop WM_CLASS. The instance will be the first string.
---@field pid number? The client PID, if available.
---@field role string? The window role, if available.
---@field machine string The machine client is running on.
---@field icon_name string The client name when iconified.
---@field icon Surface The client icon as a surface.
---@field icon_sizes { [0]: number, [1]: number }[] The available sizes of client icons. This is a table where each entry contains the width and height of an icon. 
---@field screen Screen Client screen.
---@field hidden boolean Define if the client must be hidden, i.e. never mapped, invisible in taskbar.
---@field minimized boolean Define it the client must be iconify, i.e. only visible in taskbar.
---@field size_hints_honor boolean Honor size hints, e.g. respect size ratio. This is enabled by default. To disable it by default, see awful.rules.
---@field border_width integer The client border width
---@field border_color Color The client border color
---@field urgent boolean The client's urgent state
---@field content Surface A cairo surface for the client window content. To get the screenshot, use: `gears.surface(c.content)`
---@field opacity number The client opacity. 0.0 - 1.0
---@field ontop boolean If the client is on top of every other window
---@field above boolean If the client is above normal windows
---@field below boolean If the client is below normal windows
---@field fullscreen boolean If the client is fullscreen
---@field maximized boolean If the client is maximized
---@field maximized_horizontal boolean If the client is maximized horizontally
---@field maximized_vertical boolean If the client is maximized vertically
---@field transient_for Client|nil The client the window is transient for
---@field group_window Client|nil Window identification unique to a group of windows
---@field leader_window Client|nil Identification unique to windows spawned by the same command
---@field size_hints { user_position: integer, user_size: integer, program_position: integer, program_size: integer, max_width: integer, max_height: integer, min_width: integer, min_height: integer, width_inc: integer, height_inc: integer } A table with size hints of the client.
---@field motif_wm_hints nil|{ functions: { all: boolean?, resize: boolean?, move: boolean?, minimize: boolean?, maxmimize: boolean? }?, decorations: { all: boolean?, border: boolean?, resizeh: boolean?, title: boolean?, menu: boolean?, minimize: boolean?, maximize: boolean? }?, input_mode: string?, status: { tearoff_window: boolean? }? } The motif WM hints of the client. This is nil if the client has no motif hints. Otherwise, this is a table that contains the present properties. Note that awesome provides these properties as-is and does not interpret them for you. For example, if the function table only has “resize” set to true, this means that the window requests to be only resizable, but asks for the other functions not to be able. If however both “resize” and “all” are set, this means that all but the resize function should be enabled
---@field sticky boolean Set the client sticky, ie available on all tags
---@field modal boolean Indicate if the client is modal
---@field focusable boolean True if the client can receive the input focus
---@field shape_bounding Surface The client's bounding shape as set by awesome as a (native) cairo surface
---@field shape_clip Surface The client's clip shape as set by awesome as a (native) cairo surface
---@field shape_input Surface The client's input shape as set by awesome as a (native) cairo surface.
---@field client_shape_bounding Surface The client's bounding shape as set by the program as a (native) cairo surface.
---@field client_shape_clip Surface The client's clip shape as set by the program as a (native) cairo surface.
---@field startup_id string? The FreeDesktop StartId. See https://awesomewm.org/doc/api/classes/client.html#client.startup_id
---@field valid boolean If the client that this object refers to is still managed by awesome. To avoid errors use `local is_valid = pcall(function() return c.valid end) and c.valid`
---@field first_tag Tag The first tag of the client. Optimized form of `c:tags()[1]`
---@field marked boolean If the client is marked or not
---@field is_fixed boolean If the client has a fixed size or not.
---@field immobilized boolean Is the client immobilized?
---@field floating boolean If the client is floating
---@field x integer The x coordinate
---@field y integer The y coordinate
---@field width integer The client width
---@field height integer The client height
---@field dockable boolean If the client is dockable.  A dockable client is an application confined to the edge of the screen. The space it occupies is substracted from the `screen.workarea`. Clients with a type of “utility”, “toolbar” or “dock” are dockable by default.
---@field requests_no_titlebar boolean If the client requests not to be decorated with a titlebar
---@field shape GearsShape Set the client shape
---@field struts GetterOrSetter<CClient, Struts> Return client struts (reserved space at the edge of the screen). 
---@field buttons GetterOrSetter<CClient, Button[]> Get or set mouse buttons bindings for a client. 
---@field isvisible fun(self: CClient): boolean Check if a client is visible on its screen
---@field kill fun(self: CClient) Kill a client
---@field swap fun(self: CClient, c: CClient) Swap a client with another one in global client list. 
---@field tags GetterOrSetter<CClient, Tag[]> Access or set the client tags.
---@field raise fun(self: CClient) Raise a client on top of others which are on the same layer
---@field lower fun(self: CClient) Lower a client on bottom of others which are on the same layer
---@field unmanage fun(self: CClient) Stop managing a client
---@field geometry GetterOrSetter<CClient, Geometry>  Return or set client geometry
---@field apply_size_hints fun(self: CClient, width: integer, height: integer) Apply size hints to a size
---@field keys GetterOrSetter<CClient, Key[]> Get or set keys bindings for a client
---@field get_icon fun(self: CClient, index: integer): Surface Get the client's n-th icon
---@field jump_to fun(self: CClient, merge: boolean|function) Jump to the given client. Takes care of focussing the screen, the right tag, etc
---@field relative_move fun(self: CClient, x: integer?, y: integer?, width: integer?, height: integer?) Move/resize a client relative to current coordinates
---@field move_to_tag fun(self: CClient, tag: Tag) Move a client to a tag
---@field toggle_tag fun(self: CClient, tag: Tag) Toggle a tag on a client
---@field move_to_screen fun(self: CClient, screen: Screen?) Move a client to a screen. Default is next screen, cycling
---@field to_selected_tags fun(self: CClient) Tag a client with the set of current tags
---@field get_transient_for_matching fun(self: CClient, matcher: fun(c: CClient): boolean): CClient? Get a matching transient_for client if any
---@field is_transient_for fun(self: CClient, c: CClient): boolean Is this client transient for another one? 

---@alias Client CClient | InstanceSignalAble<ClientSignal>

---@class ClientModule
---@field focus Client|nil The focused client or nil (in case there is none).
---@field instances fun(): integer Get the number of instances. This includes closed clients
---@field get fun(screen: Screen?, stacked: boolean?): Client[] Get all clients into a table. 

---@type ClientModule | ClassSignalAble<ClientSignal>
client       = client or {}
screen       = screen or {}
root         = root or {}
tag          = tag or {}
mouse        = mouse or {} --[[@as Mouse]]
mousegrabber = mousegrabber or {}
button       = button or {}
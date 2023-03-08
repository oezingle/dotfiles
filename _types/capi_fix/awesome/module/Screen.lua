---@meta

---@alias ScreenSignal "primary_changed" | "added"| "removed"| "list"| "swapped"| "tag::history::update"

---@class CScreen
---@field geometry Geometry The screen coordinates. [Link](https://awesomewm.org/doc/api/classes/screen.html#screen.geometry)
---@field index integer The internal screen number. The indeces are a continuous sequence from 1 to screen.count(). It is NOT related to the actual screen position relative to each other. 1 is NOT necessarily the primary screen. When screens are added and removed indices CAN change. [Link](https://awesomewm.org/doc/api/classes/screen.html#screen.index)
---@field outputs { [string]: { mm_width: integer, mm_height: integer } }
---@field workarea Geometry The screen workarea. The workarea is a subsection of the screen where clients can be placed. It usually excludes the toolbars (see awful.wibar) and dockable clients (see client.dockable) like WindowMaker DockAPP
---@field padding Struts The screen padding. This adds a “buffer” section on each side of the screen
---@field clients Client[] The list of visible clients for the screen. Minimized and unmanaged clients are not included in this list as they are technically not on the screen.
---@field hidden_clients Client[] Get the list of clients assigned to the screen but not currently visible. This includes minimized clients and clients on hidden tags
---@field all_clients Client[]  All clients assigned to the screen
---@field tiled_clients Client[] Tiled clients for the screen. Same as `screen.clients`, excluding: fullscreen, maximized, floating
---@field tags Tag[] A list of all tags on the screen. Read-only
---@field selected_tags Tag[] A list of all selected tags on the screen
---@field selected_tag Tag The first selected tag
---@field swap fun(self: CScreen, s: Screen) Swap a screen with another one in global screen list
---@field get_square_distance fun(self: CScreen, x: number, y: number): number Get the square distance between a screen and a point
---@field get_next_in_direction fun(self: CScreen, direction: Direction): Screen
---@field get_bounding_geometry fun(self: CScreen, args: { honor_padding: boolean?, honor_workarea: boolean?, margins: integer|Struts|nil, tag: Tag?, parent: unknown?, bounding_rect: unknown? }|nil): Geometry
---@field get_clients fun(self: CScreen, stacked: boolean?): Client[] Get the list of visible clients for the screen. `stacked` defaults to `true`
---@field get_all_clients fun(self: CScreen, stacked: boolean?): Client[] Get all clients assigned to the screen. `stacked` defaults to `true`
---@field get_tiled_clients fun(self: CScreen, stacked: boolean?): Client[] Get tiled clients for the screen.`stacked` defaults to `true`

---@alias Screen CScreen | CFakeScreen | InstanceSignalAble<ScreenSignal>

---@class CFakeScreen : CScreen
---@field fake_remove fun() Remove the fake screen
---@field fake_resize fun(x: integer, y: integer, width: integer, height: integer) Resize the fake screen

---@alias FakeScreen CFakeScreen | InstanceSignalAble<ScreenSignal>

---@class CScreenModule
---@field primary Screen The primary screen
---@field instances fun(): integer Get the number of instances. This includes removed screens
---@field screen fun(): fun(): Screen Iterate over screens
---@field count fun(): integer Get the number of screens
---@field fake_add fun(x: integer, y: integer, width: integer, height: integer): FakeScreen
---@field set_auto_dpi_enabled fun(enabled: boolean) Enable the automatic calculation of the screen DPI (experimental). [link](https://awesomewm.org/doc/api/classes/screen.html#screen:set_auto_dpi_enabled)

---@alias ScreenModule CScreenModule | ClassSignalAble<ScreenSignal> | fun(): Screen https://awesomewm.org/doc/api/classes/screen.html
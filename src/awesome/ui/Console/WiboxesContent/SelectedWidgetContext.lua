
local Context = require("lib.LuaX").Context

---@type LuaX.Context<{ selected: Awesome.Wibox.Widget, set_selected: (fun(widget: Awesome.Wibox.Widget))}>
local SelectedWidgetContext = Context.create()

return SelectedWidgetContext
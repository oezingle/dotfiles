
local create_context = require("lib.LuaX").create_context

---@type LuaX.Context<{ selected: string?, current_name: string? }>
local TabsContext = create_context({ })

return TabsContext
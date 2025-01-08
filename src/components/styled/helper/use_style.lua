
local use_context = require("lib.LuaX").use_context
local StyleContext= require("src.components.styled.StyleProvider.StyleContext")

---@return Zingle.Awesome.Style
local use_style = function ()
    return use_context(StyleContext)
end

return use_style
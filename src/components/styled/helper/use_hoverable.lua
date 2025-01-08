
local LuaX = require("lib.LuaX")
local use_style = require("src.components.styled.helper.use_style")
local use_state = LuaX.use_state

---@overload fun(selected: boolean, colors: Zingle.Awesome.Style.Pallette)
---@param selected boolean?
---@param hover_type "border" | "text"?
local function use_hoverable (selected, hover_type)
    hover_type = hover_type or "border"

    ---@type Zingle.Awesome.Style.Pallette
    local colors = type(hover_type) == "table" and hover_type or use_style().colors[hover_type]
    
    local is_hovered, set_hovered = use_state(false)

    return {
        onhover = function ()
            set_hovered(true)
        end,
        onleave = function ()
            set_hovered(false)
        end,
        color = (selected and colors.selected) or 
            (is_hovered and colors.hover or colors.clickable) or 
            colors.default
    }
end

return use_hoverable
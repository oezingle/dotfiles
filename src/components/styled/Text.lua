
local BaseText = require("src.components.base.Text")
local use_style= require("src.components.styled.StyleProvider.use_style")

local merge_props = require("src.components.helper.merge_props")
local LuaX = require("lib.LuaX")
local create_element = LuaX.create_element


local Text = function ()
    local style = use_style()

    return create_element(BaseText, merge_props({
        font = style.font.family,
        size = style.font.size.default
    }))
end

return Text
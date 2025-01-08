---@class Zingle.Awesome.Style
local default_style = {
    font = {
        family = "Arial",
        size = {
            default = 12,

            title = 16,
            subtitle = 14,

            -- TODO better name field
            subtext = 10,
        },
    },

    colors = {
        text = {
            clickable = "#007bff",
            hover     = "#539eed", -- TODO untested

            default = "#ffffff",

            muted = "#777777"
        },

        border = {
            clickable = "#777777",
            hover     = "#AAAAAA",
            selected  = "#ffffff"
        },
    }
}

---@alias Zingle.Awesome.Style.Pallette { ["clickable"|"hover"|"selected"|"default"]: string }

---@type LuaX.Context<Zingle.Awesome.Style>
local StyleContext = require("lib.LuaX").Context.create(default_style)

return StyleContext

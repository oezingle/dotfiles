local wibox = require("wibox")
local wal   = require("src.util.wal")

--- Set the foreground and background of a widget based on pywal updates. 
--- Useful for text etc 
---@param child table child widget
---@param fg? boolean defaults to true
---@param bg? boolean defaults to false
---@return unknown
local function pywal(child, fg, bg)
    local widget = wibox.widget {
        layout = wibox.container.background,
        child
    }

    -- default to using foreground colors
    fg = fg == nil and true or fg

    wal.on_change(function (scheme) 
        if bg then
            widget.bg = scheme.special.background
        end

        if fg then
            widget.fg = scheme.special.foreground
        end
    end)

    return widget
end


return pywal
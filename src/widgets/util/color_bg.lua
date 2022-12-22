local shapes = require("src.util.shapes")
local wibox  = require("wibox")
local unpack = require("src.agnostic.version.unpack")

local get_decoration_color = require("src.util.color.get_decoration_color")

-- A widget with a rounded rect, margin, and background color
local function color_bg_widget(args)
    local widgets = { unpack(args) }
    if #widgets > 1 then
        widgets.layout = args.layout or wibox.layout.fixed.vertical

        widgets.fill_space = false

        widgets.spacing = args.spacing
    else
        widgets = widgets[1]
    end

    return wibox.widget {
        {
            widgets,
            widget = wibox.container.margin,
            margins = args.margins or 2,
        },
        widget = wibox.container.background,
        shape = shapes.rounded_rect(args.radius),
        bg = args.bg or get_decoration_color(),
    }
end

return color_bg_widget

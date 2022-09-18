local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local config= require("config")
local get_font = require("util.get_font")

local shapes = require("util.shapes")

local popup = awful.popup {
    widget    = {
        {
            {
                -- TODO make bigger - font
                widget = wibox.widget.textbox,
                text   = "Modal Notification",
                font   = get_font(18),
                id     = "modal-title"
            },
            {
                widget = wibox.widget.textbox,
                text   = "Modal Notification Text",
                font   = get_font(12),
                id     = "modal-text"
            },
            layout = wibox.layout.fixed.vertical
        },
        margins = 10,
        widget  = wibox.container.margin
    },
    visible   = false,
    ontop     = true,
    shape     = shapes.rounded_rect(),
    placement = awful.placement.centered,

    bg = config.popup.bg,
    fg = config.popup.fg,
}

local timer = gears.timer({
    timeout     = 2,
    single_shot = true,
    callback    = function()
        popup.visible = false
    end
})

local modal_notify = function(title, text)
    popup.widget:get_children_by_id("modal-title")[1].text = title
    popup.widget:get_children_by_id("modal-text")[1].text = text

    popup.screen = awful.screen.focused()

    popup.visible = true

    timer:again()
end

return modal_notify

local config = require("config")
local gears  = require("gears")
local no_scroll = require("widgets.helper.no_scroll")
local gtable = gears.table
local awful  = require("awful")
local wibox  = require("wibox")
local base   = wibox.widget.base

local shapes   = require("util.shapes")
local get_font = require("util.get_font")
local Class    = require("util.Class")

local select = {}

-- just a button bruh
local function default_button(content)
    local widget = wibox.widget {
        {
            {
                widget = wibox.widget.textbox,
                font = get_font(12),

                text = content,
                id = "button-text"
            },
            layout = wibox.container.place
        },

        bg = config.button.normal,

        shape = shapes.rounded_rect(5),

        widget = wibox.container.background
    }

    widget:connect_signal("mouse::enter", function(self)
        self.bg = config.button.hover
    end)

    widget:connect_signal("mouse::leave", function(self)
        self.bg = config.button.normal
    end)

    return widget
end

function select:fit(context, width, height)
    return base.fit_widget(self, context, self._private.button, width, height)
end

local function update_dropdown_text(self)
    local button = self._private.button

    local textbox = button:get_children_by_id("button-text")[1]

    local option_index = self._private.option_index

    if option_index == 0 then
        textbox.text = "Select an Option"
    else
        textbox.text = self._private.options[option_index]
    end
end

function select:layout(context, width, height)
    update_dropdown_text(self)

    return { base.place_widget_at(self._private.button, 0, 0, width, height) }
end

function select:trigger()
    local popup = self._private.popup

    if popup.visible then
        popup.visible = false
    else
        -- TODO cache all this work with self._private.last_placement or something
        for _, widget_geometry in ipairs(mouse.current_widget_geometries) do
            if widget_geometry.widget == self._private.button then
                local parent = mouse.current_wibox

                local parent_geo = parent:geometry()

                local new_geometry = {
                    x     = parent_geo.x + widget_geometry.x,
                    y     = parent_geo.y + widget_geometry.y + widget_geometry.height,
                    width = widget_geometry.width,
                }

                popup:geometry(new_geometry)

                popup.widget.forced_width = new_geometry.width

                popup.visible = true

                return
            end
        end

        -- fallback
        popup:move_next_to(self._private.button)
    end
end

function select:hide()
    self._private.popup.visible = false
end

-- TODO hide popup on parent visibility change automagically

function select:set_button(button)
    button = button or default_button()

    button:connect_signal("button::press", no_scroll(function()
        self:trigger()
    end))

    self._private.button = button
end

function select:choose(index)
    self._private.option_index = index

    update_dropdown_text(self)
end

function select:get_choice()
    local option_index = self._private.option_index

    return option_index, self._private.options[option_index]
end

-- awesome calls this for me :)
function select:set_options(options)
    -- update option_list
    local option_list = self._private.option_list

    option_list:reset()

    for index, option in ipairs(options) do
        local option_widget = default_button(option)

        option_widget:connect_signal("button::press", no_scroll(function()
            self:choose(index)
        end))

        option_list:add(option_widget)
    end

    -- prevent a stack overflow
    self._private.options = options
end

function select:new(options)
    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, select, true)

    ret._private.option_index = 0

    ret._private.option_list = wibox.widget {
        layout = wibox.layout.fixed.vertical,
        spacing = 5,
    }

    ret._private.popup = awful.popup {
        widget = wibox.widget {
            ret._private.option_list,

            layout = wibox.container.margin,
            margins = 5,
        },

        preferred_positions = "bottom",

        ontop = true,
        visible = false,

        shape = shapes.partially_rounded_rect(0, false, false, true, true),

        bg = config.popup.bg,

        hide_on_right_click = true
    }

    ret:set_button()

    options = options or {}
    ret.options = options

    return ret
end

return Class(select)

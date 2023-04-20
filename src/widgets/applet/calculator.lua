local wibox         = require("wibox")
local awful         = require("awful")
local shapes        = require("src.util.shapes")
local config        = require("config")
local lighten_color = require("src.util.color.lighten")
local no_scroll     = require("src.widgets.helper.function.no_scroll")

local textinput = require("src.widgets.element.textinput")

local get_font = require("src.util.get_font")
local get_decoration_color = require("src.util.color.get_decoration_color")

local applet = require("src.widgets.helper.applet")

local luaxp = require("lib.luaxp")

-- TODO move error_shape to the right of textinput ( need to fix textinput )
-- TODO larger calculator option? seperate applet? idk
-- TODO color of error_shape is kinda iffy with some color schemes
-- TODO luaxp context

local function create_calculator()
    local primary_button_color = get_decoration_color()
    local number_button_color = "#333"
    local secondary_button_color = config.progressbar.bg

    -- TODO degree mode switch!

    local function create_button(content, bg, callback)
        local widget = wibox.widget {
            {
                {
                    widget = wibox.widget.textbox,
                    font = get_font(14),
                    text = content
                },
                layout = wibox.container.place
            },

            bg = bg,

            shape = shapes.rounded_rect(100),

            widget = wibox.container.background
        }

        widget:connect_signal("mouse::enter", function(self)
            self.bg = lighten_color(bg)
        end)

        widget:connect_signal("mouse::leave", function(self)
            self.bg = bg
        end)

        if callback then
            widget:connect_signal("button::press", no_scroll(function()
                callback()
            end))
        end

        return widget
    end

    --[[
        C ± / x
        7 8 9 -
        4 5 6 +
        1 2 3 =
        000 . =
    ]]

    local grid = wibox.widget {
        homogeneous = true,
        spacing     = 5,

        forced_num_cols = 4,
        forced_num_rows = 5,

        min_rows_size = 48,
        min_cols_size = 48,

        layout = wibox.layout.grid,
    }

    local input = textinput {
        font = get_font(14),

        bind_widget = grid
    }

    local error_shape = wibox.widget {
        layout = wibox.container.background,
        shape = shapes.rounded_rect(100),

        forced_width = 24,
        forced_height = 24,

        bg = "#f5743d",

        visible = false,

        {
            layout = wibox.container.place,
            {
                widget = wibox.widget.textbox,
                text = "!",

                font = get_font(12)
            }
        }
    }

    local error_tooltip = awful.tooltip {
        objects = { error_shape },

        bg = config.popup.bg,
		fg = config.popup.fg,

        text = "I'm an integral!"
    }

    --- Create a callback to append text to the textbox
    ---@param to_append string
    ---@return function callback the callback for create_button
    local function cb_append(to_append)
        return function()
            local text = input:get_text()

            text = text .. to_append

            error_shape.visible = false

            input:set_text(text)
        end
    end

    local function clear()
        error_shape.visible = false

        input:set_text("")
    end

    local function evaluate()
        local text = input:get_text()

        if not #text then
            return
        end

        local res, err = luaxp.evaluate(text, {})

        if res then
            if luaxp.isNull(res) then
                -- I've yet to see this
                input:set_text("= ∅")
            else
                input:set_text("= " .. res)
            end
        else
            if not err then return end

            error_shape.visible = true

            error_tooltip.text = err.message
        end
    end

    input:on_key(function (mod, key)

        if key == "Return" then
            evaluate()
        end
    end)

    grid:add_widget_at(create_button("C", primary_button_color, clear), 1, 1)

    -- TODO this button
    grid:add_widget_at(create_button("±", secondary_button_color), 1, 2)

    grid:add_widget_at(create_button("/", secondary_button_color, cb_append(" / ")), 1, 3)
    grid:add_widget_at(create_button("x", secondary_button_color, cb_append(" * ")), 1, 4)

    grid:add_widget_at(create_button("7", number_button_color, cb_append("7")), 2, 1)
    grid:add_widget_at(create_button("8", number_button_color, cb_append("8")), 2, 2)
    grid:add_widget_at(create_button("9", number_button_color, cb_append("9")), 2, 3)
    grid:add_widget_at(create_button("-", secondary_button_color, cb_append(" - ")), 2, 4)

    grid:add_widget_at(create_button("4", number_button_color, cb_append("4")), 3, 1)
    grid:add_widget_at(create_button("5", number_button_color, cb_append("5")), 3, 2)
    grid:add_widget_at(create_button("6", number_button_color, cb_append("6")), 3, 3)
    grid:add_widget_at(create_button("+", secondary_button_color, cb_append(" + ")), 3, 4)

    grid:add_widget_at(create_button("1", number_button_color, cb_append("1")), 4, 1)
    grid:add_widget_at(create_button("2", number_button_color, cb_append("2")), 4, 2)
    grid:add_widget_at(create_button("3", number_button_color, cb_append("3")), 4, 3)
    grid:add_widget_at(create_button("=", primary_button_color, evaluate), 4, 4, 2, 1)

    grid:add_widget_at(create_button("0", number_button_color, cb_append("0")), 5, 1, 1, 2)
    grid:add_widget_at(create_button(".", number_button_color, cb_append(".")), 5, 3)

    local widget = wibox.widget {
        {
            error_shape,

            input:get_widget(),

            layout = wibox.layout.fixed.horizontal,
            spacing = 5
        },

        grid,

        forced_width = 207,

        layout = wibox.layout.fixed.vertical,
        spacing = 15,
    }

    return widget
end

Calculator = applet(create_calculator()):create()

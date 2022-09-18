local wibox  = require("wibox")
local shapes = require("util.shapes")
local config = require("config")
local lighten_color = require("util.color.lighten")

local exitable_dialog = require("widgets.util.exitable_dialog")
local textinput = require("widgets.components.textinput")

local get_font = require("util.get_font")
local get_decoration_color = require("util.color.get_decoration_color")

local function create_calculator ()
    local primary_button_color = get_decoration_color()
    local number_button_color = "#333"
    local secondary_button_color = config.progressbar.bg

    -- TODO custom math interpreter - bc has too many pitfalls
    -- content -> BEDMAS -> ordered table -> simple AST -> output

    local content = ""

    -- TODO degree mode switch!

    local function create_button (content, bg, callback) 
        local widget =  wibox.widget {
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

        widget:connect_signal("mouse::enter", function (self)
            self.bg = lighten_color(bg)
        end)

        widget:connect_signal("mouse::leave", function (self)
            self.bg = bg
        end)

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
        homogeneous   = true,
        spacing       = 5,

        forced_num_cols = 4,
        forced_num_rows = 5,

        min_rows_size = 48,
        min_cols_size = 48,

        layout        = wibox.layout.grid,
    }
    

    grid:add_widget_at(create_button("C", primary_button_color), 1, 1)
    grid:add_widget_at(create_button("±", secondary_button_color), 1, 2)
    grid:add_widget_at(create_button("/", secondary_button_color), 1, 3)
    grid:add_widget_at(create_button("x", secondary_button_color), 1, 4)
    
    grid:add_widget_at(create_button("7", number_button_color), 2, 1)
    grid:add_widget_at(create_button("8", number_button_color), 2, 2)
    grid:add_widget_at(create_button("9", number_button_color), 2, 3)
    grid:add_widget_at(create_button("-", secondary_button_color), 2, 4)
    
    grid:add_widget_at(create_button("4", number_button_color), 3, 1)
    grid:add_widget_at(create_button("5", number_button_color), 3, 2)
    grid:add_widget_at(create_button("6", number_button_color), 3, 3)
    grid:add_widget_at(create_button("+", secondary_button_color), 3, 4)
    
    grid:add_widget_at(create_button("1", number_button_color), 4, 1)
    grid:add_widget_at(create_button("2", number_button_color), 4, 2)
    grid:add_widget_at(create_button("3", number_button_color), 4, 3)
    grid:add_widget_at(create_button("=", primary_button_color), 4, 4, 2, 1)
    
    grid:add_widget_at(create_button("0", number_button_color), 5, 1, 1, 2)
    grid:add_widget_at(create_button(".", number_button_color), 5, 3)

    local input = textinput()

    local widget = wibox.widget {
        input:get_widget(),
        
        grid,

        forced_width = 207,

        layout = wibox.layout.fixed.vertical,
        spacing = 15,
    }
    
    return exitable_dialog {
        widget = widget
    }
end

local calculator = create_calculator()

Calculator = {
    show = function ()
        calculator.visible = true
    end,
    toggle = function()
        calculator.visible = not calculator.visible
    end
}
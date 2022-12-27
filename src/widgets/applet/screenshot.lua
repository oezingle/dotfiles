local wibox  = require("wibox")
local gtable = require("gears.table")
local awful  = require("awful")

local switch    = require("src.widgets.components.switch")
local select    = require("src.widgets.components.select")
local textinput = require("src.widgets.components.textinput")
local get_font  = require("src.util.get_font")

local applet = require("src.widgets.helper.applet")

local function take_screenshot(args)
    local mouse_flag = args.include_mouse and "-p " or ""

    local file_path = args.save_to_clipboard and
        "'/tmp/%F_%T_$wx$h.png' -e 'xclip -selection clipboard -target image/png -i $f'" or
        "'/tmp/scrot.png'; mv /tmp/scrot.png $(zenity --file-selection --save --title='Save Your Screenshot' --filename=$HOME/Pictures/screenshot.png)"

    local delay = (args.delay or 0) + 0.4

    local area = ""

    if args.area then
        local x = args.area.x
        local y = args.area.y
        local w = args.area.width
        local h = args.area.height

        local s = tostring

        area = "-a " .. s(x) .. "," .. s(y) .. "," .. s(w) .. "," .. s(h) .. " "
    end

    local select_area_flag = args.select_area and "-s " or ""

    local window = args.window and
        "-b -s " or
        ""

    local screenshot_script =
    "sleep " .. tostring(delay) .. "; scrot -o " .. mouse_flag .. select_area_flag .. window .. area .. file_path

    awful.spawn.with_shell(screenshot_script)
end

-- TODO custom screenshot area select
-- fullscreen wibox on current screen with border and draggable circles
-- pres enter to take screenshot, escape to cancel

local function create_screenshot_util()
    -- using a grid because homogeneous option
    local grid = wibox.widget {
        homogeneous = true,
        spacing     = 5,

        forced_num_cols = 3,
        forced_num_rows = 5,

        min_rows_size = 32,
        min_cols_size = 96,

        layout = wibox.layout.grid,
    }

    -- its good enough for now
    local mode_dropdown = wibox.widget {
        widget = select,
        options = {
            "Current Display",
            "Select Window",
            "Select Area"
        }
    }

    grid:add_widget_at(
        mode_dropdown,
        1, 1, 1, 3
    )

    grid:add_widget_at(
        wibox.widget {
            widget = wibox.widget.textbox,
            text = "Include Mouse Pointer",
            font = get_font(10)
        },
        2, 1, 1, 2
    )

    local include_mouse = true

    grid:add_widget_at(
        wibox.widget {
            {
                switch(function()
                    include_mouse = not include_mouse
                end, include_mouse),

                layout = wibox.container.margin,
                marigns = 1,
                forced_width = 34,
                forced_height = 18,
            },

            layout = wibox.container.place,
            halign = "right"
        },
        2, 3
    )

    grid:add_widget_at(
        wibox.widget {
            widget = wibox.widget.textbox,
            text = "Save Screenshot to Clipboard",
            font = get_font(10)
        },
        3, 1, 1, 2
    )

    local save_to_clipboard = false

    grid:add_widget_at(
        wibox.widget {
            {
                switch(function()
                    save_to_clipboard = not save_to_clipboard
                end, save_to_clipboard),

                layout = wibox.container.margin,
                marigns = 1,
                forced_width = 34,
                forced_height = 18,
            },

            layout = wibox.container.place,
            halign = "right"
        },
        3, 3
    )

    grid:add_widget_at(
        wibox.widget {
            widget = wibox.widget.textbox,
            text = "Delay",
            font = get_font(10)
        },
        4, 1, 1, 2
    )

    local delay_input = textinput {
        forced_width = 32,

        validator = function(text)
            return type(tonumber(text)) ~= "nil"
        end
    }
    delay_input:set_text("0")

    grid:add_widget_at(
        wibox.widget {
            {
                delay_input:get_widget(),
                {
                    widget = wibox.widget.textbox,
                    text = "s",
                    font = get_font(10)
                },

                layout = wibox.layout.fixed.horizontal,
                spacing = 3,
            },
            layout = wibox.container.place,
            halign = "right"
        },
        4, 3
    )

    local screenshot_button = applet.toolkit.button("Take a Screenshot!", function()
        local selected_index = mode_dropdown:get_choice()

        if selected_index then
            Screenshot.hide()

            local screenshot_args = {
                save_to_clipboard = save_to_clipboard,
                include_mouse = include_mouse,
                delay = tonumber(delay_input:get_text() or 0) -- allow for nil (invalid) text values
            }

            if selected_index == 1 then
                take_screenshot(screenshot_args)
            elseif selected_index == 2 then
                gtable.crush(screenshot_args, {
                    window = true
                })

                take_screenshot(screenshot_args)
            elseif selected_index == 3 then
                gtable.crush(screenshot_args, {
                    select_area = true
                })

                -- TODO scrot's area selection leaves MUCH to be desired

                take_screenshot(screenshot_args)
            end
        end
    end)

    grid:add_widget_at(screenshot_button, 5, 1, 1, 3)

    local widget = wibox.widget {
        {
            {
                widget = wibox.widget.textbox,
                text = "Take a Screenshot!",
                font = get_font(14)
            },
            grid,

            layout = wibox.layout.fixed.vertical,
            spacing = 5,
        },
        layout = wibox.container.margin,
        margins = 2

    }

    local on_close = function()
        mode_dropdown:hide()
    end

    return widget, on_close
end

do
    local screenshot_widget, on_close = create_screenshot_util()

    local screenshot_applet = applet(screenshot_widget, {
        "scrot"
    })

    screenshot_applet:on_close(on_close)

    Screenshot = screenshot_applet:create()
end

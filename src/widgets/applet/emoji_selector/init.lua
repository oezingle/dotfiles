local applet = require("src.widgets.helper.applet")
local atk = require("src.widgets.helper.applet.toolkit")
local textinput = require("src.widgets.element.textinput")
local get_font  = require("src.util.get_font")

local awful = require("awful")
local wibox = require("wibox")

local directories = require("src.util.fs.directories")
local backend = require("src.widgets.applet.emoji_selector.backend")

-- TODO finish this

local function create_emoji_selector()
    local icons = {
        ["Smileys & Emotion"] = "happy-outline",
        ["People & Body"] = "body-outline",
        ["Animals & Nature"] = "leaf-outline",
        ["Food & Drink"] = "fast-food-outline",
        ["Travel & Places"] = "bus-outline",
        ["Activities"] = "bicycle-outline",
        ["Objects"] = "bulb-outline",
        ["Symbols"] = "calculator-outline",
        ["Flags"] = "flag-outline"
    }

    local COLUMNS = 12

    -- TODO scrollbar

    local emoji_results = wibox.widget {
        layout = wibox.layout.grid,

        forced_num_cols = COLUMNS,
        forced_num_rows = 5,

        spacing = 5,

        min_cols_size = 32,
        min_rows_size = 32
    }

    -- pixel scroll
    local emoji_scroll = 0

    ---@type DeserializedEmoji[]
    local emojis = {}

    local function render_emojis()
        emoji_results:reset()

        for i, result in ipairs(emojis) do
            local index = i - (emoji_scroll * COLUMNS)

            local function on_button (w)
                local text = w:get_children_by_id("button-text")[1].text

                awful.spawn("xdotool type \"" .. text .. "\"")
            end

            if index > 0 and index <= COLUMNS * 5 then
                emoji_results:add(atk.button(result.emoji, on_button))
            end
        end
    end

    emoji_results:connect_signal("button::press", function(_, _, _, button)
        if button == 4 or button == 5 then
            if button == 4 then
                emoji_scroll = emoji_scroll - 1

                if emoji_scroll < 0 then
                    emoji_scroll = 0
                end
            elseif button == 5 then
                emoji_scroll = emoji_scroll + 1

                local scroll_max = math.ceil(#emojis / COLUMNS) - 5

                if emoji_scroll > scroll_max then
                    emoji_scroll = scroll_max
                end
            end

            render_emojis()
        end

    end)

    ---@param results DeserializedEmoji[]
    local function set_results(results)
        emojis = results

        emoji_scroll = 0

        render_emojis()
    end

    set_results(backend.get_all())

    local category_buttons = {
        layout = wibox.layout.fixed.horizontal,
        spacing = 5
    }

    do
        table.insert(category_buttons, atk.widget_button(
            {
                widget = wibox.widget.imagebox,
                    image = directories.icon .. "emoji-selector/globe-outline.svg",
                    forced_width = 32,
                    forced_height = 32,
            },
            function()
                local emojis = backend.get_all()

                set_results(emojis)
            end
        ))

        local categories = backend.get_categories()

        for _, category in ipairs(categories) do
            local svg_file = icons[category]

            local icon_path = svg_file and
                (directories.icon .. "emoji-selector/" .. svg_file .. ".svg") or
                (directories.icon .. "scratch-term/help-circle-outline.svg")

            table.insert(category_buttons, atk.widget_button(
                {
                    widget = wibox.widget.imagebox,
                    image = icon_path,
                    forced_width = 32,
                    forced_height = 32,

                    -- Stylesheets aren't supported in this version of awesome :(
                    -- stylesheet = "svg { stroke: #ff0000; }"
                },
                function()
                    local emojis = backend.find_category(category)

                    set_results(emojis)
                end
            ))
        end
    end

    ---@type TextInput
    local input = textinput {
        font = get_font(18)
    }

    input:on_text_changed(function (text)
        local emojis = backend.find_term(text)

        set_results(emojis)
    end)

    local widget = {
        atk.body("Emoji Selector"),

        {
            layout = wibox.container.place,
            forced_width = 380,
            input:get_widget(),
        },

        -- Emoji results
        emoji_results,

        {
            layout = wibox.container.place,
            category_buttons
        },

        layout = wibox.layout.fixed.vertical,
        spacing = 5,
    }

    return widget
end

EmojiSelector = applet(create_emoji_selector()):create()

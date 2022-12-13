local atk   = require("src.widgets.applet.applet.toolkit")
local wibox = require("wibox")
local wal   = require("src.util.wal")

local function color_box(id)
    return {
        {
            {
                layout = wibox.container.margin,
                margins = 16,
            },
            layout = wibox.container.background,
            id = "colors-" .. id,
            bg = "#000000",
        },
        {
            atk.tiny(id),
            layout = wibox.container.place,
        },

        spacing = 2,
        layout = wibox.layout.fixed.vertical,
    }
end

local function create_pywal_info()
    local row0 = {
        layout = wibox.layout.fixed.horizontal,
        spacing = 5
    }

    for i = 0, 7 do
        table.insert(row0, color_box(tostring(i)))
    end

    local row1 = {
        layout = wibox.layout.fixed.horizontal,
        spacing = 5
    }

    for i = 8, 15 do
        table.insert(row1, color_box(tostring(i)))
    end

    local page = wibox.widget {
        atk.title("Pywal Colors"),

        {
            color_box("foreground"),
            color_box("background"),
            color_box("cursor"),

            layout = wibox.layout.fixed.horizontal,
            spacing = 5,
        },

        row0,

        row1,

        layout = wibox.layout.fixed.vertical,
        spacing = 5,
    }

    wal.on_change(function(scheme)
        page:get_children_by_id("colors-foreground")[1].bg = scheme.special.foreground
        page:get_children_by_id("colors-background")[1].bg = scheme.special.background
        page:get_children_by_id("colors-cursor")[1].bg = scheme.special.cursor

        for i = 0, 15 do
            page:get_children_by_id("colors-" .. tostring(i))[1].bg = scheme.colors["color" .. tostring(i)]
        end
    end)

    return page
end

return create_pywal_info

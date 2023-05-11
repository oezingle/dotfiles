local gtable = require("gears.table")
local wibox = require("wibox")
local base = wibox.widget.base

local ensure_client_decoration = require("src.client.colorize")

local config = require("config")
local shapes = require("src.util.shapes")
local Class = require("src.util.Class")

local client_preview = require("src.widgets.element.client_preview")
local get_wallpaper = require("src.util.wallpaper_old.get_wallpaper")
local clienticon_or_xorg = require("src.widgets.element.clienticon_or_xorg")

local tag_preview = {}

local pack = require("src.agnostic.version.pack")

function tag_preview:fit(context, width, height)
    return width, height
end

function tag_preview:layout(context, d_width, d_height)

    local t = self._private.tag

    local fast = self._private.fast

    local s = t.screen

    local s_width = s.geometry.width
    local s_height = s.geometry.height

    local scale_x = d_width / s_width
    local scale_y = d_height / s_height

    local width = s_width * scale_x
    local height = s_height * scale_y

    local virtual_desktop = wibox.widget {
        layout = wibox.layout.manual
    }

    for _, c in ipairs(t:clients()) do
        local preview

        if fast then
            ensure_client_decoration(c)

            preview = wibox.widget {
                layout = wibox.container.background,
                bg = config.popup.bg,

                shape_border_width = config.border.floating_width * scale_x,
                shape_border_color = c.decoration_color,

                shape = shapes.rounded_rect(),

                {
                    clienticon_or_xorg(c),
                    layout = wibox.container.place,
                },
            }
        else
            preview = client_preview(c)
        end

        virtual_desktop:add_at(preview, {
            x = c.x * scale_x,
            y = c.y * scale_y,
            width = c.width * scale_x,
            height = c.height * scale_y,
        })
    end

    local desktop_wrapper = wibox.widget {
        layout = wibox.layout.stack,

        forced_height = height,
        forced_width = width,

        {
            widget = wibox.widget.imagebox,
            image = get_wallpaper(width, height),
        },
        virtual_desktop
    }

    return { base.place_widget_at(desktop_wrapper, 0, 0, width, height) }
end

-- Set a new tag
function tag_preview:update(t)
    self._private.tag = t
end

function tag_preview:init_as_function(t, fast)
    assert(t)

    fast = fast or false

    local ret = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(ret, tag_preview, true)

    ret._private.tag = t
    ret._private.fast = fast

    return ret
end

function tag_preview:init_as_table(args)
    return self:init_as_function(args.tag, args.fast)
end

function tag_preview:init(...)
    local args = pack(...)

    if #args == 2 and type(args[2]) == "boolean" then
        return tag_preview:init_as_function(args[1], args[2])
    elseif #args >= 2 and type(args[2]) == "table" then
        return tag_preview:init_as_table(args[2])
    end

end

return Class(tag_preview)

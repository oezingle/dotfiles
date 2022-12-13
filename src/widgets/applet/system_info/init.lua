local applet              = require("src.widgets.applet.applet")
local pagination          = require("src.widgets.util.pagination")
local create_system_load  = require("src.widgets.applet.system_info.pages.system_load")
local create_system_specs = require("src.widgets.applet.system_info.pages.system_specs")
local create_awesome_info = require("src.widgets.applet.system_info.pages.awesome")
local create_pywal_info = require("src.widgets.applet.system_info.pages.pywal")
local shapes              = require("src.util.shapes")
local config              = require("config")

local wibox = require("wibox")

local print = require("src.agnostic.print")

-- TODO page_indicator.visible = false -> property::visible 

local function create_system_info()
    local pages = pagination {
        create_system_load(),
        create_system_specs(),
        create_awesome_info(),
        config.gimmicks.pywal and create_pywal_info()
    }

    local page_indicator = wibox.widget {
        (function () 
            local widgets = {
                layout = wibox.layout.fixed.horizontal,
                spacing = 5
            }

            for _=1,#pages.children do
                table.insert(widgets, {
                    {
                        layout = wibox.container.margin,
                        margins = 5,
                    },

                    shape = shapes.rounded_rect(100),
                    layout = wibox.container.background,

                    bg = config.tag.occupied,

                    id = "page-indicator-dot"
                })
            end

            return widgets
        end)(),
        layout = wibox.container.place
    }

    pages:connect_signal("property::page", function (p)
        local dots = page_indicator:get_children_by_id("page-indicator-dot")

        for _, dot in ipairs(dots) do
            dot.bg = config.tag.occupied
        end

        dots[p.page].bg = config.tag.focus
    end)

    pages:emit_signal("property::page")

    local paginated = wibox.widget {
        pages,

        {
            applet.toolkit.button("Prev", function()
                pages:prev()
            end),

            page_indicator,

            applet.toolkit.button("Next", function()
                pages:next()
            end),

            layout = wibox.layout.flex.horizontal,
            spacing = 5
        },

        layout = wibox.layout.fixed.vertical,

        spacing = 5,
    }

    paginated:connect_signal("property::visible", function (w)
        pages.visible = w.visible

        pages:emit_signal("property::visible")
    end)

    return paginated
end

do
    local system_info = create_system_info()

    local system_info_applet = applet(system_info, {
        -- dependencies
        "mpstat"
    })

    system_info_applet:on_close(function ()
        system_info.visible = false

        system_info:emit_signal("property::visible")
    end)

    system_info_applet:on_open(function ()
        system_info.visible = true

        system_info:emit_signal("property::visible")    
    end)

    SystemInfo = system_info_applet:create()
end

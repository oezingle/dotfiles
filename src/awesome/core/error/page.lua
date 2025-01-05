local wibox      = require("wibox")
local log_error  = require("src.awesome.core.error.log_error")

local has_service, Service    = pcall(require, "src.util.Service.Service")

local error_page = {}

-- TODO FIXME button for restart, button to hide wibox and open text editor with error log

---@param s Awesome.Screen
---@param err string
function error_page.display_for_screen(s, err)
    local widget = wibox.widget {
        widget = wibox.widget.textbox,
        text = "An unrecoverable error occurred!\n\n" .. tostring(err),
        font = "Monospace 12"
    }

    wibox {
        x = s.geometry.x,
        y = s.geometry.y,
        width = s.geometry.width,
        height = s.geometry.height,

        screen = s,

        ontop = true,
        visible = true,

        ---@type Awesome.Client.Type
        type = "dialog",

        -- TODO FIXME configurable this
        bg = "#00000099",

        widget = widget
    }
end

-- TODO FIXME better error entrypoint than this!
---@param err string
function error_page.display(err)
    log.fatal(err)

    log_error(err)

    pcall(function()
        if has_service then
            Service.stop_all({ "cli" })
                :after(function()
                    log.info("Successfully stopped all services")
                end)
        end
    end)

    for s in screen do
        error_page.display_for_screen(s, err)
    end
end

return error_page

local radial_menu      = require("src.widgets.util.radial_menu")
local scratch_terminal = require("src.util.scratch").terminal
local easy_menu_item   = require("src.widgets.util.radial_menu.easy_menu_item")

local gfs        = require("gears.filesystem")
local config_dir = gfs.get_configuration_dir()

local function scratch_terminal_widget()
    local langs = {
        {
            name = "Bash",
            cmd  = "bash",
            icon = "terminal-outline"
        },

        {
            name = "Python",
            cmd  = "python",
            icon = "logo-python"
        },

        {
            name = "Node",
            cmd  = "node",
            icon = "logo-nodejs"
        },

        {
            name = "Lua",
            cmd  = "lua",
            icon = "Lua-Logo"
        },

        {
            name = "BC",
            cmd  = "bc",
            icon = "calculator-outline"
        },
    }

    local children = {}

    for _, lang in ipairs(langs) do
        lang.icon = lang.icon or "help-circle-outline"

        local icon = config_dir .. "icon/scratch-term/" .. lang.icon .. ".svg"

        local lang_widget = easy_menu_item(lang.name, icon)
        
        table.insert(children, {
            widget = lang_widget,

            callback = function()
                scratch_terminal(lang.cmd)
            end
        })
    end

    radial_menu(children, true)
end

return scratch_terminal_widget

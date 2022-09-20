local radial_menu             = require("widgets.util.radial_menu")
local easy_menu_item          = require("widgets.util.radial_menu.easy_menu_item")
local awful                   = require("awful")
local beautiful               = require("beautiful")
local uppercase_first_letters = require("util.uppercase_first_letters")

local function layout_selector()
    local current_screen = awful.screen.focused()

    local current_layout = awful.layout.get(current_screen)

    local children = {}

    for i, layout in ipairs(awful.layout.layouts) do
        local layout_name = uppercase_first_letters(layout.name)

        local name =
            layout.name == current_layout.name and
            ("<b>" .. layout_name .. "</b>") or
            layout_name

        local icon = beautiful["layout_" .. layout.name]

        children[i] = {
            widget = easy_menu_item(name, icon),

            callback = function()
                current_screen.selected_tag.layout = layout
            end
        }
    end

    radial_menu(children, true)
end

return layout_selector

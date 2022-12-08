local radial_menu             = require("src.widgets.util.radial_menu")
local easy_menu_item          = require("src.widgets.util.radial_menu.easy_menu_item")
local awful                   = require("awful")
local beautiful               = require("beautiful")
local uppercase_first_letters = require("src.util.uppercase_first_letters")

---@param dont_use_mouse boolean? if the mouse position should be ignored and the menu should be in the center of the screen
local function layout_selector(dont_use_mouse)
    dont_use_mouse = dont_use_mouse or false

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

    radial_menu(children, not dont_use_mouse)
end

return layout_selector

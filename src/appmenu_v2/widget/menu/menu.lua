local class               = require("lib.30log")
local Promise             = require("src.util.Promise")

local wibox               = require("wibox")

local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module 'widget.menu.button'
local menu_button         = require(folder_of_this_file .. "button")

---@class MenuBuilder : LogBaseFunctions
---@operator call:MenuBuilder
---@field menu_item MenuItem|nil
---@field widget table the internal widget
---@field depth number
---@field layout_table LayoutTable
---@field parent MenuButton|nil
---@field children MenuButton[]
---@field is_hovered boolean
local menu_builder        = class("MenuWidgetBuilder", {})

-- STUPID BAD DEPENDENCY INJECTION
menu_button.set_menu_builder(menu_builder)

function menu_builder:init()
    self.is_hovered = false
end

--- Set the layout and direction table
---@param table LayoutTable
---@param depth number?
function menu_builder:set_layout_table(table, depth)
    depth = depth or 0
    self.depth = depth

    self.layout_table = table

    if table then
        local table_entry = table[self.depth] or table.default

        self:set_layout(table_entry.layout)
    end

    return self
end

---@nodiscard
---@param layout "vertical"|"horizontal"
---@return self self for chaining
function menu_builder:set_layout(layout)
    -- TODO BOOOHOO

    self:_create_widget(layout)

    return self
end

---@param direction Direction|nil
---@return self self for chaining
function menu_builder:set_popup_direction(direction)
    self.popup_direction = direction

    return self
end

function menu_builder:get_children()
    if self.menu_item then
        return self.menu_item:get_children()
            :after(function(children)
                self.children = children

                return self.children
            end)
    else
        return Promise.resolve({})
    end
end

---@param parent MenuButton a button to be this menu's parent
---@return self self for chaining
function menu_builder:set_parent(parent)
    self.parent = parent

    return self
end

-- TODO this is my trouble rn - on mouse hover generate self.child - MenuBuilder with popup.
-- TODO don't rely on mouse however, as keyboard control is important too
---@param menu_item MenuItem|nil
---@return self self for chaining
function menu_builder:set_menu_item(menu_item)
    self.menu_item = menu_item

    self:get_children()
    ---@param children MenuItem[]
        :after(function(children)
            self.widget:reset()

            self.children = {}

            for i, child in ipairs(children) do
                local button = menu_button(child)
                    :set_layout_table(self.layout_table, self.depth)
                    :set_parent(self)

                self.children[i] = button

                self.widget:add(button:get_widget())
            end
        end)
        :catch(function(err)
            print(debug.traceback(err))
        end)

    return self
end

--- Pass signals to the widget
---@deprecated this works, but use MenuBuilder.widget:emit_signal()
---@param name string
---@param ... any
function menu_builder:emit_signal(name, ...)
    self.widget:emit_signal(name, ...)
end

--- Connect a signal callback to the widget
---@deprecated this works, but use MenuBuilder.widget:connect_signal()
---@param name string
---@param callback function
function menu_builder:connect_signal(name, callback)
    self.widget:connect_signal(name, callback)
end

--- Internal function
---@param layout_name "vertical" | "horizontal"
function menu_builder:_create_widget(layout_name)
    local layout

    if layout_name == "vertical" then
        layout = wibox.layout.fixed.vertical
    else
        layout = wibox.layout.fixed.horizontal
    end

    -- TODO pywal background
    -- TODO minumum width/height - child that exists only to have a forced size property
    local widget = wibox.widget {
        layout = layout,
        spacing = 2,

        {
            widget = wibox.widget.textbox,
            text = "FUCK EM ALL 100000 DEAD COPS"
        }
    }

    widget:connect_signal("mouse::leave", function()
        self.is_hovered = false
    end)

    widget:connect_signal("mouse::enter", function()
        self.is_hovered = true
    end)

    widget:connect_signal("menu_item::child::activated", function()
        -- self:leave_children()

        self.parent.widget:emit_signal("menu_item::child::activated")
    end)

    self.widget = widget
end

--- Check if any children are hovered, and if they are return true
---@return integer|nil, MenuButton|nil
function menu_builder:child_hovered()
    for i, child in ipairs(self.children) do
        if child.is_hovered or child:child_hovered() then
            return i, child
        end
    end
end

--- Call the leave handler for all children, closing menus that may be waiting for removal
function menu_builder:leave_children()
    for _, child in ipairs(self.children) do
        child:leave()
    end
end

--- Generate the menu widget.
function menu_builder:get_widget()
    return self.widget
end

return menu_builder

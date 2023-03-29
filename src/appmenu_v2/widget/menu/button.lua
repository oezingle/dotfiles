local class     = require("lib.30log")

local wibox     = require("wibox")
local awful     = require("awful")
local gtimer    = require("gears.timer")

local get_font  = require("src.util.get_font")
local no_scroll = require("src.widgets.helper.no_scroll")
local wal       = require("src.util.wal")
local config    = require("config")

---@module "widget.menu.menu"
local menu_builder

---@alias MenuLayout { layout: "vertical" | "horizontal", popup_direction: Direction, click_focus: boolean?, has_focus: boolean? }
---@alias LayoutTable table<number|"default", MenuLayout>

-- TODO some sort of state table
--[[
    {
        mouse: boolean = false (hover to grab children, click to activate)
        keyboard: boolean = false (arrow keys to move around buttons, enter to activate, esc to close children)
    }
]]
-- TODO highlight keyboard shortcuts if using keyboard control
-- Reformat text to bold on keyboard::activate signal?

---@class MenuButton : LogBaseFunctions
---@operator call:MenuButton
---@field menu_item MenuItem
---@field parent MenuBuilder|nil a parent widget
---@field popup_direction Direction the direction the popup faces
---@field popup table|nil the popup for this menu's children
---@field widget table the button widget itself
---@field layout_table LayoutTable the table of popup directions, button widget layouts, and click focus rules for all menus and menu buttons
---@field layout_table_entry MenuLayout the menu layout table entry that reflects the depth of this button
---@field depth number
---@field click_focus boolean
---@field child MenuBuilder|nil
---@field is_hovered boolean
local menu_button = class("MenuButton")

---@param menu_item MenuItem
function menu_button:init(menu_item)
    self.menu_item = menu_item

    self:set_popup_direction("right")

    self.click_focus = false
    self.is_hovered = false

    self:_create_widget()
end

---@param parent MenuBuilder a parent widget
---@return self self for convienience
function menu_button:set_parent(parent)
    self.parent = parent

    return self
end

--- Set the layout and direction table
---@param table LayoutTable
---@param depth number?
function menu_button:set_layout_table(table, depth)
    depth = depth or 0
    self.depth = depth

    self.layout_table = table

    self.layout_table_entry = table[self.depth] or table.default

    self:set_popup_direction(self.layout_table_entry.popup_direction)

    self.click_focus = self.layout_table_entry.click_focus or false

    return self
end

---@param popup_direction Direction
---@return self self for convienience
function menu_button:set_popup_direction(popup_direction)
    self.popup_direction = popup_direction

    return self
end

function menu_button:_format_label()
    local is_keygrabbing = false

    return self.menu_item.label:gsub("_(%a)", is_keygrabbing and "<b>%1</b>" or "%1")
end

function menu_button:activate()
    self.menu_item:activate()
        :after(function()
            if self.parent then
                self.parent.widget:emit_signal("menu_item::child::activated")
            end
        end)
end

function menu_button:hover()
    if self.parent then
        self.parent:leave_children()
    end

    self.widget.bg = config.button.hover

    self.is_hovered = true

    -- shout out MACM 101 - A -> B <=> ~A v B
    -- keep the menu item from getting too excited if click
    -- focus is enabled and the menu item isn't clicked yet
    if not self.click_focus or self.layout_table_entry.has_focus then
        self.menu_item:has_children()
            :after(function(has_children)
                if not has_children then
                    return
                end

                self.child = menu_builder()
                    :set_layout_table(self.layout_table, self.depth + 1)
                    :set_menu_item(self.menu_item)
                    :set_popup_direction(self.popup_direction)
                    :set_parent(self)

                if self.popup then
                    self.popup.widget = self.child
                        :get_widget()
                else
                    self.popup = awful.popup {
                        widget = self.child
                            :get_widget(),

                        ontop = true,
                        visible = true,

                        bg = config.taskbar.bg,
                        fg = config.popup.fg,

                        preferred_positions = { self.popup_direction },
                        preferred_anchors = { 'front' }
                    }
                end

                -- Move to mouse
                -- TODO why so wonky
                do
                    local geo = mouse.current_widget_geometry

                    if geo then
                        -- move to mouse
                        self.popup:move_next_to(geo)
                    end
                end
            end)
    end
end

--- Check if the child menu has a hovered item
function menu_button:child_hovered()
    if self.child and (self.child:child_hovered() or self.child.is_hovered) then
        return true
    else
        return false
    end
end

--- Close the popup
---@param force boolean? if the widget should ignore the mouse
function menu_button:leave(force)
    -- Don't close if an item in a child menu is hovered
    if not force and self:child_hovered() then
        return
    end

    if self.popup then
        self.popup.visible = false

        self.popup = nil
    end

    self.is_hovered = false

    self.widget.bg = nil
end

function menu_button:_create_widget()
    local button = nil

    if self.menu_item.label == "" then
        button = wibox.widget {
            layout = wibox.container.margin,
            margins = 5
        }
    else
        button = wibox.widget {
            layout = wibox.container.background,
            {
                layout = wibox.container.margin,
                margins = 2,
                {
                    widget = wibox.widget.textbox,
                    font = get_font(13),
                    markup = self:_format_label()
                }
            }
        }

        wal.on_change(function(scheme)
            button.fg = scheme.special.foreground
        end)

        --- TODO deactivate siblings

        button:connect_signal("button::press", no_scroll(function()
            if self.click_focus then
                self.layout_table_entry.has_focus = not self.layout_table_entry.has_focus

                if self.layout_table_entry.has_focus then
                    self:hover()
                else
                    self:leave()
                end
            else
                self:activate()
            end
        end))

        local mouse_leave_timer = gtimer {
            timeout = 0.2,
            single_shot = true,

            callback = function()
                self:leave()
            end
        }

        button:connect_signal("mouse::enter", function()
            self:hover()

            if mouse_leave_timer.started then
                mouse_leave_timer:stop()
            end
        end)

        button:connect_signal("mouse::leave", function(widget)
            mouse_leave_timer:start()

            widget.bg = nil
        end)

        button:connect_signal("menu_item::child::activated", function()
            if self.layout_table_entry.has_focus then
                self.layout_table_entry.has_focus = false
            end
            
            self:leave(true)

            if self.parent then
                self.parent.widget:emit_signal("menu_item::child::activated")
            end
        end)
    end

    self.widget = button
end

function menu_button:get_widget()
    return self.widget
end

--- A really stupid function
---@param menu_builder_ MenuBuilder
function menu_button.set_menu_builder(menu_builder_)
    menu_builder = menu_builder_
end

return menu_button

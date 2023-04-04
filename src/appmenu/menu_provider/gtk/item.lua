local class = require("lib.30log")

local GVariant = require("src.util.lgi.GVariant")
local Promise = require("src.util.Promise")
local gvariant_ipairs = require("src.util.lgi.gvariant_ipairs")

local divider_item = require("src.appmenu.menu_provider.divider")

-- TODO calling org.gtk.Menus.End is good practice, but not required
-- TODO menu number is hard coded here as 0

---@class GTKMenuItem : MenuItem
---@field activate fun(self: MenuItem): Promise<nil>
---@field get_children fun(self: MenuItem): Promise<MenuItem[]>
---@field proxies { menu: SmartProxy, actions: SmartProxy }
---@field subsciption_group number
---@field label string?
---@field action string?
---@field children GTKMenuItem[]|nil
local gtk_menu_item = class("GTKMenuItem", {})

---@param proxies { menu: SmartProxy, actions: SmartProxy }
---@param subscription_group number
---@param label string?
---@param action string?
function gtk_menu_item:init(proxies, subscription_group, label, action)
    -- TODO signals are broken
    proxies.menu.connect_signal("Changed", function()
        self:_invalidate_children()
    end)

    self.proxies = proxies

    self.subsciption_group = subscription_group

    self.label = label

    self.action = action

    self:_invalidate_children()
end

function gtk_menu_item:activate()
    return Promise(function(res, rej)
        if not self.action then
            -- No bound action id for this menu item, so no action taken

            res(false)

            return
        end

        local action = self.action:gsub("unity%.", "")

        local activate_variant = GVariant("(sava{sv})", { action, {}, {} })

        xpcall(function ()
            self.proxies.actions.method.Activate(activate_variant)        
        end, rej)

        res(true)
    end)
end

---@alias DBusGTKMenuItem table<string, any>
---@alias DBusGTKMenuAction { [1]: number, [2]: number, [3]: DBusGTKMenuItem[] }

--- Find the right action by subscription group and menu number,
--- and then return the action's sub-items
---@param actions DBusGTKMenuAction[]
---@param subcription number
---@param menu number
---@return DBusGTKMenuItem|nil
local function get_action_menu_items(actions, subcription, menu)
    for _, action in gvariant_ipairs(actions) do
        local action_subscription = action[1]
        local action_menu = action[2]

        if subcription == action_subscription and menu == action_menu then
            return action[3]
        end
    end

    --- This can sometimes happen. maybe print a warn? idk

    -- -- I've realised idk how to get the right information to trace back
    -- print("Warning: Menu item for ")

    return nil
end

--- Get the menu items from all the actions and a specific action
--- subsciption group and menu number
---
--- GTK menu items can have :section tags, which reference another menu
--- this is common, as GTK apps love to expose a section as the only child of a menu.
--- Recursively find these sections, and resolve them as if they are native child elements.
---
--- Entries with multiple sections are handled as multiple sections.
---@param actions DBusGTKMenuAction[]
---@param subscription_group number
---@param menu_number number
---@return DBusGTKMenuItem[]
local function resolve_menu(actions, subscription_group, menu_number)
    local action = get_action_menu_items(actions, subscription_group, menu_number)

    if not action then
        return {}
    end

    local menu_items = {}

    for _, menu_item in gvariant_ipairs(action) do
        -- Section is a GVariant that points to another GTK Menu or nil
        local section = menu_item[":section"]

        if section then
            -- find child menu, recursively insert these items

            local section_subscription = section[1]
            local section_menu = section[2]

            local child_items = resolve_menu(
                actions,
                section_subscription,
                section_menu
            )

            for _, inherited in ipairs(child_items) do
                table.insert(menu_items, inherited)
            end

            -- Section divider
            table.insert(menu_items, {})
        else
            -- simple insertion
            table.insert(menu_items, menu_item)
        end
    end

    if not menu_items[#menu_items].label then
        menu_items[#menu_items] = nil
    end

    return menu_items
end

function gtk_menu_item:_invalidate_children()
    self.children = nil
end

--- TODO promsifiy
function gtk_menu_item:_get_children_uncached()
    self:_invalidate_children()

    self.children = {}

    local action_variant = GVariant("(au)", { { self.subsciption_group } })

    -- org.gtk.Menus.Start takes an array of subsciption groups,
    -- but this implementation only provides one, so skip to the actions
    -- provided by this single item
    local actions = self.proxies.menu.method.Start(action_variant)[1]

    local menu_items = resolve_menu(actions, self.subsciption_group, 0)

    -- Turn these menu items from DBus data into Lua objects
    for _, menu_item in ipairs(menu_items) do
        -- for some reason next(menu_item) doesn't work - LGI bug?
        if menu_item.label then
            local label = menu_item.label
            local action = menu_item.action

            -- Grab the information for the child's submenu, if it has one
            local submenu = menu_item[":submenu"]

            local submenu_subscription = submenu and submenu[1] or nil

            local new_menu_item = gtk_menu_item(
                self.proxies,
                submenu_subscription,
                label,
                action
            )

            table.insert(self.children, new_menu_item)
        else
            table.insert(self.children, divider_item())
        end
    end
end

function gtk_menu_item:get_children()
    return Promise(function(res, rej)
        -- I used to check if the table was empty using
        -- next(self.children), but a childless menu would reload
        -- constantly even if the lack of children was already known

        if not self.children then
            xpcall(function ()
                self:_get_children_uncached()
            end, rej)
        end

        res(self.children)
    end)
end

function gtk_menu_item:has_children()
    return self:get_children()
        :after(function(children)
            return next(children) ~= nil
        end)
end

return gtk_menu_item

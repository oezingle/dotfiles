local class = require("lib.30log")
local gvariant_ipairs = require("src.appmenu.gvariant_ipairs")

-- TODO test signals

-- TODO greyed out options?

local lgi = require("lgi")
local GVariant = lgi.GLib.Variant

local gtk_menu_item = class("GTK Menu Item", {
    MENU_TYPE = "gtk"
})

-- TODO determine if actions are always ordered - O(1) efficiency instead of O(n)
local function gtk_get_action(actions, subscription_group, menu_number)

    for _, action in ipairs(actions) do
        local action_subscription_group = action[1]
        local action_menu_number = action[2]

        if subscription_group == action_subscription_group and
            menu_number == action_menu_number then

            -- return menu items
            return action[3]
        end
    end
end

local function gtk_resolve_sections(actions, subscription_group, menu_number)
    local action = gtk_get_action(actions, subscription_group, menu_number)

    -- apparently :section calls can be nonsensical
    if not action then
        return {}
    end

    local menu_items = {}

    for _, menu_item in gvariant_ipairs(action) do
        local section = menu_item[":section"]

        if section then
            local section_subscription_group = section[1]
            local section_menu_number = section[2]

            for _, inherited_item in ipairs(gtk_resolve_sections(actions, section_subscription_group, section_menu_number)) do
                table.insert(menu_items, inherited_item)
            end
        else
            table.insert(menu_items, menu_item)
        end
    end

    return menu_items
end

-- TODO async
local function gtk_get_children(i_menu_item)
    if type(i_menu_item.subscription_group) == "nil" then
        return
    end

    local action_variant = GVariant('(au)', { { i_menu_item.subscription_group } })

    -- actions are stored in a tuple so we grab the first index immediately
    local actions = i_menu_item._private.menu_proxy.method.Start(action_variant)[1]

    -- the first action's first menu item often has a :section
    local action = gtk_resolve_sections(actions, i_menu_item.subscription_group, 0)

    for _, menu_item in ipairs(action) do
        local label = menu_item.label
        local submenu = menu_item[":submenu"]

        local action = menu_item.action

        local submenu_subscription = submenu and submenu[1] or nil

        local new_menu_item = gtk_menu_item.init(
            {},
            i_menu_item._private.menu_proxy,
            i_menu_item._private.actions_proxy,
            submenu_subscription,
            label,
            action
        )

        setmetatable(new_menu_item, { __index = gtk_menu_item })

        table.insert(
            i_menu_item._private.children,
            new_menu_item
        )
    end
end

function gtk_menu_item:activate()
    if self._private.action then
        local action = self._private.action:gsub("unity%.", "")

        local activate_variant = GVariant("(sava{sv})", { action, {}, {} })

        self._private.actions_proxy.method.Activate(activate_variant)
    end
end

function gtk_menu_item:get_children(callback)
    if next(self._private.children) == nil then
        gtk_get_children(self)
    end

    callback(self._private.children)
end

function gtk_menu_item:init(menu_proxy, actions_proxy, subscription_group, label, action)
    self.subscription_group = subscription_group

    self.label = label

    self._private = {}

    self._private.action = action

    self._private.menu_proxy = menu_proxy
    self._private.actions_proxy = actions_proxy

    -- private cached children table
    self._private.children = {}

    -- TODO signals broken :)
    menu_proxy.connect_signal("Changed", function()
        -- invalidate children cache
        self._private.children = {}
    end)

    return self
end

return gtk_menu_item
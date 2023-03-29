local class = require("lib.30log")
local flags = require("src.appmenu.flags")
local gvariant_ipairs = require("src.util.lgi.gvariant_ipairs")

-- TODO add back the LayoutChanged signal to deal with layout changing while the system sleeps

-- TODO greyed out options?

local agnostic_print = require("src.agnostic.print")

local lgi = require("lgi")
local GVariant = lgi.GLib.Variant

local canonical_menu_item = class("Canonical Menu Item", {
    MENU_TYPE = "canonical"
})

-- TODO async
local function canonical_get_children(i_menu_item)
    local menu_item_children = {}

    local variant = GVariant("(iias)", { i_menu_item.id, 1, {} })

    local res, err = i_menu_item._private.proxy.method.GetLayout(variant)

    if flags.DEBUG then
        if err then
            agnostic_print(err)
        end
    end

    --local revision = res[1]
    --
    --local label = res[2][2].label
    --local children_display = res[2][2]['children-display']

    if not res or not #res or not #res[2] then
        return
    end

    local children = res[2][3]

    for _, child_item in gvariant_ipairs(children) do
        local child_id = child_item[1]
        local child_label = child_item[2].label

        -- child_item[2].shortcut: string[]|nil

        -- tell the child it's going to be visible
        local id_variant = GVariant("(i)", { child_id })

        local _, err = i_menu_item._private.proxy.method.AboutToShow(id_variant)

        if flags.DEBUG then
            if err then
                agnostic_print(err)
            end
        end

        local new_menu_item = canonical_menu_item(
            i_menu_item._private.proxy,
            child_id,
            child_label
        )

        table.insert(
            menu_item_children,
            new_menu_item
        )
    end

    return menu_item_children
end

function canonical_menu_item:activate()
    -- closest I can get to nil
    local nil_variant = GVariant("i", 0)

    local event_variant = GVariant("(isvu)", { self.id, 'clicked', nil_variant, 0 })

    local res, err = self._private.proxy.method.Event(event_variant)

    if flags.DEBUG then
        if err then
            agnostic_print(err)
        end
    end
end

function canonical_menu_item:get_children(callback)
    -- TODO sort out why menu item ids change constantly
    callback(canonical_get_children(self))
end

function canonical_menu_item:init(proxy, id, label)    
    self.id = id

    self.label = label

    self._private = {}

    self._private.proxy = proxy
end

return canonical_menu_item
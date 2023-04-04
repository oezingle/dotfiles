local class = require("lib.30log")

local GVariant = require("src.util.lgi.GVariant")
local Promise = require("src.util.Promise")
local gvariant_ipairs = require("src.util.lgi.gvariant_ipairs")

local divider_item = require("src.appmenu.menu_provider.divider")

---@class CanonicalMenuItem : MenuItem
---@field activate fun(self: MenuItem): Promise<nil>
---@field get_children fun(self: MenuItem): Promise<MenuItem[]>
---@field _has_children boolean|nil
---@field proxy SmartProxy
---@field id number
---@field label string?
---@field shortcut string[]?
local canonical_menu_item = class("CanonicalMenuItem", {
    type = "item"
})

---@param proxy SmartProxy
---@param id number
---@param label string?
---@param shortcut string[]?
function canonical_menu_item:init(proxy, id, label, shortcut)
    self.proxy    = proxy
    self.id       = id
    self.label    = label
    self.shortcut = shortcut
end

function canonical_menu_item:activate()
    -- closest I can get to nil
    local nil_variant = GVariant("i", 0)

    local event_variant = GVariant("(isvu)", { self.id, 'clicked', nil_variant, 0 })

    return Promise(function(res, rej)
        local success = xpcall(function ()
            self.proxy.method.Event(event_variant)        
        end, rej)

        if not success then
            return
        end

        res(true)
    end)
end

function canonical_menu_item:get_children()
    return Promise(function(res, rej)
        local variant = GVariant("(iias)", { self.id, 1, {} })

        local success, layout = xpcall(function ()
            return self.proxy.method.GetLayout(variant)
        end, rej)

        if not success then
            return
        end

        if not layout or not #layout or not #layout[2] then
            res({})
        end

        local children = layout[2][3]

        local menu_item_children = {}

        for _, child_item in gvariant_ipairs(children) do
            local child_id = child_item[1]
            local child_label = child_item[2].label

            -- local child_icon = child_item[2]["icon-name"]

            ---@type string[]?
            local child_shortcut = nil
            if child_item[2].shortcut then
                child_shortcut = {}
                for _, key in ipairs(child_item[2].shortcut[1]) do
                    table.insert(child_shortcut, key)
                end
            end

            -- tell the child it's going to be visible

            if child_label then
                local id_variant = GVariant("(i)", { child_id })

                local success = xpcall(function ()
                    self.proxy.method.AboutToShow(id_variant)                
                end, rej)

                if not success then
                    return
                end

                local new_menu_item = canonical_menu_item(
                    self.proxy,
                    child_id,
                    child_label,
                    child_shortcut
                )

                table.insert(
                    menu_item_children,
                    new_menu_item
                )
            else
                table.insert(menu_item_children, divider_item())
            end
        end

        res(menu_item_children)
    end)
end

-- This much can be cached
function canonical_menu_item:has_children()
    if type(self._has_children) == "nil" then
        return self:get_children()
            :after(function(children)
                return next(children) ~= nil
            end)
            :after(function(has_children)
                self._has_children = has_children

                return has_children
            end)
    else
        return Promise.resolve(self._has_children)
    end
end

return canonical_menu_item

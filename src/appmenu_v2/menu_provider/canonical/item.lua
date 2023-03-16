local class = require("lib.30log")

local GVariant = require("src.util.lgi.GVariant")
local Promise = require("src.util.Promise")
local gvariant_ipairs = require("src.util.lgi.gvariant_ipairs")

local divider_item = require("src.appmenu_v2.menu_provider.divider_item")

---@class CanonicalMenuItem : MenuItem
---@field activate fun(self: MenuItem): Promise<nil>
---@field get_children fun(self: MenuItem): Promise<MenuItem[]>
---@field proxy SmartProxy
---@field id number
---@field label string?
local canonical_menu_item = class("CanonicalMenuItem", {
    type = "item"
})

---@param proxy SmartProxy
---@param id number
---@param label string?
function canonical_menu_item:init(proxy, id, label)
    self.proxy = proxy
    self.id    = id
    self.label = label
end

function canonical_menu_item:activate()
    -- closest I can get to nil
    local nil_variant = GVariant("i", 0)

    local event_variant = GVariant("(isvu)", { self.id, 'clicked', nil_variant, 0 })

    return Promise(function (res)
        self.proxy.method.Event(event_variant)
        
        res()
    end)
end

--- TODO where tf do the nil items come from
function canonical_menu_item:get_children()
    return Promise(function(res)
        local variant = GVariant("(iias)", { self.id, 1, {} })

        local layout = self.proxy.method.GetLayout(variant)

        if not layout or not #layout or not #layout[2] then
            res({})
        end

        local children = layout[2][3]

        local menu_item_children = {}

        for i, child_item in gvariant_ipairs(children) do            
            local child_id = child_item[1]
            local child_label = child_item[2].label

            -- child_item[2].shortcut: string[]|nil

            -- tell the child it's going to be visible

            if child_label then
                local id_variant = GVariant("(i)", { child_id })

                self.proxy.method.AboutToShow(id_variant)
    
                local new_menu_item = canonical_menu_item(
                    self.proxy,
                    child_id,
                    child_label
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

return canonical_menu_item

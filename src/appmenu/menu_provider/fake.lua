local class = require("lib.30log")
local Promise = require("src.util.Promise")

-- TODO inherit children from another MenuItem?

---@class FakeMenuItem : MenuItem
---@field on_activate function|nil
---@field label string
---@field children MenuItem[]
---@field inherit MenuItem|nil
---@operator call:FakeMenuItem
local fake_menu_item = class("FakeMenuItem", {

})

--- Create a fake menu item
---@param label string
---@param on_activate function?
---@param children MenuItem[]?
function fake_menu_item:init(label, on_activate, children)
    self:set_label(label)

    if on_activate then
        self:set_on_activate(on_activate)
    end

    self:set_children(children or {})
end

--- Set a menu item from whom the children returned by this one are merged
---@param menu_item MenuItem
---@return self self for convienience
function fake_menu_item:inherit_children(menu_item)
    self.inherit = menu_item

    return self
end

--- Set the label
---@param label string
---@return self self for convienience
function fake_menu_item:set_label(label)
    self.label = label

    return self
end

---@param on_activate function
---@return self self for convienience
function fake_menu_item:set_on_activate(on_activate)
    self.on_activate = on_activate

    return self
end

function fake_menu_item:activate()
    if self.on_activate then
        return Promise.resolve(self.on_activate(self))
    end
end

--- Set the children for the menu
---@param children MenuItem[]
---@return self self for convienience
function fake_menu_item:set_children(children)
    self.children = children

    return self
end

---@return Promise<MenuItem[]>
function fake_menu_item:get_children()
    return Promise.resolve(self.children)
        :after(function(children)
            if self.inherit then
                local all_children = {}

                for _, child in ipairs(children) do
                    table.insert(all_children, child)
                end

                return self.inherit:get_children()
                    :after(function(inherited_children)
                        for _, child in ipairs(inherited_children) do
                            table.insert(all_children, child)
                        end

                        return all_children
                    end)
            else
                return children
            end
        end)
end

function fake_menu_item:has_children()
    return self:get_children()
        :after(function(children)
            return next(children) ~= nil
        end)
end

return fake_menu_item

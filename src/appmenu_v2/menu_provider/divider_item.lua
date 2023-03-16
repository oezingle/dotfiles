
local class = require("lib.30log")

local Promise = require("src.util.Promise")

---@class DividerMenuItem : MenuItem
local divider_item = class("DividerMenuItem", {
    label = ""
})

function divider_item.activate()
    return Promise.resolve()
end

function divider_item.get_children()
    return Promise.resolve({})
end

return divider_item
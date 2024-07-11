
local Type = require("src.typed.Type")

local map = require("src.polyfill.list.map")

---@class Zingle.Typed.Type.Array : Zingle.Typed.CType
---@field type Zingle.Typed.Type
---@operator call:Zingle.Typed.Type.Array
local Array = Type:extend("Array")

-- TODO FIXME rewrite - this is anti-pattern!! Array(type, { default }) - how do I re-init?

---@param subtype Zingle.Typed.Type
---@param default any[]?
function Array:init(subtype, default)
    self.type = subtype

    self.children = default
end

---@param passed any[]?
function Array:default(passed)
    if passed then
        return passed
    end

    if self.children then
        return self.children
    else
        return { self.type:default() }
    end
end

function Array:check(value)
    if not type(value) == "table" then
        return false, "Expected an iterable table"
    end

    for i, v in ipairs(value) do
        local ok, err = self.type:check(v)

        if not ok then
            return false, string.format("In %dth element: %s", i, err)
        end
    end

    return true
end

function Array:display()
    local subtype = self.type:display()

    return string.format("%s[]", subtype)
end

return Array
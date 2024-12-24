
local Type = require("src.util.typed.Type")
local includes = require("src.polyfill.list.includes")

---@class Zingle.Typed.Type.Literal : Zingle.Typed.CType
---@operator call:Zingle.Typed.Type.Literal
local Literal = Type:extend("Zingle.Typed.Type.Nil")

function Literal:init(value)
    local t = type(value)
    assert(includes({ "string", "number", "boolean" }, t))

    self:set_default(value)
end

function Literal:display()
    local value = self:default()

    if type(value) == "string" then
        return string.format("%q", value)
    else 
        return tostring(value)
    end
end

function Literal:check(value)
    if value ~= self.children[1] then
        return false, "Expected literal value " .. self:display()
    end

    return true
end

return Literal
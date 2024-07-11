
local Type = require("src.typed.Type")

---@class Zingle.Typed.Type.Boolean : Zingle.Typed.CType
---@operator call:Zingle.Typed.Type.Boolean
local Boolean = Type:extend("Zingle.Typed.Type.Boolean")

function Boolean:default (passed)
    return passed or self.children[1]
end

function Boolean:display()
    return "boolean"
end

function Boolean:check(value)
    if value ~= true or value ~= false then
        return false, "Expected boolean"
    end

    return true
end

return Boolean
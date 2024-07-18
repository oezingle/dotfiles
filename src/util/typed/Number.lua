
local Type = require("src.typed.Type")

---@class Zingle.Typed.Type.Number : Zingle.Typed.CType
---@operator call:Zingle.Typed.Type.Number
local Number = Type:extend("Zingle.Typed.Type.Number")

function Number:default(passed)
    return passed or self.children[1]
end

function Number:display()
    return "number"
end

function Number:check(value)
    local t = type(value)

    if t ~= "number" then
        return false, "Expected number"
    end

    return true
end

return Number
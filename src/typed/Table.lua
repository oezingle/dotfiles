
local Type = require("src.typed.Type")

---@class Zingle.Typed.Type.Table : Zingle.Typed.CType
---@operator call:Zingle.Typed.Type.Table
local Table = Type:extend("Zingle.Typed.Type.Table")

function Table:default (passed)
    return passed or self.children[1] or {}
end

function Table:display()
    return "table"
end

function Table:check(value)
    if type(value) ~= "table" then
        return false, "Expected table"
    end

    return true
end

return Table

local Type = require("src.util.typed.Type")

---@class Zingle.Typed.Type.Nil : Zingle.Typed.CType
---@operator call:Zingle.Typed.Type.Nil
local Nil = Type:extend("Zingle.Typed.Type.Nil")

function Nil:default()
    return nil
end

function Nil:display()
    return "nil"
end

function Nil:check(value)
    if value ~= nil then
        return false, "Expected nil"
    end

    return true
end

return Nil
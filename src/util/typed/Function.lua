
local Type = require("src.util.typed.Type")

---@class Zingle.Typed.Type.Function : Zingle.Typed.CType
---@operator call:Zingle.Typed.Type.Function
local Function = Type:extend("Zingle.Typed.Type.Function")

function Function:default (passed)
    return passed or self.children[1]
end

function Function:display()
    return "function"
end

function Function:check(value)
    local t = type(value)

    if t ~= "function" then
        return false, "Expected function"
    end

    return true
end

return Function
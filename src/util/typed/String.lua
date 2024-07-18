local Type = require("src.typed.Type")

---@class Zingle.Typed.Type.String : Zingle.Typed.CType
---@operator call:Zingle.Typed.Type.String
local String = Type:extend("Zingle.Typed.Type.String")

---@param passed string?
function String:default(passed)
    return passed or self.children[1]
end

function String:display()
    return "string"
end

function String:check(value)
    local t = type(value)

    if t ~= "string" then
        return false, "Expected string"
    end

    return true
end

return String

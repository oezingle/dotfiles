local Type = require("src.util.typed.Type")
local map  = require("src.polyfill.list.map")

---@class Zingle.Typed.Type.Union : Zingle.Typed.CType
---@operator call:Zingle.Typed.Type.Union
local Union = Type:extend("Zingle.Typed.Type.Union")

function Union:default(passed)
    return passed or self.children[1]:default()
end

function Union:check(value)
    for _, child in ipairs(self.children) do
        local ok = child:check(value)

        if ok then
            return true
        end
    end

    --- TODO FIXME figure out error messages
    return false, string.format("in %s", self:display())
end

function Union:display()
    return string.format("(%s)", table.concat(map(self.children, function (child)        
        return child:display()
    end), "|"))
end

return Union

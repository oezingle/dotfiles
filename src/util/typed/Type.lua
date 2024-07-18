
local class = require("lib.30log")

---@alias Zingle.Typed.Type.Generator fun(...: any[]): Zingle.Typed.Type

---@alias Zingle.Typed.Type Zingle.Typed.Type.Generator | Zingle.Typed.CType

---@class Zingle.Typed.CType : Log.BaseFunctions
---@field children Zingle.Typed.Type[] By default Types consume child types as arrays.
local Type = class("Zingle.Typed.Type")

Type.display = "Type (Base class)"

function Type:init (...)
    self:set_default(...)
end

function Type:set_default (...)
    self.children = table.pack(...)
end

--- Provide initial arguments to the type constructor, while allowing different arguments.
---@param ... any
function Type:generator (...)
    local generalized = table.pack(...)

    return function (...)
        return self(table.unpack(generalized), ...)
    end
end

function Type:default (passed)
    return passed or self.children[1]
end

--[[
---@param passed any
function Type:default (passed)
    return map(self.children, function (child, key)
        if passed and type(passed) == "table" and passed[key] then
            return passed[key]
        end
        
        return child:default()
    end)
end
]]

-- TODO Type:check()

--- TODO recursions here should have good logic to help make errors easily accessible
---@param value any
---@return boolean, string?
function Type:check(value)
    return false, "Base Type class does not provide checking."
end

---@return string
function Type:display()
    return "Type (Base class)"
end

return Type
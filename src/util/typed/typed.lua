
local typed = {}

typed.Number = require("src.util.typed.Number")
typed.Boolean = require("src.util.typed.Boolean")
typed.String = require("src.util.typed.String")
typed.Function = require("src.util.typed.Function")
typed.Nil = require("src.util.typed.Nil")
typed.Table = require("src.util.typed.Table")

typed.Union = require("src.util.typed.Union")
typed.Array = require("src.util.typed.Array")

typed.KeyedTable = require("src.util.typed.KeyedTable")

---@param type Zingle.Typed.Type
---@param passed any
function typed.default (type, passed) 
    return type:default(passed)
end

---@param type Zingle.Typed.Type
---@param value any
---@return boolean ok, string? err
function typed.check (type, value)
    return type:check(value)
end

return typed
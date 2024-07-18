
local typed = {}

typed.Number = require("src.typed.Number")
typed.Boolean = require("src.typed.Boolean")
typed.String = require("src.typed.String")
typed.Function = require("src.typed.Function")
typed.Nil = require("src.typed.Nil")
typed.Table = require("src.typed.Table")

typed.Union = require("src.typed.Union")
typed.Array = require("src.typed.Array")

typed.KeyedTable = require("src.typed.KeyedTable")

---@param type Zingle.Typed.Type
---@param passed any
function typed.default (type, passed) 
    return type:default(passed)
end

---@param type Zingle.Typed.Type
---@param value any
function typed.check (type, value)
    -- return type:check(value)

    local ok, err = type:check(value)

    if not ok then
        error(err)
    end
end

return typed
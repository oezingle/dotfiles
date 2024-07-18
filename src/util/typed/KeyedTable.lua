local Type = require("src.typed.Type")
local nil_coalesce = require("src.polyfill.nil_coalesce")

--- A table with specific keys as opposed to any value
---@class Zingle.Typed.Type.KeyedTable : Zingle.Typed.CType
---@field children { [1]: table }
---@operator call:Zingle.Typed.Type.KeyedTable
local KeyedTable = Type:extend("Zingle.Typed.Type.KeyedTable")

---@param default table
---@param passed table
---@param deep boolean
function KeyedTable.overwrite_clone (default, passed, deep)
    local t = {}

    for k, v in pairs(default) do
        t[k] = v
    end

    for k, v in pairs(passed) do
        if deep and type(v) == "table" then
            t[k] = KeyedTable.overwrite_clone(t[k] or {}, v, deep)
        else
            t[k] = v
        end
    end

    return t
end

function KeyedTable:default(passed)
    return self.overwrite_clone(self.children[1] or {}, passed or {}, self.is_deep)
end

function KeyedTable:display()
    local keys = {}

    local source_table = self.children[1] or {}

    for k, _ in pairs(source_table) do
        table.insert(keys, string.format("%q", k))
    end

    -- TODO FIXME improve this shit
    return string.format("{ [%s]: any }", table.concat(keys, "|"))
end

--- TODO FIXME impreove this shit
function KeyedTable:check(value)
    if type(value) ~= "table" then
        return false, "Expected table"
    end

    return true
end

---@param deep boolean?
---@return self
function KeyedTable:deep(deep)
    local is_deep = nil_coalesce(deep, true)

    self.is_deep = is_deep

    return self
end

return KeyedTable

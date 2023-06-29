-- table dumpers:
-- http://lua-users.org/wiki/DataDumper - old, unsafe, allows every lua type
-- https://github.com/gvx/Smallfolk - modern, supports inane tables, no closure/thread/

local ftos = require("lib.widgey.f_and_s").ftos

--- Serialize a prop if possible, or return nil
---@param prop any
---@overload fun(prop: nil|number|string|boolean|table|function): string
local function serialize_prop(prop)
    ---@type {["nil" | "number" | "string" | "boolean" | "table" | "function"]: (fun(value: any): string), ["thread" | "userdata"]: (fun(value: any): nil) }
    local serializers = {
        ["nil"] = function(_) return "nil" end,
        ["number"] = function(value) return tostring(value) end,
        ["string"] = function (value) return value end,
        ["boolean"] = function(value) return tostring(value) end,
        
        -- kinda shitty implementation - doesn't allow self-referential tables etc.
        ["table"] = function(value)
            local keyvalues = {}
            
            local mt = getmetatable(value)

            for _, tbl in pairs({ value, mt }) do
                for k, v in pairs(tbl) do
                    local key = ({
                        ["string"] = function (k) return k end,
    
                        -- todo would be cool to return null when i implement that so that
                        -- todo table serialize in a more natural looking way
                        ["number"] = function (n) return string.format("[%d]", n) end,
                        
                        ["boolean"] = function (b) return string.format("[%s]", tostring(b)) end
                    })[type(k)](k)
    
                    local value = serialize_prop(v)
    
                    if key and value then
                        table.insert(keyvalues, string.format("%s = %s", key, value))
                    end
                end                    
            end

            return string.format("{ %s }", table.concat(keyvalues, ", "))
        end,
        ["function"] = function(value)
            return ftos(value, true)
        end
    }

    return serializers[type(prop)](prop) --[[ @as unknown ]]
end

return serialize_prop
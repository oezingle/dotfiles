
-- Convert xml attribute values to lua, with variables (ooo)
---@param value string
local function parse_xml_value(value)
    local lua_value = value:match("^%{(.*)%}$")

    if lua_value then
        -- return the literal in the brackets
        return lua_value
    else
        if value:match("\n") then
            return "\"" .. value .. "\""
        else
            -- This is just a string
            return "[[" .. value .. "]]"            
        end
    end
end

return parse_xml_value
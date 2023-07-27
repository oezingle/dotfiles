local unpack = require("src.agnostic.version.unpack")

---@param str string|number
---@param pattern string|number
---@param init number?
---@return fun(): (start: number, end: number, ...: string)|fun(): nil
local function string_find_iter(str, pattern, init)
    init = init or 1

    local last_end = init

    return function()
        local values = { str:find(pattern, last_end) }

        if #values == 0 then
            return nil
        end

        last_end = values[2]

        return unpack(values)
    end
end

--- Return a string that has been escaped, so it can
--- be used in String search functions as a literal
--- https://stackoverflow.com/questions/9790688/escaping-strings-for-gsub
---@param str string
---@return string
local function escape_string(str)
    local rep = str:gsub("([^%w])", "%%%1")

    return rep
end

---@param xml_line string
---@param pattern string
---@param callback fun(str: string)
local function for_prop_and_values(xml_line, pattern, callback)
    for start, finish, str in string_find_iter(xml_line, pattern) do
        ---@type unknown, string?
        local _, err = nil, ""

        -- find the next ending bracket until valid lua.
        -- this is a cheat but also not too slow so eh
        repeat
            local value = str:match("%{(.*)%}")

            _, err = load("return " .. value)

            if err then
                finish = xml_line:find("%}", finish + 1)

                if not finish then
                    error(string.format("Escaping bracket not found: %q", xml_line))
                end

                str = xml_line:sub(start, finish)
            end

            callback(str)
        until not err
    end
end

--- Allow nice features in XML like string auto-escaping and quoteless literal values
---@param xml string
---@return string
local function xml_gsub(xml)
    local c = xml
        -- match all element creation tags
        ---@param xml_line string
        :gsub("(<[^/%s].-/?>)", function(xml_line)
            --[[
            for start, finish, str in string_find_iter(xml_line, "([^=%s]+%s-=%s-%{.-%})") do
                ---@type unknown, string?
                local _, err = nil, ""

                -- find the next ending bracket until valid lua.
                -- this is a cheat but also not too slow so eh
                repeat
                    local value = str:match("%{(.*)%}")

                    _, err = load("return " .. value)

                    if err then
                        finish = xml_line:find("%}", finish + 1)

                        if not finish then
                            error(string.format("Escaping bracket not found: %q", xml_line))
                        end

                        str = xml_line:sub(start, finish)
                    end
                until not err

                local prop, value = str:match("([^=%s]+)%s-=%s-%{(.*)%}")

                xml_line = xml_line:gsub(escape_string(str), string.format("%s=\"{%s}\"", prop, value))
            end
            ]]

            --[[
            for start, finish, str in string_find_iter(xml_line, "([^=%s]+%s-=%s-[\"']%{.-%}[\"'])") do
                ---@type unknown, string?
                local _, err = nil, ""

                -- find the next ending bracket until valid lua.
                -- this is a cheat but also not too slow so eh
                repeat
                    local value = str:match("%{(.*)%}")

                    _, err = load("return " .. value)

                    if err then
                        finish = xml_line:find("%}", finish + 1)

                        if not finish then
                            error(string.format("Escaping bracket not found: %q", xml_line))
                        end

                        str = xml_line:sub(start, finish)
                    end
                until not err

                local prop, value = str:match("([^=%s]+)%s-=%s-[\"']%{(.*)%}[\"']")

                --- Auto-escape quotes
                value = value:gsub("\"", "\\\"")

                xml_line = xml_line:gsub(escape_string(str), string.format("%s=\"{%s}\"", prop, value))
            end
            ]]

            for_prop_and_values(xml_line, "([^=%s]+%s-=%s-%{.-%})", function(str)
                local prop, value = str:match("([^=%s]+)%s-=%s-%{(.*)%}")

                xml_line = xml_line:gsub(escape_string(str), string.format("%s=\"{%s}\"", prop, value))
            end)

            for_prop_and_values(xml_line, "([^=%s]+%s-=%s-[\"']%{.-%}[\"'])", function(str)
                local prop, value = str:match("([^=%s]+)%s-=%s-[\"']%{(.*)%}[\"']")

                --- Auto-escape quotes
                value = value:gsub("\"", "\\\"")

                xml_line = xml_line:gsub(escape_string(str), string.format("%s=\"{%s}\"", prop, value))
            end)

            return xml_line
        end)

    return c
end

return xml_gsub


local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "src.util.get_config.type_checker.generate"
local generate = require(folder_of_this_file .. "generate")

---@module "src.util.get_config.type_checker.primitives"
local primitives = require(folder_of_this_file .. "primitives")

---@param string string
---@return string
local function trim(string)
    while string:sub(1, 1):match("%s") do
        string = string:sub(2)
    end

    while string:sub( -1):match("%s") do
        string = string:sub(1, -2)
    end

    return string
end


--- Split a string, ignoring matches in any of the following: <> () {}
---@param string string the string to split
---@param matcher fun(char: string): boolean a function that takes the current character and determines if the line should split
---@return string[] substrings
local function bracket_split(string, matcher)
    local substring = ""

    local strings = {}

    local bracket_opposites = {
        ["{"] = "}",
        ["}"] = "{",
        ["<"] = ">",
        [">"] = "<",
        ["("] = ")",
        [")"] = "("
    }

    local brackets = ""

    for char in string:gmatch(".") do
        if #brackets == 0 and matcher(char) then
            table.insert(strings, substring)

            substring = ""
        else
            if bracket_opposites[char] then
                if brackets:sub( -1) == bracket_opposites[char] then
                    brackets = brackets:sub(1, -2)
                else
                    brackets = brackets .. char
                end
            end

            substring = substring .. char
        end
    end

    table.insert(strings, substring)

    return strings
end

--- An iterator to split a string by a pattern
---@param string string the string to search
---@param pattern string the pattern
---@return fun(): string iterator
local function bracket_split_iter(string, pattern)
    local strings = bracket_split(string, function(char)
        return char:match(pattern)
    end)

    local i = 1
    return function()
        local substring = strings[i]

        i = i + 1

        return substring
    end
end

---@param type_string string a type string, ie string|number, table<string, boolean>, etc
---@return Type
local function parse_type_string(type_string)
    type_string = type_string:gsub("%?", "|nil")

    local subtypes = {}

    -- Split up unions with bracket awareness
    do
        local subtype = ""

        local bracket_opposites = {
            ["{"] = "}",
            ["}"] = "{",
            ["<"] = ">",
            [">"] = "<",
            ["("] = ")",
            [")"] = "("
        }

        local brackets = ""

        for char in type_string:gmatch(".") do
            if char == "|" and #brackets == 0 then
                table.insert(subtypes, subtype)

                subtype = ""
            else
                if bracket_opposites[char] then
                    if brackets:sub( -1) == bracket_opposites[char] then
                        brackets = brackets:sub(1, -2)
                    else
                        brackets = brackets .. char
                    end
                end

                subtype = subtype .. char
            end
        end

        table.insert(subtypes, subtype)
    end

    if #subtypes > 1 then
        local types = {}

        for _, subtype in ipairs(subtypes) do
            local parsed_w = parse_type_string(subtype)

            if parsed_w then
                table.insert(types, parsed_w)
            else
                print("Type string " .. subtype .. " resulted in no known type")
            end
        end

        return generate.union(types)
    else
        -- This boy is a primitive
        if primitives[type_string] then
            return type_string
        end

        -- TODO non-string (ie number) literals
        -- Literal
        do
            local literal = string.match(type_string, "^\"([^\"]*)\"$")

            if literal then
                return generate.literal(literal)
            end
        end

        -- Reference
        if string.match(type_string, "^[%a%d_]+$") then
            return generate.reference(type_string)
        end

        -- (complex) Table
        do
            local type1, type2 = string.match(type_string, "^table<([^,]+),%s*([^>]+)>")

            if type1 and type2 then
                return generate.table(
                    parse_type_string(type1),
                    parse_type_string(type2)
                )
            end
        end

        -- Array
        do
            local arr = string.match(type_string, "^(.+)%[%]$")

            if arr then
                -- parse subtype
                return generate.array(
                    parse_type_string(arr)
                )
            end
        end

        -- Dict
        do
            local dict = string.match(type_string, "^{%s*(.*)%s*}$")

            if dict then
                local types = {}

                for slice in bracket_split_iter(dict, ",") do
                    slice = trim(slice)

                    local key, value = string.match(slice, "^([%a%d_%[%]]+):%s*(.*)$")

                    local keytype = nil

                    if key:sub(1, 1) == "[" then
                        keytype = parse_type_string(key:sub(2, -2))
                    else
                        keytype = generate.literal(key)
                    end

                    table.insert(types, {
                        key = keytype,
                        value = parse_type_string(trim(value))
                    })
                end

                return generate.dict(types)
            end
        end
    end

    print("Type string '" .. type_string .. "' resulted in no known type")
end

--- Parse lua comment annotations
--- 
--- See https://github.com/LuaLS/lua-language-server/wiki/Annotations#class
---@param file string a lua file as a string (NOT its path) to parse the annotations of
---@return table<string, Type>
local function parse_file_string(file)
    local types = {}

    local class = {
        name = nil,
        fields = {}
    }

    for w in string.gmatch(
    -- Add a secret tag at the end so if the last meta tag is a class it gets flushed
    -- TODO a better method than that
        file .. "\n---@finish",
        "---@([^\n]+)"
    ) do
        local args = {}

        do
            local arg = ""

            local bracket_opposites = {
                ["{"] = "}",
                ["}"] = "{",
                ["<"] = ">",
                [">"] = "<",
                ["("] = ")",
                [")"] = "("
            }

            local brackets = ""

            local last_char = ""

            for char in w:gmatch(".") do
                if char:match("%s") and #brackets == 0 and last_char ~= "|" then
                    table.insert(args, arg)

                    arg = ""
                else
                    if bracket_opposites[char] then
                        if brackets:sub( -1) == bracket_opposites[char] then
                            brackets = brackets:sub(1, -2)
                        else
                            brackets = brackets .. char
                        end
                    end

                    arg = arg .. char
                end

                last_char = char
            end

            table.insert(args, arg)
        end

        if args[1] == "field" then
            local arg_offset = 0

            if args[2] == "private" or args[2] == "protected" or args[2] == "public" or args[2] == "package" then
                arg_offset = 1
            end

            class.fields[args[2 + arg_offset]] = parse_type_string(args[3 + arg_offset])
        else
            if class.name then
                types[class.name] = generate.class(class.fields)

                class.name = nil
                class.fields = {}
            end

            if args[1] == "class" then
                class.name = args[2]
            elseif args[1] == "alias" then
                local name = args[2]
                local parsed_type = parse_type_string(args[3])

                types[name] = parsed_type
            end
        end
    end

    return types
end

local parse = {
    file_string = parse_file_string,
    type_string = parse_type_string
}

return parse
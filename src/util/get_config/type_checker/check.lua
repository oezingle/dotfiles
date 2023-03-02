
local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "src.util.get_config.type_checker.primitives"
local primitives = require(folder_of_this_file .. "primitives")

--- Rebuilding the lua extension's type checker in lua
---@param desired_type Type
---@param to_check any
---@param type_table table<string, Type>?
---@return boolean match, string? error whether or not the types match, and if not, the associated error message
local function check_type(desired_type, to_check, type_table)
    if primitives[desired_type] then
        local found_type = type(to_check)

        if desired_type == found_type then
            return true
        else
            return false, string.format("Expected %s, found %s", tostring(desired_type), tostring(found_type))
        end
    end

    assert(desired_type)

    if desired_type.type == "table" then
        if type(to_check) ~= "table" then
            return false, "Expected table, found " .. type(to_check)
        end

        local keytype = desired_type.key
        local valuetype = desired_type.value

        for key, value in pairs(to_check) do
            local success, err = check_type(keytype, key, type_table)

            if not success then
                return false, string.format("In key %s:\n%s", tostring(key), err)
            end

            local success, err = check_type(valuetype, value, type_table)

            if not success then
                return false, string.format("In value %s:\n%s", tostring(value), err)
            end
        end

        return true
    elseif desired_type.type == "union" then
        for _, subtype in ipairs(desired_type.types) do
            if check_type(subtype, to_check, type_table) then
                return true
            end
        end

        return false, "No union type match"
    elseif desired_type.type == "literal" then
        local word = desired_type.word

        if to_check == word then
            return true
        else
            return false, string.format("Expected literal %s, found literal %s", tostring(word), tostring(to_check))
        end
    elseif desired_type.type == "alias" then
        local success, err = check_type(desired_type.subtype, to_check, type_table)

        return success, not success and string.format("In alias:\n%s", err) or nil
    elseif desired_type.type == "class" then
        if type(to_check) ~= "table" then
            return false, "Expected table, found " .. type(to_check)
        end

        -- TODO inheritance

        local success, err = check_type(desired_type.dict, to_check, type_table)

        return success, not success and string.format("In class field:\n%s", err) or nil
    elseif desired_type.type == "dict" then
        if type(to_check) ~= "table" then
            return false, "Expected table, found " .. type(to_check)
        end

        for _, subtype in ipairs(desired_type.types) do
            local keytype, valuetype = subtype.key, subtype.value

            -- assert all literals in the dictionary are present
            if type(keytype) == "table" and keytype.type == "literal" then
                local literal = keytype.word

                if not to_check[literal] then
                    -- only allow this if nil passes for this value
                    if not check_type(valuetype, nil) then
                        return false, string.format("Key of literal '%s' not found", literal) 
                    end
                end
            end

            for key, value in pairs(to_check) do
                if check_type(keytype, key, type_table) then
                    -- TODO consider that there may be another keytype-valuetype
                    -- TODO pair where value does satisfy this requirement,
                    -- TODO leaving a valid type
                    local success, err = check_type(valuetype, value, type_table)

                    if not success then
                        return false, string.format("In key %s:\n%s", tostring(key), err)
                    end
                end
            end
        end

        return true
    elseif desired_type.type == "reference" then
        if not type_table then
            return false, "Referenced type cannot be checked: no type_table argument provided"
        end

        ---@type string
        local ref_name = desired_type.ref

        local ref = type_table[ref_name]

        if not ref then
            return false, string.format("Referenced type '%s' not found in provided type table", ref_name)
        end

        local success, err = check_type(ref, to_check, type_table)

        return success, not success and string.format("In referenced type '%s':\n%s", ref_name, err) or nil
    end

    return false
end

return check_type
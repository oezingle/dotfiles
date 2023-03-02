
---@param keytype Type
---@param valuetype Type
---@return ComplexType
local function generate_table(keytype, valuetype)
    return {
        type = "table",
        key = keytype,
        value = valuetype
    }
end

---@param valuetype Type
---@return ComplexType
local function generate_array(valuetype)
    return generate_table("number", valuetype)
end

---@param types Type[]
---@return ComplexType
local function generate_union(types)
    return {
        type = "union",
        types = types
    }
end

---@param word Primitive
---@return ComplexType
local function generate_literal(word)
    return {
        type = "literal",
        word = word
    }
end

--- TODO almost-global alias table?
---@param type Type
---@return ComplexType
local function generate_alias(type)
    return {
        type = "alias",
        subtype = type
    }
end

--- Generate a dictionary
---@param types { key: Type, value: Type }[]
local function generate_dict(types)
    return {
        type = "dict",
        types = types
    }
end

--- A class type
---@param fields table<string, Type>
---@param inherits string?
---@return ComplexType
local function generate_class(fields, inherits)
    local dict_input = {}

    for key, value in pairs(fields) do
        table.insert(dict_input, {
            key = generate_literal(key),
            value = value
        })
    end

    return {
        type = "class",
        dict = generate_dict(dict_input),
        inherits = inherits
    }
end

--- Generate a reference to another type. Requires a type table
---@param ref_name string
local function generate_refernce(ref_name)
    return {
        type = "reference",
        ref = ref_name
    }
end

local generate = {
    table     = generate_table,
    array     = generate_array,
    union     = generate_union,
    literal   = generate_literal,
    alias     = generate_alias,
    dict      = generate_dict,
    class     = generate_class,
    reference = generate_refernce
}

return generate
-- https://stackoverflow.com/questions/20325332/how-to-check-if-two-tablesobjects-have-the-same-value-in-lua

local assert = require("luassert")

---@param a any
---@param b any
local function assert_deep_equals(a, b)
    local type_a = type(a)
    local type_b = type(b)
    
    assert.equal(type_a, type_b)
    assert.table(a)

    local keys = {}

    for k, v_a in pairs(a) do
        local v_b = b[k]

        assert.Not.Nil(v_b)

        if type(v_b) == "table" then
            assert_deep_equals(v_a, v_b)
        else
            assert.equal(v_a, v_b)
        end

        keys[k] = true
    end

    for k in pairs(b) do
        assert.Not.Nil(keys[k])
    end

    --[[
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or deep_equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
    ]]
end

return assert_deep_equals
-- functions exposed to users

---@alias TestingFunction fun(): string, boolean|nil, any

--- Check if the script is running in awesome
---@return boolean has_awesome whether or not the script is running in AwesomeWM
local function has_awesome()
    return type(awesome) ~= "nil" and next(awesome) ~= nil
end

--- Create a test callback wrapped around a function
---@param callback function a function that could throw an error
---@param name string? the name of the test
---@return TestingFunction test for internal use
local function test(callback, name)
    name = name or "[Unnamed test]"

    return function()
        local success, ret = xpcall(function()
            callback()
        end, function(err)
            print(debug.traceback(err))

            -- passes to ret
            return err
        end)

        return name, success, ret
    end
end

--- Create a test if in AwesomeWM context
---@param callback function a function that could throw an error
---@param name string? the test's name
---@return TestingFunction test for internal use
local function awesome_only_test(callback, name)
    name = name or "[Unnamed test]"

    if has_awesome() then
        return test(callback, name)
    else
        return function()
            return name, nil, "This test requires AwesomeWM"
        end
    end
end

--- Assert non-false / non-null value
---@param boolean any the value to check for truthiness
---@param name string? the test's name
---@return TestingFunction test for internal use
local function test_assert(boolean, name)
    return test(function()
        return assert(boolean)
    end, name)
end

--- A test that hasn't been implemented
---@param name string? the test's name
local function test_not_implemented(name)
    return function()
        return name, nil, "Not yet implemented"
    end
end

return {
    test              = test,
    awesome_only_test = awesome_only_test,
    assert            = test_assert,
    not_implemented   = test_not_implemented,
    has_awesome       = has_awesome,
}

-- functions exposed to users

--- Check if the script is running in awesome
---@return boolean has_awesome whether or not the script is running in AwesomeWM
local function has_awesome()
    return type(awesome) ~= "nil" and next(awesome) ~= nil
end

--- Create a test callback wrapped around a function that might throw an error
---@param callback function
---@param name string?
---@return fun(): string, boolean, any
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
---@param callback function
---@param name string?
---@return function
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

--- Create a test callback wrapped around a function that returns a boolean
---@param boolean boolean
---@param name string?
---@return function
local function test_assert(boolean, name)
    return test(function()
        return assert(boolean)
    end, name)
end

return {
    test              = test,
    awesome_only_test = awesome_only_test,
    assert            = test_assert,
    has_awesome       = has_awesome
}

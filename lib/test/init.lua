local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "lib.test.cli"
local cli = require(folder_of_this_file .. "test.cli")
---@module "lib.test.testing_functions"
local library = require(folder_of_this_file .. "test.testing_functions")
---@module "lib.test.profile"
local profile = require(folder_of_this_file .. "test.profile")

local pack = table.pack or function(...)
        local tmp = { ... }
        tmp.n = select("#", ...)

        return tmp
    end

---@class TestResult
---@field success boolean|nil
---@field name string
---@field ret string

--- Recurse through test results
---@param results TestResult[]
---@param depth number?
local function print_test_results(results, depth)
    depth = depth or 0

    for _, result in ipairs(results) do
        if result[1] then
            print_test_results(result, depth + 1)
        else
            local ret = ""

            if not result.success then
                ret = " - " .. cli.success.get_color(result.success)
                    .. result.ret .. cli.colors.RESET
            end

            print(
                string.rep("     ", depth + 2) .. cli.success.get(result.success)
                .. " " .. result.name .. ret
            )
        end
    end
end

--- Count total tests tested
---@param results TestResult[]
---@param needs_pass boolean? if the test needs to pass to count
local function count_tests(results, needs_pass)
    needs_pass = needs_pass or false

    local count = 0

    for _, result in ipairs(results) do
        if result[1] then
            count = count + count_tests(result, needs_pass)
        else
            if not needs_pass or result.success then
                count = count + 1
            end
        end
    end

    return count
end

--- Check the overall success of a set of results
---@param results TestResult[]
---@return boolean|nil
local function overall_success(results)
    ---@type boolean|nil
    local success = true

    for _, result in ipairs(results) do
        if result[1] then
            local sub_success = overall_success(result)

            if sub_success == false then
                success = false
            elseif sub_success == nil and success then
                success = nil
            end
        else
            if result.success == false then
                success = false
            elseif result.success == nil and success then
                success = nil
            end
        end
    end

    return success
end

--- Group similar tests, indenting them in the printed results
---@param ... TestingFunction|TestResult
---@return (TestResult|TestResult[])[] results
local function test_collection(...)
    ---@type (function|TestResult[])[]
    local tests = pack(...)

    local tests_passed = 0

    -- TODO re-incorporate this
    ---@type boolean|nil
    -- local all_passed = true

    ---@type (TestResult|TestResult[])[]
    local results = {}

    for _, test in ipairs(tests) do
        if type(test) == "function" then
            local name, success, ret = test()

            --[[
            if success == nil then
                all_passed = nil
            elseif success == false then
                all_passed = false
            else
                tests_passed = tests_passed + 1
            end
            ]]
            table.insert(results, {
                success = success,
                name = name,
                ret = (ret ~= nil and tostring(ret) or "")
            })
        else
            table.insert(results, test)
        end
    end

    return results
end

--- Run a test suite given a name and test.* testing functions
---@param name string
---@param ... function
local function suite(name, ...)
    local results = test_collection(...)

    local total_tests = count_tests(results)
    local tests_passed = count_tests(results, true)

    print(
        "     " .. cli.success.get(overall_success(results)) ..
        " Tests for " .. name .. " - " ..
        tostring(total_tests) .. " tests"
    )

    print_test_results(results, 0)

    print(
        "     " .. cli.to_percent(tests_passed, total_tests) .. " tests passed"
    )

    print()

    return results
end

--- Only call callback if running in AwesomeWM
---@param name string
---@param callback any
local function require_awesome(name, callback)
    if library.has_awesome() then
        callback(name)
    else
        print("     " ..
        cli.success.get_color(nil) ..
        cli.success.get_character(nil) .. " Tests for " ..
        name .. " require AwesomeWM" .. cli.colors.RESET)
        print()
    end
end

return {
    suite             = suite,
    require_awesome   = require_awesome,
    collection        = test_collection,
    --
    test              = library.test,
    awesome_only_test = library.awesome_only_test,
    assert            = library.assert,
    not_implemented   = library.not_implemented,
    has_awesome       = library.has_awesome,
    --
    profile           = profile
}

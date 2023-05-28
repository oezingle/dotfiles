
local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "test.cli"
local cli = require(folder_of_this_file .. "cli")
---@module "test.testing_functions"
local library = require(folder_of_this_file .. "testing_functions")
---@module "test.profile"
local profile = require(folder_of_this_file .. "profile")

local pack = table.pack or function(...)
    local tmp = { ... }
    tmp.n = select("#", ...)

    return tmp
end

local global_state = {
    all_passed = true,
}

function global_state.reset()
    print("resetting")

    global_state.all_passed = true
end

function global_state.fail()
    global_state.all_passed = false
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
---@return { passed: number, total: number, run: number }
local function count_tests(results)
    local passed = 0
    local total = 0
    local run = 0

    for _, result in ipairs(results) do
        if result[1] then
            local subcount = count_tests(result)

            passed = passed + subcount.passed
            total = total + subcount.total
            run = run + subcount.run
        else
            if result.success == true then
                passed = passed + 1
            end

            if result.success ~= nil then
                run = run + 1
            end

            total = total + 1
        end
    end

    return {
        passed = passed,
        total = total,
        run = run
    }
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

    -- local tests_passed = 0

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

    local test_count = count_tests(results)

    print(
        "     " .. cli.success.get(overall_success(results)) ..
        " Tests for " .. name .. " - " ..
        tostring(test_count.passed) .. " tests"
    )

    print_test_results(results, 0)

    print(
        "     " .. cli.to_percent(test_count.passed, test_count.run) .. " tests passed"
    )

    print()

    if test_count.passed ~= test_count.run then
        global_state.fail()
    end

    return { results = results, count = test_count, name = name }
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
    profile           = profile,

    global_state      = global_state
}

local spawn = require("src.agnostic.spawn")
local print = require("src.agnostic.print")

-- TODO await Promises returned by test functions - Promise.all()

-- For speed
local DISABLE_TESTABLE = true

if DISABLE_TESTABLE then
    local bypass = function (...)
        return ...
    end

    return setmetatable({
        testable          = bypass,
        has_awesome       = bypass,
        on_signal         = bypass,
        test_all          = bypass,
        test              = bypass,
        awesome_only_test = bypass,
        assert            = bypass
    }, {
        __call = function(_, ...)
            return bypass(...)
        end
    })
    
end

---@class Array<T>: { [integer]: T }

---@alias SingleOrArray<T> T|Array<T>

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
    return function()
        local success, ret = xpcall(function()
            callback()
        end, function (err)
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
    if has_awesome() then
        return test(callback, name)
    else
        return function()
            return name, nil, "This tests requires AwesomeWM"
        end
    end
end

--- Create a test callback wrapped around a function that returns a boolean
---@param callback fun(): boolean
---@param name string?
---@return function
local function test_assert(callback, name)
    return test(function()
        assert(callback())
    end, name)
end

-- TODO stack traces

local ALLOW_FUNCTION_TESTS = true

--- Make it clear that this module can be tested
---@generic T : table
---@param ret `T`
---@param tests SingleOrArray<fun(): boolean, string?> the function called when testing
---@return T ret the module's return but with a testing callback
local function testable(ret, tests)
    if type(ret) == "function" then
        if ALLOW_FUNCTION_TESTS then
            ret = { fn = ret }

            setmetatable(ret, {
                __call = function(self, ...)
                    return self.fn(...)
                end
            })
        else
            print("ALLOW_FUNCTION_TESTS flag disabled, so tests for this module are skipped")

            return ret
        end
    end

    if type(ret) ~= "table" then
        print("Tests can't be applied to non-table return values!")
        assert(false, "Tests can't be applied to non-table return values!")
    end

    if type(tests) == "function" or
        type(tests) == "table" then
        ret.__test = tests
    else
        error("Unexpected type of " .. type(tests))
    end

    return ret
end

-- Allow this module to be tested by the awesome::dotfiles::vhs::test signal
---@generic T : table
---@param ret `T`
---@param test_callback fun(): boolean|boolean[]|table<string, boolean> the function called when testing
---@return T ret the module's return but with a testing callback
local function on_signal(ret, test_callback)
    if not has_awesome() then
        error("testable.on_signal requires AwesomeWM")
    end

    awesome.connect_signal("awesome::dotfiles::vhs::test", test_callback)

    return ret
end

--- Split a string into an array by newlines
---@param s string the string to split up
---@return string[] lines
local function split_newlines(s)
    local lines = {}
    for sub in string.gmatch(s, "[^\r\n]+") do
        table.insert(lines, sub)
    end

    return lines
end

--- Convert a filesystem path to a lua module name
---@param path string
---@return string
local function as_module(path)
    local new_path = path
        -- remove ./
        :gsub("%./", "")
        -- remove .lua
        :gsub(".lua", "")
        -- / -> .
        :gsub("/", ".")

    return new_path
end

---@enum TextColors
local text_colors = {
    RED    = "\27[31m",
    GREEN  = "\27[32m",
    YELLOW = "\27[33m",
    RESET  = "\27[0m",
}

---@param success boolean|nil
---@return string
local function success_get_color(success)
    if success == nil then
        return text_colors.YELLOW
    elseif success then
        return text_colors.GREEN
    else
        return text_colors.RED
    end
end

---@param success boolean|nil
---@return string
local function success_get_character(success)
    if success == nil then
        return "?"
    elseif success then
        return "✔"
    else
        return "✘"
    end
end

-- TODO creates new tags and another top/left bar under awesomewm
--- Test all lua files in the dotfile directory
---@param args { LOADING_IS_A_TEST: boolean?, AWESOME_NOT_REQUIRED: boolean? }|nil
local function test_all(args)
    args = args or {}

    args.LOADING_IS_A_TEST = args.LOADING_IS_A_TEST or false
    args.AWESOME_NOT_REQUIRED = args.AWESOME_NOT_REQUIRED or false

    local tests_count = 0
    local tests_passed = 0

    local skip_modules = {
        "rc",
        "test",
        "util.testable"
    }

    -- spider around and shit
    spawn("cd ~/.config/awesome; find . -name '*.lua'", function(res)
        print("Running Module Tests:")

        local lines = split_newlines(res)

        for _, line in ipairs(lines) do
            local module_name = as_module(line)

            local should_skip = false

            for _, skip_module in ipairs(skip_modules) do
                if module_name == skip_module then
                    should_skip = true
                end
            end

            if module_name and not should_skip then
                local success, module = pcall(function()
                    return require(module_name)
                end)

                if success then
                    if type(module) == "table" and type(module.__test) ~= "nil" then
                        -- module.__test can be a function or Array<function>

                        local tests = module.__test

                        local module_test_count = 0
                        ---@type boolean|nil
                        local module_all_tests_passed = true
                        local module_tests = {}

                        if type(tests) == "function" then
                            tests = { tests }
                        end

                        if type(tests) == "table" then
                            for _, test in ipairs(tests) do
                                module_test_count = module_test_count + 1

                                tests_count = tests_count + 1

                                local name, success, ret = test()

                                if success == nil and module_all_tests_passed ~= false then
                                    module_all_tests_passed = nil
                                elseif success == false then
                                    module_all_tests_passed = false
                                    -- might be nil
                                elseif success then
                                    tests_passed = tests_passed + 1
                                end

                                table.insert(module_tests, {
                                    success = success,
                                    name    = name or "[Unnamed test]",
                                    ret     = (ret ~= nil and tostring(ret) or "")
                                })
                            end
                        else
                            print(module_name .. ".__test has an unexpected type of " .. type(tests))
                        end

                        print(
                            success_get_color(module_all_tests_passed) .. "     " ..
                            success_get_character(module_all_tests_passed) ..
                            " " .. text_colors.RESET .. module_name ..
                            " - " .. tostring(module_test_count) .. " tests"
                        )

                        for _, test_result in ipairs(module_tests) do
                            print(
                                success_get_color(test_result.success) .. "         " ..
                                success_get_character(test_result.success) ..
                                " " .. text_colors.RESET .. test_result.name ..
                                (
                                test_result.success and "" or
                                    (" - " .. success_get_color(test_result.success) .. test_result.ret .. text_colors.RESET))
                            )
                        end
                    elseif args.LOADING_IS_A_TEST then
                        tests_count = tests_count + 1
                        tests_passed = tests_passed + 1

                        print(text_colors.GREEN .. "     ✔ " .. text_colors.RESET .. module_name .. " loads")
                    end
                elseif has_awesome() or args.AWESOME_NOT_REQUIRED then
                    tests_count = tests_count + 1

                    print(text_colors.RED .. "     ✘ " .. text_colors.RESET .. module_name .. " does not load")
                end
            end
        end

        local percent = math.floor((tests_passed / tests_count) * 100)

        print(tostring(percent) .. "% of tests passed")

        -- print the stipulations
        if args.AWESOME_NOT_REQUIRED and not has_awesome() then
            print(" - Assumed that modules that do not load would load under awesome")
        end
        if args.LOADING_IS_A_TEST then
            print(" - Modules that load and do not define tests are considered passed tests")
        end
    end)
end

-- connect global signal
if has_awesome() then
    awesome.connect_signal("awesome::dotfiles::vhs::test", function()
        test_all {
            -- LOADING_IS_A_TEST = true
        }
    end)
elseif arg then
    if not pcall(debug.getlocal, 4, 1) then
        test_all {
            -- LOADING_IS_A_TEST = true
        }
    end
end

return setmetatable({
    testable          = testable,
    has_awesome       = has_awesome,
    on_signal         = on_signal,
    test_all          = test_all,
    test              = test,
    awesome_only_test = awesome_only_test,
    assert            = test_assert
}, {
    __call = function(_, ...)
        return testable(...)
    end
})

local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "lib.test.cli"
local cli = require(folder_of_this_file .. "test.cli")
---@module "lib.test.testing_functions"
local library = require(folder_of_this_file .. "test.testing_functions")

local pack = table.pack or function(...)
    local tmp = { ... }
    tmp.n = select("#", ...)

    return tmp
end

--- Run a test suite given a name and test.* testing functions
---@param name string
---@param ... function
local function suite(name, ...)
    ---@type function[]
    local tests = pack(...)

    local tests_passed = 0

    ---@type boolean|nil
    local all_passed = true

    local results = {}

    for _, test in ipairs(tests) do
        local name, success, ret = test()

        if success == nil then
            all_passed = nil
        elseif success == false then
            all_passed = false
        else
            tests_passed = tests_passed + 1
        end

        table.insert(results, {
            success = success,
            name = name,
            ret = (ret ~= nil and tostring(ret) or "")
        })
    end

    print(
        "     " .. cli.success.get(all_passed) .. 
        " Tests for " .. name .. " - " .. 
        tostring(#tests) .. " tests"
    )

    for _, result in ipairs(results) do
        local ret = ""

        if not result.success then
            ret = " - " .. cli.success.get_color(result.success)
            .. result.ret .. cli.colors.RESET
        end

        print(
            "         " .. cli.success.get(result.success) 
            .. " " .. result.name .. ret
        )
    end

    print(
        "     " .. cli.to_percent(tests_passed, #tests) .. " tests passed"
    )

    print()
end

--- Only call callback if running in AwesomeWM
---@param name string
---@param callback any
local function require_awesome(name, callback)
    if library.has_awesome() then
        callback(name)
    else
        print("     " .. cli.success.get(nil) .. " Tests for " .. name .. " require AwesomeWM")
        print()
    end
end

return {
    suite = suite,
    require_awesome = require_awesome,

    test = library.test,
    awesome_only_test = library.awesome_only_test,
    assert = library.assert,
    has_awesome = library.has_awesome,
}

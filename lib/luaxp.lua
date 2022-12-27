
local luaxp = require("lib.luaxp.luaxp")

---@class LuaxpError
---@field type "compile"|"evaluation" the stage at which the error occured
---@field message string a description of the error
---@field location number? the character position of the error

---@alias LuaxpResult any

if false then
    luaxp = {
        --- Parse a string into an expression table
        ---@param string string the expression as a string
        ---@return table|nil expr, LuaxpError? err the expression table or nil and an error
        compile = function (string)
            return luaxp.compile(string)
        end,

        --- Run a parsed expression
        ---@param expr table
        ---@param context table? additional functions for the expression runtime, in key-value pairs
        ---@return LuaxpResult|nil result, LuaxpError? err the result of the expression or nil and an error
        run = function (expr, context)
            return luaxp.run(expr, context)
        end,

        --- Parse and run an expression string
        ---@param string string the expression as a string
        ---@param context table? additional functions for the expression runtime, in key-value pairs
        ---@return LuaxpResult|nil result, LuaxpError? err the result of the expression or nil and an error
        evaluate = function (string, context)
            return luaxp.evaluate(string, context)
        end,

        --- Check if the result of running an expression is Null. This is NOT nil!
        ---@param result LuaxpResult
        ---@return boolean
        isNull = function (result)
            return luaxp.isNull(result)
        end,

        --- Dump something to a string
        ---@param input any
        ---@return string
        dump = function (input)
            return luaxp.dump(input)
        end,

        ---@type string luaxp version
        _VERSION = luaxp._VERSION
    }
end

return luaxp
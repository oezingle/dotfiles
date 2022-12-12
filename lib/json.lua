
local json = require("lib.json.json")

if false then
    json = {
        --- Turn a lua table into a JSON serialized string
        ---@param table table
        ---@return string json
        encode = function (table) return "" end,

        --- Turn a JSON serialized string into a lua table
        ---@param str string
        ---@return table table
        decode = function (str) return {} end
    }
end

return json
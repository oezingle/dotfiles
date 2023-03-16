
local argparse = require("lib.argparse.src.argparse")

if false then
    ---@class ArgParse
    ---@field argument fun(self: ArgParse, name: string, description: string?, default: string?)
    ---@field option fun(self: ArgParse, flags: string, description: string?, default: string?)
    ---@field flags fun(self: ArgParse, flags: string, description: string?)
    ---@field parse fun(self: ArgParse)
    ---@operator call(string):ArgParse
    local argparse = {}
end

return argparse
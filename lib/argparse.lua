local argparse = require("lib.argparse.src.argparse")

if false then
    ---@class ArgParse.Option
    ---@field args fun(self: self, args: number | "?"): self set the number of arguments per option. ie parser:option("double"):args(2) -> <program> --double arg1 arg2
    ---@field target fun(self: self, target: string): self
    ---@field count fun(self: self, count: "*"|string|number): self set the count of this option possible
    ---@field choices fun(self: self, choies: string[]): self set the possible choices for that option
    ---@field argname fun(self: self, argname: string|string[]): self set the name of the argument in help messages
    ---@field hidden fun(self: self, hide: boolean): self set hidden in help

    ---@class ArgParse.Flag
    ---@field target fun(self: self, target: string): self
    ---@field count fun(self: self, count: "*"|string|number): self set the count of this option possible
    ---@field hidden fun(self: self, hide: boolean): self set hidden in help


    ---@class ArgParse.Argument
    ---@field count fun(self: self, count: "*"|string|number): self set the count of this option possible
    ---@field choices fun(self: self, choies: string[]): self set the possible choices for that option
    ---@field hidden fun(self: self, hide: boolean): self set hidden in help

    ---@class ArgParse
    ---@field argument fun(self: ArgParse, name: string, description: string?, default: string?): ArgParse.Argument
    ---@field option fun(self: ArgParse, flags: string, description: string?, default: string?): ArgParse.Option
    ---@field flag fun(self: ArgParse, flags: string, description: string?): ArgParse.Flag
    ---@field parse fun(self: ArgParse, arg?: table)
    ---@operator call(string):ArgParse
    argparse = {}
end

return argparse

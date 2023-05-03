local class = require("lib.30log")

---@class BadArgParse : LogBaseFunctions
---@field name string?
---@field description string?
---@field arguments { name: string, description: string, default: any }[]
---@field options { flags: string[], description: string }[]
---@field print function(...)
---@operator call:BadArgParse
local argparse = class("BadArgParse", {
    print = print
})

--[[
Usage: cli.lua [-p <path>] [-w <window>] [-a] [-h]

A dirty command line to test GTK/Canonical DBus menus

Options:
        -p <path>,        the menu items to navigate through, using periods as seperators. ie File.Open_Recent (default: )
   --path <path>
         -w <window>,    The X window id
   --window <window>
   -a, --activate        Activate the resulting menu item
   -h, --help            Show this help message and exit.
]]
function argparse:init(name, description)
    self:set_name(name)

    self:set_description(description)

    self.options = {}
    self.arguments = {}
end

---@param name string
function argparse:set_name(name)
    self.name = name

    return self
end

---@param description string
function argparse:set_description(description)
    self.description = description

    return self
end

---@param name string
---@param description string
---@param default any?
function argparse:add_argument(name, description, default)
    table.insert(self.arguments, {
        name        = name,
        description = description,
        default     = default
    })

    return self
end

function argparse:print_usage()
    local print = self.print

    local optline = {"[-h --help]"}

    for _, option in ipairs(self.options) do
        table.insert(
            optline,
            string.format("[%s]", table.concat(option.flags))
        )
    end

    -- TODO args and options
    print(string.format(
        "Usage: %s %s %s",
        self.name or "<program>",
        table.concat(optline, " "),
        ""
    ))

    print()

    if self.description then
        print(self.description, "\n")
    end

    if #self.arguments ~= 0 then
        print("Arguments:")

        for _, argument in ipairs(self.arguments) do
            print("", argument.name, "", argument.description)
        end

        print()
    end

    if #self.options ~= 0 then
        print("Options:")
        
        -- TODO not implemented

        print()
    end

    return self
end

--- Parse the provided args variable. If the function returns nil, the user has made an error.
---@param args string[]
---@return { flags: table<string, string|boolean>, arguments: string[], [string]: string|boolean }|nil
function argparse:parse(args)
    local print = self.print
    
    local res = {
        flags = {},
        arguments = {}
    }

    local minimum_arg_count = #self.arguments

    for i, arg in ipairs(self.arguments) do
        res.arguments[i] = arg.default

        if arg.default ~= nil then
            minimum_arg_count = minimum_arg_count - 1
        end
    end

    for i, arg in ipairs(args) do        
        if i > 0 then
            if arg:match("^[%-]+") then
                -- TODO unknown flags
                res.flags[arg:gsub("^[%-]+", "")] = true
            else
                res.arguments[i] = arg
            end
        end
    end

    if res.flags.h or res.flags.help then
        self:print_usage()

        return
    end

    if #args < minimum_arg_count then
        print("Too few arguments. Exiting")

        return
    end

    return res
end

return argparse

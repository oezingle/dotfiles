-- TODO file that turns arguments into called functions or loaded files what have you

-- every command should be a:
-- function, string, or table that contains a description etc and one of those two to activate
-- the function is passed args but global arg should also be set using getenv
-- a fake require should be used so that code chunks are dynamically reloaded

-- basically it is my goal that CLIs i have already written could just exist within the awesome shell

local get_commands = require("src.cli.get_commands")
local envhacks     = require("src.agnostic.version.envhacks")

local unpack = require("src.agnostic.version.unpack")

local string = string
local loadfile = loadfile
local type = type

--- Split a string into its non-empty strings
---@param s string
---@return string[] words
local function split_args(s)
    local words = {
        [-1] = "awesome"
    }

    local index = 0
    for word in s:gmatch("[^%s]+") do 
        words[index] = word

        index = index + 1
    end

    return words
end

---@param command string
local function interpret(command)
    local args = split_args(command)

    -- TODO a way to do ...

    local file = get_commands()[args[0]]

    if not file then
        print(string.format("%s: command not found", args[0]))

        return
    end

    local run_command = loadfile(file, nil, setmetatable({
        arg = args
    }, { __index = envhacks.getfenv(1) }))

    if not run_command then
        error("File doesn't load")
    end

    local res = run_command()

    if type(res) == "function" then
        res(unpack(args))
    end
end

return interpret

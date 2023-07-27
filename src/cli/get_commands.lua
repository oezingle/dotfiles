local fs = require("src.util.fs")
local pack = require("src.agnostic.version.pack")

---@type string[]
local args = pack(...)

-- https://stackoverflow.com/questions/6380820/get-containing-path-of-lua-file
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

---@return table<string, string>
local function get_commands()
    ---@type string
    local commands_folder

    if args then
        commands_folder = args[2]:gsub("/[%a_]+%.lua", "/commands")
    else
        -- fall back on this function because debug isn't supposed to be used
        commands_folder = script_path() .. "commands"
    end
    
    local commands_table = {}

    for _, file in ipairs(fs.list(commands_folder)) do
        local command = file:gsub("%.lua", "")

        local path = commands_folder .. "/" .. file

        commands_table[command] = path
    end

    return commands_table
end

local commands = get_commands()

return function()
    return commands
end

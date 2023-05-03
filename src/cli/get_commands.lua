local fs = require("src.util.fs")
local pack = require("src.agnostic.version.pack")

---@type string[]
local args = pack(...)

---@return table<string, string>
local function get_commands()
    local commands_folder = args[2]:gsub("/[%a_]+%.lua", "/commands")

    local commands_table = {}

    for _, file in ipairs(fs.list(commands_folder)) do
        local command = file:gsub("%.lua", "")

        local path = commands_folder .. "/" .. file

        commands_table[command] = path
    end

    return commands_table
end

local commands = get_commands()

return function ()
    return commands
end
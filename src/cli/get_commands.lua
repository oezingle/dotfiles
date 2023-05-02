local fs = require("src.util.fs")
local pack = require("src.agnostic.version.pack")

---@type string[]
local args = pack(...)

---@return table<string, string>
local function get_commands()
    local commands_folder = args[2]:gsub("/[%a_]+%.lua", "/commands")

    local commands_lua_path = args[1]:gsub("%.[%a_]+$", ".commands")

    local commands_table = {}

    for i, file in ipairs(fs.list(commands_folder)) do
        local command = file:gsub("%.lua", "")

        local luapath = commands_lua_path .. "." .. command

        commands_table[command] = luapath
    end

    return commands_table
end

local commands = get_commands()

return function ()
    return commands
end
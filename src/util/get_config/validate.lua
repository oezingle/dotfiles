
local fs           = require("src.util.fs")
local type_checker = require("src.util.get_config.type_checker")

local function validate_config()
    local config_file = fs.read(fs.directories.config .. "config.lua")

    if not config_file then
        error("config.lua missing")
    end

    local config = load(config_file, "config")()

    ---@type boolean, string?
    local success, err = type_checker():add_files(
            fs.directories.config .. "_types/config.lua",
            fs.directories.config .. "_types/color.lua",
            fs.directories.config .. "_types/direction.lua"
        ):check("DotfileConfiguration", config)

    return success, err
end

return validate_config

local fs           = require("src.util.fs")
local type_checker = require("src.util.get_config.type_checker")

---@param config DotfileConfiguration
local function validate_config(config)

    ---@type boolean, string?
    local success, err = type_checker():add_files(
            fs.directories.config .. "_types/config.lua",
            fs.directories.config .. "_types/color.lua",
            fs.directories.config .. "_types/direction.lua"
        ):check("DotfileConfiguration", config)

    return success, err
end

return validate_config
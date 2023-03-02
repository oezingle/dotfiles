-- switching the configuration file to JSON
-- so it can be operated on with a visual editor

local config = require("config")
local fs = require("src.util.fs")

local function jsonify_config()
    if type(config.wallpaper) == "table" then
        local time = config.wallpaper.time

        local list = {}

        for k, v in pairs(config.wallpaper) do
            if k ~= "time" then
                list[k] = v
            end
        end

        config.wallpaper = {
            list = list,
            time = time
        }
    end

    fs.json.dump("config.json", config)
end

return jsonify_config

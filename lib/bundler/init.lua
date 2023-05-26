
local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module 'bundler.path'
local pathlib = require(folder_of_this_file)

local argparse = require("lib.argparse")

local json = require("lib.json")

warn = function (...)
    print("WARN", ...)
end

---@class Bundler.Config
---@field out_dir string
---@field in_dir string
---@field main string
local default_config = {
    out_dir = "./build",
    
    in_dir = "./src",

    main = "./init.lua",

    -- treeshake = true
}

---@param config_or_path Bundler.Config|string
---@return Bundler.Config config
local function parse_config (config_or_path)
    ---@type Bundler.Config
    local config
    
    if type(config_or_path) == "string" then
        local file = io.open(config_or_path, "r")

        assert(file, "Config file specified does not exist")
        
        assert(file:read(0), "Cannot read config file")

        local read_config = json.decode(file:read("a"))

        config = setmetatable(read_config, { __index = default_config })
    elseif type(config_or_path) == "table" then
        config = setmetatable(config_or_path, { __index = default_config })
    else 
        error(string.format("Unknown configuration type %s", type(config_or_path)))
    end

    -- Warn about keys in config that don't exist in default
    for k, v in pairs(config) do
        if not default_config[k] then
            warn(string.format("Key '%s' does not exist in default configuration object. Removing it."))

            config[k] = nil
        end
    end

    return config
end

local function main()
    
end

main()
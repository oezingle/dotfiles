warn = function(...)
    print("WARN", ...)
end

---@module 'bundler.path'
local pathlib = require("lib.bundler.path")

---@module 'bundler.Bundler'
local Bundler = require("lib.bundler.Bundler")

local argparse = require("lib.argparse")

local json = require("lib.json")

---@class Bundler.Config
---@field out_dir string
---@field in_dir string
---@field exports {  in_file: string, out_file: string }[] the files to shim for public use
---@field strip { comments: boolean, annotations: boolean, empty: boolean } strip out comments, annotation comments, or empty lines
---@field public_dir string|nil an optional directory for LICENSE, README, etc, to be copied to <config.out_dir>/ 
local default_config = {
    out_dir = "./build",

    in_dir = "./src",

    exports = {},

    strip = {
        comments = false,
        annotations = false,
        empty = false
    },

    public_dir = nil

    -- treeshake = true
}

---@param config_or_path Bundler.Config|string
---@return Bundler.Config config
local function parse_config(config_or_path)
    ---@type Bundler.Config
    local config

    if type(config_or_path) == "string" then
        local extension = pathlib.extension(config_or_path)

        if extension == ".json" then
            local file = io.open(config_or_path, "r")

            assert(file, "Config file specified does not exist")

            assert(file:read(0), "Cannot read config file")

            local read_config = json.decode(file:read("a"))

            config = setmetatable(read_config, { __index = default_config })
        elseif extension == ".lua" then
            local read_config = loadfile(config_or_path)(pathlib.to_lua(config_or_path), config_or_path)

            config = setmetatable(read_config, { __index = default_config })
        else
            error(string.format("Unsupported file extension %s", extension))
        end
    elseif type(config_or_path) == "table" then
        config = setmetatable(config_or_path, { __index = default_config })
    else
        error(string.format("Unknown configuration type %s", type(config_or_path)))
    end

    -- Warn about keys in config that don't exist in default
    for k, _ in pairs(config) do
        if not default_config[k] then
            warn(string.format("Key '%s' does not exist in default configuration object. Removing it."))

            config[k] = nil
        end
    end

    return config
end

---@param config Bundler.Config
local function fix_config(config)
    for i, export in pairs(config.exports) do
        for k, v in pairs(export) do
            config.exports[i][k] = v:gsub(".lua", ""):gsub("[/\\]", ".")
        end

        if export.out_file:match("%.") then
            error("outputted files may not be contained in a subdirectory")
        end
    end

    return config
end

-- TODO FIXME remove path separators from end of outdir, publicdir, and indir if present
local function main()
    local parser = argparse("bundler", "package lua files into a portable folder structure including dependencies")

    parser:option("-c --config --config-file", "Read from a .lua or .json configuration file")
    parser:option("-o --outdir", "Set the directory to ouptut packaged files")
    parser:option("-i --indir", "Set the directory to read source files from")
    parser:option("-m --main", "Set the main file in the source directory")
    parser:option("-e --export", "Export a given file"):count("*")
    parser:option("-m --map", "Remap a given file - <in> <out>"):count("*"):args(2)
    parser:option("-s --strip", "Remove one of the choices"):choices({ "comments", "annotations", "empty" }):count("*")
    parser:option("-p --publicdir", "Set the directory to copy LICENSE, README, etc from to outdir")

    local args = parser:parse()

    ---@type Bundler.Config
    local config = setmetatable({ strip = {} }, { __index = default_config })

    -- steal config file if provided
    if args.config then
        config = parse_config(args.config)
    end

    -- set outdir if provided
    if args.outdir then
        config.out_dir = args.outdir
    end

    -- set indir if provided
    if args.indir then
        config.in_dir = args.indir
    end

    -- set publicdir if provided
    if args.publicdir then
        config.public_dir = args.publicdir
    end

    -- set main via args.export
    if args.main then
        table.insert(args.export, args.main)
    end

    -- map file -> file
    for _, v in ipairs(args.export) do
        table.insert(config.exports, { in_file = v, out_file = v })
    end

    -- map fileA -> fileB
    for _, v in ipairs(args.map) do
        table.insert(config.exports, {
            in_file = v[1],
            out_file = v[2]
        })
    end

    for _, v in pairs(args.strip) do
        config.strip[v] = true
    end

    config = fix_config(config)

    Bundler()
        :set_config(config)
        :run()
end

main()


-- TODO shim template test:
--[[
    require("lib.bundler.shim_template")

    local Bundler = require("lib.bundler.Bundler")
    local Bundler2 = require("<UUID>.Bundler")

    assert(Bundler == Bundler2)
]]

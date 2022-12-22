local cli = require("lib.test.cli")
local fs  = require("src.util.fs")

local spawn = require("src.agnostic.spawn")

-- audit all files for usage

--- Split a string into an array by newlines
---@param s string the string to split up
---@return string[] lines
local function split_newlines(s)
    local lines = {}
    for sub in string.gmatch(s, "[^\r\n]+") do
        table.insert(lines, sub)
    end

    return lines
end

--- Convert a filesystem path to a lua module name
---@param path string
---@return string
local function as_module(path)
    local new_path = path
        -- remove ./
        :gsub("%./", "")
        -- remove .lua
        :gsub(".lua", "")
        -- / -> .
        :gsub("/", ".")
        -- <mod>.init -> mod
        :gsub("%.init", "")

    return new_path
end

local function audit()
    print("No files depend on these files: ")

    local ignore = {
        "lib",
        "_types",
        "test",
        "rc.lua",
        "audit.lua",
        "config.example.lua",
        "src/widgets/applet"
    }

    spawn("find -name '*.lua'", function(res)
        for _, file in ipairs(split_newlines(res)) do
            (function()
                for _, ignore_item in ipairs(ignore) do
                    if string.find(file, "./" .. ignore_item) then
                        return
                    end
                end

                local module_name = as_module(file)

                spawn("find -name '*.lua' | grep -v \"" .. file .. "\"", function(res)
                    local has_depends = false

                    for _, possibly_depends in ipairs(split_newlines(res)) do
                        local contents = fs.read(possibly_depends)

                        if not contents then
                            error("file " .. possibly_depends .. " does not load")
                        end

                        if string.find(contents, module_name) then
                            has_depends = true

                            break
                        end
                    end

                    if not has_depends then
                        print(" - " .. module_name)
                    end
                end)
            end)()
        end
    end)
end

audit()

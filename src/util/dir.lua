local script_dir = require("src.util.script_dir").script_dir
local join       = require("src.polyfill.path.join")
local fs         = require("src.util.fs")

---@class Zingle.Awesome.Dir.CallableTable
---@field protected __parent_path string
---@operator call:string

---@param parent_path string
---@param subpaths table<string, Zingle.Awesome.Dir.CallableTable>
local function recurse_insert_path(parent_path, subpaths)
    subpaths.__parent_path = subpaths.__parent_path or ""

    for k, subpath in pairs(subpaths) do
        if k ~= "__parent_path" then
            ---@diagnostic disable-next-line:invisible
            subpath.__parent_path = join(parent_path, subpath.__parent_path)

            recurse_insert_path(parent_path, subpath)
        end
    end
end

--- nice filesystem-type mock
---@generic T:table<string, Zingle.Awesome.Dir.CallableTable>
---@param path string
---@param subpaths T?
---@return Zingle.Awesome.Dir.CallableTable | T
local function callable_table(path, subpaths)
    subpaths = subpaths or {}

    recurse_insert_path(path, subpaths)

    return setmetatable(subpaths, {
        __call = function(t, file, notexists_ok)
            local path = join(script_dir(), t.__parent_path, path, file)

            if file then
                assert(fs.exists(path) or notexists_ok, string.format("File %q does not exist!", path))
            end

            return path
        end
    })
end

local dir = {
    asset = callable_table("asset", {
        awesome = callable_table("awesome", {
            core = callable_table("core", {
                cli = callable_table("cli")
            })
        })
    }),
    src = callable_table("src", {
        awesome = callable_table("awesome", {
            actions = callable_table("actions"),
            services = callable_table("services"),
        })
    }),
    config = callable_table("config", {
        actions = callable_table("actions"),
        scripts = callable_table("scripts"),
        services = callable_table("services"),
    }),
    generated = callable_table("generated", {
        persistent_storage = callable_table("persistent-storage"),
        log = callable_table("log"),
    })
}

return dir

local Promise         = require("src.polyfill.Promise")
local LuaC            = require("src.util.soft_load.LuaC")
local LuaX            = require("lib.LuaX")
local dir             = require("src.util.dir")
local fs              = require("src.util.fs")
local time            = require("src.util.time")

---@class Zingle.SoftLoadedAsset : Log.BaseFunctions
---@field asset_path string
---@field ttl number
---@field last_load number
---
---@operator call:Zingle.SoftLoadedAsset
local SoftLoadedAsset = class("Zingle.SoftLoadedAsset")

---@class Zingle.SoftLoadedAsset.Options
---@field path string
---@field ttl number? time-to-live in seconds

--- TODO SoftLoadedAsset global Timer to kill dead modules

--- TODO set ttl here
--- TODO FIXME type
function SoftLoadedAsset:init(options)
    self.asset_path = options.path

    self.ttl = options.ttl or time:minutes(30):toSeconds()
end

function SoftLoadedAsset:get_dump_filename()
    local filename = self.asset_path
        :gsub("%.", "_")

    return filename .. ".bin"
end

-- TODO throw this in a worker thread
--- Get this module's chunk
function SoftLoadedAsset:get_chunk()
    local path = dir.generated.compiled(self:get_dump_filename(), true)

    fs.mkdir_p(path)

    if not fs.exists(path) then
        local luax_transpiled = LuaX.transpile.from_path(self.asset_path)

        LuaC.from_string(luax_transpiled, self.asset_path)
            :to_file(path)
    end

    local chunk, err = loadfile(path, "b")

    if not chunk then
        error(string.format("Should-be-unreachable error: %s", err))
    end

    return chunk() or true
end

function SoftLoadedAsset:kill()
    self.module = nil
end

function SoftLoadedAsset:get_module()
    self.last_load = os.time()

    if self.module then
        return Promise.resolve(self.module)
    end

    return Promise(function(res)
        local module = self:get_chunk()

        self.module = module

        res(self.module)
    end)
end

return SoftLoadedAsset

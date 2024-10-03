-- TODO move this to util? 

local fs = require("src.util.fs")
local join = require("src.polyfill.path.join")
local lfs = require("lfs")

---@class Zingle.Awesome.DirectoryPoller : Log.BaseFunctions
local DirectoryPoller = class("Zingle.Awesome.ScriptPoller")

function DirectoryPoller.any_validator()
    return true
end

---@param path string
function DirectoryPoller.default_loader(path)
    local chunk, err = loadfile(path)

    if not chunk then
        error(err)
    end

    return chunk()
end

---@class Zingle.Awesome.DirectoryPoller.Settings
---@field dir string
---@field validator? fun(object: any): boolean
---@field expected? boolean
---@field loader? fun(path: string): any

---@param settings Zingle.Awesome.DirectoryPoller.Settings
function DirectoryPoller:init(settings)
    self.dir = settings.dir
    self.expected = settings.expected or false

    self.validator = settings.validator or self.any_validator
    self.loader = settings.loader or self.default_loader

    self.modules = {}
    self.mtimes = {}
end

---@param settings Zingle.Awesome.DirectoryPoller.Settings
function DirectoryPoller.create(settings)
    return DirectoryPoller(settings)
end

---@return string[]
function DirectoryPoller:ls()
    local exists = fs.exists(self.dir)
    local is_dir = fs.is_dir(self.dir)

    if not exists or not is_dir then
        if self.expected then
            local err = exists and
                "Expected directory %q, found file" or
                "Expected directory %q, found nothing"

            log.error(string.format(err, self.dir))
        end

        return {}
    end

    return fs.ls(self.dir)
end

---@param path string
function DirectoryPoller:try_load (path)
    local ok, res = pcall(self.loader, path)

    if not ok then
        local err = res

        log.error(string.format("Unable to load file %q: %s", path, err))

        return
    end

    local module = res

    local validated = self.validator(module)

    if not validated then
        log.error(string.format("Ignoring %q, as it failed validation", path))

        return 
    end

    self.modules[path] = module

    log.info(string.format("Loaded %q", path))
end

---@param path string
function DirectoryPoller:mtime_changed (path)
    local last_mtime = self.mtimes[path]
    
    local mtime = lfs.attributes(path, 'modification') --[[@as integer]]

    self.mtimes[path] = mtime

    if not last_mtime then
        return true
    end

    return mtime > last_mtime
end

function DirectoryPoller:poll()
    local paths = {}

    for _, path in ipairs(self:ls()) do
        path = join(self.dir, path)

        if fs.is_dir(path) then
            path = join(path, "init.lua")
        end

        paths[path] = true

        if self:mtime_changed(path) then
            self:try_load(path)
        end
    end

    -- Clean up dead modules
    local has_dead = false
    for path in pairs(self.modules) do
        if not paths[path] then
            log.info(string.format("Script %q found to be removed", path))

            self.modules[path] = nil

            has_dead = true
        end
    end

    if has_dead then
        -- TODO not in love with this - maybe poll just returns has_dead?
        collectgarbage("collect")
    end
end

return DirectoryPoller

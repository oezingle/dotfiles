local HotReload        = require("src.util.HotReload")
local lfs              = require("lfs")
local exists           = require("src.util.fs.exists")
local is_dir           = require("src.util.fs.is_dir")
local join             = require("src.polyfill.path.join")
local dir              = require("src.util.dir")
local fs               = require("src.util.fs")

-- TODO load config/scripts, and anything found in src.actions
-- TODO (use lfs, ls dir, build lua-like paths, searchpath) (this avoids hard-coding paths that could be from ./?/init.lua)

local load_scripts     = {
    ---@type Zingle.HotReload.ModuleWatcher[]
    watchers = {},
}

local validator        = {}
load_scripts.validator = validator

function validator.is_action()
    -- TODO FIXME validate this
end

function validator.is_service()
    -- TODO FIXME validate this
end

--- TODO FIXME custom require - setfenv for any calls to require() in loaded files
---@param modname string
function load_scripts.require(modname)

end

function load_scripts.make_loaded()

end

---@return table<string, true>
function load_scripts.find_files()
    local files_existing = {}

    -- TODO FIXME make these paths betterer
    for dir_name, settings in pairs({
        [dir.src.awesome.actions()] = {
            validator = validator.is_action
        },
        [dir.src.awesome.services()] = {
            validator = validator.is_service
        },
        [dir.config.actions()] = {
            validator = validator.is_action
        },
        [dir.config.scripts()] = {

        }
    }) do
        if not exists(dir_name) then
            log.warn(string.format("Expected directory %q, found nothing", dir_name))
        elseif not is_dir(dir_name) then
            log.error(string.format("Expected directory %q, found file", dir_name))
        else
            for _, file in ipairs(fs.ls(dir_name)) do
                -- TODO validation etc.
                local path = join(dir_name, file)

                files_existing[path] = true
            end
        end
    end

    return files_existing
end

---@param existing table<string, true>
---@return Zingle.HotReload.ModuleWatcher[]
function load_scripts.find_dead(existing)
    local watchers_dead = {}
    for _, watcher in ipairs(load_scripts.watchers) do
        if not existing[watcher.path] then
            table.insert(watchers_dead, watcher)
        end
    end

    return watchers_dead
end

function load_scripts.reset()
    load_scripts.watchers = {}
end

function load_scripts.poll()
    local files = load_scripts.find_files()

    for file in pairs(files) do
        if fs.is_dir(file) then
            file = join(file, "init.lua")
        end

        local chunk, err = loadfile(file)

        if chunk then
            package.loaded[file] = chunk()

            log.info("Loaded", file)
        else
            log.error(string.format("Unable to load file %q: %s", file, err))
        end
    end

    local dead = load_scripts.find_dead(files)
end

return load_scripts
